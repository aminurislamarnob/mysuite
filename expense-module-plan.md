# Expense module — agreed plan (2026-09-03)

Decisions reached in a grilling session and verified against every consumer of
the expense tables. Build order is the commit order at the bottom.

## Ground rules

- **Zero migration, greenfield schema.** Table classes are edited to their
  ideal shape; `schemaVersion` stays 1; an existing dev DB is thrown away by
  hand. No `onUpgrade` code, no backfill.
- **Verification:** in-memory drift repository tests (pattern:
  `test/medicine_repository_test.dart`) for money paths only. UI hand-checked.
- **Landing:** commit the in-flight `BrandField` work first, then a branch of
  dependency-ordered commits (each builds and is reviewable alone).

## Schema

| Table | Change |
|---|---|
| `People` (new, core) | Replaces `MedicineProfiles`. `name`, `relation`, `color`, `type` (household \| contact). `Self` seeded, undeletable. Managed in Settings → People. Medicine (`Medicines.profileId`, `SymptomLogs.profileId`, 4 files) repoints; backup key `medicineProfiles` → `people`. |
| `Expenses.personId` | Non-null FK → People, defaults to `Self`. Default applied **in the repository** (`addTransaction`) so `payRecurring` and every caller get it. |
| `Expenses.loanId` | Nullable FK → Loans. |
| `Loans` (new) | `personId`, `direction` (0 lend / 1 borrow), `principal`, `note`, `dueDate?`, `createdAt`, `settledAt?`. `outstanding = principal − Σ repayments`, derived. |
| `TxKind` | 3 = lend, 4 = borrow, 5 = repayment. Real ledger rows, so balances stay truthful; `totals()`/`monthReport` already count only 0 and 1. |
| `Budgets` | Add `monthStart` (date, first of month). Unique per (`categoryId`, `monthStart`); `categoryId = null` = Overall. **Drop dead `rollover`.** Upsert-by-category logic replaced. |
| `ExpenseCategories` | No archive column. |

## Features

1. **Compact overview card** — one `TintCard`: total balance, month in / out
   (the two `StatTile`s fold in), `N accounts ›`. Tapping opens an **accounts
   sheet** with add / rename / recolour / archive (wires `createAccount`).
   - Tiles resolve account names from an *all-accounts* provider so archived
     accounts still label old rows.
   - Archiving is allowed with a non-zero balance; archived balances are
     excluded from the total.
2. **Row gap** — `BrandTile` gains `dense: false` (deltas `FTileStyle.padding`).
   Only the transaction list opts in.
3. **Entry sheet** — segments Expense / Income / Transfer / **Bill**. Bill
   swaps in name / period / next due / subscription toggle and writes a
   `RecurringExpenses` row; the duplicate `_addBill` sheet is deleted.
   - Person picker (household only), defaults to Self.
   - `+ New` pill at the end of the category `Wrap` → inline category creation
     without losing the typed amount.
   - **Edit mode:** tapping a row reopens the sheet prefilled.
4. **Edit / remove** — `updateTransaction` reverses the old balance delta and
   applies the new one in a single drift transaction. Swipe-delete raises an
   undo toast; undo re-inserts **with the original id** so `loanId` /
   `receiptPath` links hold.
   - Lend/borrow principal rows are not swipe-deletable from the list
     (tap → "manage in Loans"). Deleting a repayment row recomputes the loan.
5. **Categories** — manage screen off the Expenses overflow (rename, recolour,
   re-icon, reorder, delete). Defaults are editable like any other.
   - Delete with history → "Move N transactions to …", `Other` preselected,
     no skip; income → income destinations only. Zero history → immediate.
   - Also: that category's **budgets are deleted**, its **recurring bills are
     repointed** to the destination.
   - `AppIcons.categoryIcons` grows to ~30 curated tokens; grid picker + colour
     swatches.
6. **Person** — shown in `_TxTile` subtitle when not Self; "Spend by person"
   section in Reports (reuses the `byCategory` aggregate shape).
   - Deleting a person with transactions → reassign-to-`Self` prompt, same
     rule as categories.
7. **Loans** — fifth tab (`BrandTabs` is scrollable). Own FAB + sheet
   (person from all People with inline quick-add, direction, amount, account,
   note, due date). Row: outstanding, "due in N days", **Repay** (partial,
   books kind 5), auto-Settled at zero. Deleting a loan removes its ledger
   rows and reverses balances.
   - Loans with a due date appear in the Reminders screen next to bills.
   - No due-date notifications (bills have none either — `scheduleBillReminder`
     is uncalled).
8. **Budgets** — month stepper sharing `reportMonthProvider` with Reports; edit
   and delete per row; empty month offers "Copy <previous month>'s budgets"
   relative to the *viewed* month.

## Cross-cutting fixes found in verification

- `export_service.dart:83` CSV labels: add lend / borrow / repayment.
- PDF report (`:319`): exclude kinds 3–5 from the spend report.
- JSON backup: add `people`, `loans`; drop `medicineProfiles`.
- `_TxTile`: explicit branches for kinds 3–5 (repayment sign follows loan
  direction).

## Out of scope

Split attribution across people, interest / instalment plans, recurring budget
templates, category archive, loan or bill notifications, person filter on the
Overview list.

## File layout

`expenses_screen.dart` keeps scaffold, tab wiring, export. Tabs move to
`widgets/overview_tab.dart`, `reports_tab.dart`, `budgets_tab.dart`,
`bills_tab.dart`, `loans_tab.dart`; `widgets/accounts_sheet.dart`,
`widgets/loan_sheet.dart`, `categories_screen.dart`.

## Commit order

1. In-flight `BrandField` prefix/hint fix + `test/brand_field_test.dart`.
2. Schema: People (+ medicine repoint), personId, Loans, loanId, TxKind 3–5,
   Budgets.monthStart, drop rollover; repository + tests; export fixes.
3. File split (move-only).
4. `BrandTile.dense`, compact card, accounts sheet.
5. Categories screen, icon map, inline quick-add, delete-with-reassignment.
6. Person picker, tile subtitle, Reports by-person, Settings → People.
7. Month-scoped budgets tab.
8. Bill segment in entry sheet; remove `_addBill`.
9. Edit mode + `updateTransaction` + undo.
10. Loans tab, sheet, repayments, reminders entry.
