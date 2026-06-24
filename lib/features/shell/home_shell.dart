import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/theme/app_theme.dart';
import '../dashboard/dashboard_screen.dart';
import '../insights/insights_screen.dart';
import '../modules/modules_screen.dart';
import '../quick_add/quick_add_sheet.dart';
import '../settings/settings_screen.dart';

/// Root scaffold: 4 nav destinations split around a centered Quick Add FAB,
/// matching the spec's "Dashboard · Modules · Quick Add (FAB) · Insights ·
/// Settings". A notched [BottomAppBar] keeps the FAB from overlapping labels.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _pages = [
    DashboardScreen(),
    ModulesScreen(),
    InsightsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _pages),
      floatingActionButton: FloatingActionButton(
        onPressed: () => QuickAddSheet.show(context),
        elevation: 2,
        shape: const CircleBorder(),
        child: const Icon(LucideIcons.plus),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: context.colors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        padding: EdgeInsets.zero,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: LucideIcons.house,
              label: 'Today',
              selected: _index == 0,
              onTap: () => setState(() => _index = 0),
            ),
            _NavItem(
              icon: LucideIcons.layoutGrid,
              label: 'Modules',
              selected: _index == 1,
              onTap: () => setState(() => _index = 1),
            ),
            const SizedBox(width: 48), // notch gap for the FAB
            _NavItem(
              icon: LucideIcons.chartPie,
              label: 'Insights',
              selected: _index == 2,
              onTap: () => setState(() => _index = 2),
            ),
            _NavItem(
              icon: LucideIcons.settings,
              label: 'Settings',
              selected: _index == 3,
              onTap: () => setState(() => _index = 3),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? context.colors.primary : context.muted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 3),
              Text(
                label,
                style: context.text.labelSmall?.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
