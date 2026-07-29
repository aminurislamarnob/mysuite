import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/settings/app_settings.dart';
import '../../core/widgets/common.dart';
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

    final kinds =
        ResultKind.values.where((k) => settings.isEnabled(k.module)).toList();

    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Search everything…',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
          ),
          onChanged: (v) =>
              ref.read(searchQueryProvider.notifier).state = v,
        ),
        actions: [
          if (query.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                _controller.clear();
                ref.read(searchQueryProvider.notifier).state = '';
              },
            ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: const Text('All'),
                    selected: filter == null,
                    onSelected: (_) => ref
                        .read(searchKindFilterProvider.notifier)
                        .state = null,
                  ),
                ),
                ...kinds.map((k) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        avatar: Icon(k.icon, size: 15, color: k.color),
                        label: Text(k.label),
                        selected: filter == k,
                        onSelected: (_) => ref
                            .read(searchKindFilterProvider.notifier)
                            .state = filter == k ? null : k,
                      ),
                    )),
              ],
            ),
          ),
        ),
      ),
      body: results.when(
        data: (hits) {
          if (query.trim().length < 2) {
            return const EmptyState(
              icon: Icons.search,
              title: 'Search across every module',
              message: 'Notes, tasks, habits, medicines, expenses and focus '
                  'sessions — all from one bar.',
            );
          }
          if (hits.isEmpty) {
            return EmptyState(
              icon: Icons.search_off,
              title: 'No matches for "$query"',
            );
          }
          return ListView.builder(
            itemCount: hits.length,
            itemBuilder: (_, i) {
              final hit = hits[i];
              return ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: hit.kind.color.withValues(alpha: 0.13),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(hit.kind.icon, size: 18, color: hit.kind.color),
                ),
                title: Text(hit.title,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(hit.subtitle,
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Text(hit.kind.label,
                    style: TextStyle(fontSize: 10, color: hit.kind.color)),
                onTap: () => _open(hit),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) =>
            EmptyState(icon: Icons.error_outline, title: 'Error', message: '$e'),
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
