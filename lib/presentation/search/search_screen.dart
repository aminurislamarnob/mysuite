import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/settings/app_settings.dart';
import '../../core/theme/app_icons.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/common.dart';
import '../../core/theme/app_theme.dart';
import 'search_provider.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final results = ref.watch(searchResultsProvider);
    final filter = ref.watch(searchKindFilterProvider);
    final settings = ref.watch(settingsProvider);
    final query = ref.watch(searchQueryProvider);

    final kinds = ResultKind.values
        .where((k) => settings.isEnabled(k.module))
        .toList();

    // The search field and its kind filters are the header, so they are built
    // here rather than through BrandTopBar, which centres a title.
    return BrandScaffold(
      header: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: [
                  CircleIconButton(
                    icon: AppIcons.back,
                    tooltip: 'Back',
                    size: 40,
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: BrandField(
                      controller: _controller,
                      hint: 'Search everything…',
                      autofocus: true,
                      textInputAction: TextInputAction.search,
                      onChanged: (v) =>
                          ref.read(searchQueryProvider.notifier).state = v,
                    ),
                  ),
                  if (query.isNotEmpty)
                    CircleIconButton(
                      icon: AppIcons.close,
                      tooltip: 'Clear',
                      size: 40,
                      onPressed: () {
                        _controller.clear();
                        ref.read(searchQueryProvider.notifier).state = '';
                      },
                    ),
                ],
              ),
            ),
            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Pill(
                      label: 'All',
                      selected: filter == null,
                      color: Theme.of(context).colorScheme.primary,
                      onTap: () =>
                          ref.read(searchKindFilterProvider.notifier).state =
                              null,
                    ),
                  ),
                  ...kinds.map(
                    (k) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Pill(
                        label: k.label,
                        icon: k.icon,
                        selected: filter == k,
                        color: Theme.of(context).colorScheme.primary,
                        onTap: () =>
                            ref.read(searchKindFilterProvider.notifier).state =
                                filter == k ? null : k,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      child: results.when(
        data: (hits) {
          if (query.trim().length < 2) {
            return const EmptyState(
              icon: AppIcons.search,
              title: 'Search across every module',
              message:
                  'Notes, tasks, habits, medicines, expenses and focus '
                  'sessions — all from one bar.',
            );
          }
          if (hits.isEmpty) {
            return EmptyState(
              icon: AppIcons.searchOff,
              title: 'No matches for "$query"',
            );
          }
          return ListView.builder(
            itemCount: hits.length,
            itemBuilder: (_, i) {
              final hit = hits[i];
              return Padding(
                padding: const EdgeInsets.only(bottom: cardGap),
                child: BrandTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: hit.kind
                          .color(context.brand)
                          .withValues(alpha: 0.13),
                      shape: BoxShape.circle,
                    ),
                    child: AppIcon(
                      hit.kind.icon,
                      size: 18,
                      color: hit.kind.color(context.brand),
                    ),
                  ),
                  title: Text(
                    hit.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    hit.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Text(
                    hit.kind.label,
                    style: TextStyle(
                      fontSize: 10,
                      color: hit.kind.color(context.brand),
                    ),
                  ),
                  onTap: () => _open(hit),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: BrandSpinner()),
        error: (e, _) =>
            EmptyState(icon: AppIcons.error, title: 'Error', message: '$e'),
      ),
    );
  }

  void _open(SearchHit hit) {
    switch (hit.kind) {
      case ResultKind.note:
        context.push('/note_editor', extra: hit.id);
      case ResultKind.task:
        context.push('/tasks');
      case ResultKind.habit:
        context.push('/habits');
      case ResultKind.medicine:
        context.push('/medicine');
      case ResultKind.expense:
        context.push('/expenses');
      case ResultKind.focus:
        context.push('/focus');
    }
  }
}
