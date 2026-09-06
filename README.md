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

## Backup and restore

**Settings → Data** shares a full JSON backup, and **Restore from a
backup** reads one back. The restore is the exact inverse of the export:
every row travels through the drift data class's own `toJson`/`fromJson`
pair, so a column added to a table cannot be exported and then silently
dropped on the way back in. Avatars ride along as base64, because the
path a backup records names a directory on the device that wrote it.

A restore replaces the database rather than merging into it, so it parses
the whole file before touching a single row — a file that turns out to be
damaged halfway through is refused with the existing data still in place.
Foreign keys are deferred for the transaction, since folders nest inside
each other and no insert order can satisfy that row by row.

`RestoreService.sections` has to name every table; `restore_service_test.dart`
fails if a new table is added without one, which would otherwise have the
restore wipe it and never refill it.

## Ambient sounds

The Focus timer's six loops live in `assets/sounds/` as 16-bit mono WAV.
PCM rather than mp3 or aac because those formats pad the stream, and a
padded loop clicks at every wrap. They are synthesised rather than
recorded — each bed is built in the frequency domain with random phase,
which makes the buffer exactly periodic and the loop seamless by
construction. The generator is not checked in; `ambient_sounds_test.dart`
holds the properties that matter (mono 16-bit, no clipping, matched
loudness, and a seam no larger than an ordinary sample step).

## How-to guides

**Settings → How to** opens a page of short guides: a quick start, one
guide per module, and one each for the assistant, the overview tabs,
reminders, people and security. Each is a collapsible card of numbered
steps plus a few "good to know" lines, and a module's card ends with a
button into that module — or a "Turn on" button when it is switched
off. The pills on the Settings card open the page at that module.

The text lives in `lib/presentation/settings/how_to_content.dart`, one
`HowToGuide` per card. It describes what the app does today, so a
feature change that alters a step should update its line there too.

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
