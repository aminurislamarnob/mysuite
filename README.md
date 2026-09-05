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

## AI voice assistant

Say one sentence and the right rows land in the right modules: *"spent
200 taka on lunch with bKash and remind me to call the doctor at 5, and
add Napa 3 times a day for 5 days"* becomes an expense, a task with a
reminder and a medicine course. It is reachable from the sparkle button
on the dashboard, the first row of the Quick Add sheet, and a long press
on the centre `+`.

Speech recognition runs on the device. The transcript is then parsed
by whichever provider is picked in **Settings → AI assistant**: Claude,
OpenAI, Gemini or DeepSeek, with the user's own API key. The key is
stored in the platform keychain, never in SharedPreferences. What is
sent is the transcript plus the names of the user's categories,
accounts, people, habits and projects, so the model can copy them
exactly; nothing else leaves the device. (The keychain plugin needs
`libsecret-1-dev` installed to build the Linux desktop target.)
Without a key, an offline
parser built on the existing quick-add and expense parsers handles the
command instead, in English and Banglish (Bangla script needs a
provider).

Parsed entries are previewed as cards before anything is written.
Tapping a card opens the module's own editor prefilled; "Save all"
writes the rest. Names that do not match anything fall back (Other,
the first account, the user themself) with a warning on the card, and
nothing is ever auto-created from a mis-heard word. "Auto-save without
preview" skips the preview only when every card resolved cleanly.

The action schema every provider receives, and the per-kind tool
catalogue an MCP server would expose if one is ever added, live in
`lib/core/ai/ai_command_schema.dart`.

## Tests

```bash
flutter test
```

## Formatting

The repo is `dart format` clean, and stays that way:

```bash
dart format .
```

One reformat already rewrote 911 lines across 22 files without changing
any code. `git blame` credits a line to whatever commit last touched it,
so those lines would otherwise all point at the reformat instead of at
the commit that put the code there. `.git-blame-ignore-revs` lists that
commit — but blame only reads it if the clone opts in:

```bash
git config blame.ignoreRevsFile .git-blame-ignore-revs
```

Run that once per clone. GitHub's web blame reads the file with no setup.
