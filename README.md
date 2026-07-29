# mysuite

All-in-one daily productivity & wellness app.

An offline-first Flutter app covering tasks, notes, habits, medicine,
expenses and focus sessions, with a shared insights view across modules.
Every module can be turned on or off, so the app stays as small as you
want it.

## Stack

- Flutter, Material 3
- [drift](https://drift.simonbinder.eu/) — local SQLite persistence
- [Riverpod](https://riverpod.dev/) — state and data providers
- [go_router](https://pub.dev/packages/go_router) — nested shell routing

## Running it

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

`build_runner` is needed after any change to the drift tables in
`lib/core/database/`, since the generated `.g.dart` bakes in column
defaults.

## Tests

```bash
flutter test
```
