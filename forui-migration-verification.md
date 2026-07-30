# forui Migration — Implementation Verification Report

Verified against plan: `~/.claude/plans/gleaming-weaving-blossom.md`
Date: 2026-07-30 · Branch: `main` @ `e327d8b`

## Verdict

The implementation is faithful to the plan. All six phases landed as committed
(`af29c78` → `e327d8b`). Two single-site Material leftovers and three minor
deviations were found.

## Verified as implemented

- **Phase 0** — `forui: 0.24.3` pinned exactly in `pubspec.yaml`;
  `FLocalizations.localizationsDelegates` added in `lib/main.dart`; `forui init`
  not run.
- **Phase 1** — `lib/core/theme/app_forui_theme.dart` builds `FThemeData` from
  the same `BrandTokens` as the Material half:
  - Brand radius ramp pinned: field 16 / tile 20 / card 24 / sheet 28.
  - Flat shadows, Material-matching barrier scrim, compact-density
    approximation (typography ×0.94, sizes ×0.92), high-contrast flattening.
  - All 22 `FIcons` tokens bridged to Hugeicons stroke-rounded via `AppIcon`
    (with `semanticsLabel` pass-through).
  - `main.dart` resolves brightness explicitly from `settings.themeMode` +
    platform, and mounts `FTheme` → `FToaster` → `FTooltipGroup` above
    `_LockGate`.
- **Phase 2** — wrapper layer rebuilt on forui with public APIs unchanged:
  `TintCard`→`FCard`, `BrandTopBar`→`FHeader.nested`, `CurvedNavBar` keeps the
  painted `_NavBarPainter` notch under `FBottomNavigationBar`. All 8 new
  wrappers exist (`BrandScaffold`, `BrandTile`, `BrandField`, `BrandSwitchTile`,
  `BrandSegmented`, `BrandFab`, `brandToast`, `brandDialog`/`brandConfirm`).
  `BrandScaffold` injects `Material(type: transparency)` and restores the 24px
  content icon theme.
- **Phases 3–6** — one commit per phase; a generics-tolerant sweep of every
  Material component in the swap table finds only 2 leftovers (below). Dead
  `elevatedButtonTheme` / `navigationBarTheme` / `tabBarTheme` removed.
- **Tests** — `test/forui_theme_test.dart` covers every required new test
  (colour mapping incl. high contrast, en/bn typeface switch, Hugeicons-not-
  Lucide icons, radius pins, tab style). `test/brand_theme_test.dart` has the
  rewritten `TintCard` assertions, the semantics-label `CurvedNavBar` tap test,
  and the `BrandScaffold` Material-ancestor guard.

## Gaps / inconsistencies

| # | Severity | Location | Issue | Plan says |
|---|----------|----------|-------|-----------|
| 1 | Medium | `lib/presentation/medicine/medicine_screen.dart:870` | Stock row still uses Material `PopupMenuButton<String>` + `PopupMenuItem`; no `popupMenuTheme` remains, so it renders in default Material styling | → `FPopoverMenu` (1 site) |
| 2 | Medium | `lib/presentation/expenses/widgets/expense_entry_sheet.dart:199` | Kind selector still a Material `SegmentedButton<int>`; the other 6 sites use `BrandSegmented`, and no `segmentedButtonTheme` remains, so it looks off-brand inside a branded sheet | → `BrandSegmented` (7 sites) |
| 3 | Low | `notes_screen.dart:370`, `tasks_screen.dart:807`, `medicine_screen.dart:944` | Drawers are Material `Drawer` + `ListView` + Material `DrawerHeader`; no `FSidebar` anywhere | "Material `Drawer` hosting `FSidebar`" — deviation works but is not noted in code as the plan requires |
| 4 | Low | `lib/core/theme/app_theme.dart:364` | `chipTheme` is now dead config — zero Material chip call sites remain (`BrandChip` is a hand-rolled `DecoratedBox`) | Same class as the `elevatedButtonTheme` deletion the plan ordered |
| 5 | — | session | `flutter analyze` / `flutter test` / build / emulator sweep not re-run during verification (shell permission declined); green status inferred from committed code, not execution | Per-phase gates in plan |

## Recommended follow-ups

1. Swap `medicine_screen.dart:870` to `FPopoverMenu` (or a `showFSheet` action
   list) and drop the last `PopupMenuItem`s.
2. Swap `expense_entry_sheet.dart:199` to `BrandSegmented<int>`.
3. Either adopt `FSidebar` in the three drawers or add a code comment recording
   the deliberate deviation.
4. Delete the dead `chipTheme` block from `app_theme.dart`.
5. Re-run `flutter analyze` + `flutter test` to confirm green.
