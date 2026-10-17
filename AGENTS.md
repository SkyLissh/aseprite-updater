# AGENTS.md — aseprite-updater

Standing instructions for every AI agent working in this repository.
If a rule conflicts with a habit, the rule wins.

## Role

The user writes their own code. You are an assistant for **ideas, debate and focused tasks** —
not a feature factory. Changes asked of you are targeted edits, not full implementations of a
feature. The user is the owner and decision-maker of everything in this repo.

## Highest-priority rules

1. **Never change code that was not asked for.** No edits, installs, commits, or tooling changes
   without an explicit request. Explaining what should change is not permission to change it.
2. **The user decides.** Never accept vague instructions like "do what you think best" or
   "make it just work". When key information is missing, ask — and do not proceed until the
   user's answer actually resolves your doubt. The user must stay able to veto at every step.
3. **Honest debate.** Accept pushback from the user — but also push back when the user is wrong
   about something technical. Respect disagreement, not compliance.
4. **When in doubt, ask.** A short clarifying question is always cheaper than a wrong assumption.

## How to explain changes

Every proposed change must be understandable before it happens:

- State your intention and reasoning, not just the diff.
- Show it with **code snippets** for the actual changes.
- Explain what each change **could affect** (consumers, generated files, builds).
- Include a **before/after file-tree example** of the affected area, so structural mistakes
  (wrong grouping, wrong folder) are visible at a glance:
  ```
  features/releases/widgets/
    release_modal.dart          # currently: dialog + views crammed
    release_dialog_header.dart  # NEW: extracted header
    ...
  ```
- If the user seems confused or challenges an explanation, **re-explain differently** — simpler
  analogy, smaller snippet, bigger picture. Do not just repeat the same words louder.

## After making changes

Close every change with a clear account:

- ✅ what was done
- ❌ what was NOT done (explicitly, even if obvious)
- ⏳ what needs extra input, data, or decisions from the user before continuation

## Commit guidelines

- **Format:** follow gitmoji-cli's emoji-first format: `<emoji> <description>` or
  `<emoji> (<scope>): <description>`. Use one Unicode emoji, an optional feature/component
  scope, and a concise, imperative description. Do not prepend Conventional Commit types
  such as `feat:` or `fix:`.
- **Emoji selection:** use the meanings from the [official Gitmoji guide](https://gitmoji.dev/),
  which gitmoji-cli uses for its emoji picker. Consult `gitmoji --list` or
  `gitmoji --search <keyword>` when choosing an emoji; do not invent project-specific meanings.
  Common choices: ✨ new features, 🐛 bug fixes, 📝 documentation, ♻️ refactoring,
  🎨 code structure/formatting, 💄 UI/style, ✅ tests, 🔧 configuration, 🌐 localization,
  and 🚚 file/resource moves or renames. Choose the emoji matching the commit's main purpose.
- **Examples:** `✨ add incremental builds`, `🐛 (release): handle missing assets`,
  `🚚 rename releases feature folder`, `📝 document commit guidelines`.
- **Manual workflow:** `gitmoji -c` prompts for the emoji, optional scope (when enabled),
  title, and optional body (when enabled). Agents must use the same message format even
  when committing with Git directly. See the [CLI documentation](https://github.com/carloscuesta/gitmoji-cli#commit)
  and [Gitmoji specification](https://gitmoji.dev/specification).
- **Authorization:** these guidelines do not authorize staging or committing changes;
  create commits only when explicitly requested. Leave existing commit history unchanged
  unless a rewrite is explicitly requested.

## Code guidelines

- **Feature-based architecture** (`core/`, `l10n/`, `features/<feature>/{models,services,
  providers,widgets}`). Flat inside features; no `data/domain/presentation` ceremony.
- **One widget per file.** Two widgets in a file are acceptable only when the second is small
  and clearly tied to the first. The moment composition gets complex, split into files and
  group related ones in the feature's `widgets/` folder.
- **Shared components** live in `core/`. A feature-local widget may be promoted to shared once
  a second real consumer exists (propose the promotion, don't move it silently).
- **Generated files** (`.g.dart`, `.freezed.dart`) start **ungrouped**. When a folder starts
  getting hard to track at a glance (e.g. several models producing 15+ files), *suggest*
  grouping with a file-tree preview — the user decides. Same for providers and any barrel files.
- **Never reinvent the wheel.** Before writing any non-trivial logic or widget, check whether a
  lib that's already installed can do it; if not, evaluate and *suggest* a maintained one
  (e.g. markdown rendering, HTTP, state). Bias the judgment toward "solo dev, easiest to
  maintain" — a good library beats clever hand-rolled code almost always.
- **All user-facing text uses l10n** — keys in the `.arb` files, `flutter gen-l10n`
  (FVM SDK) to regenerate. Never hardcode UI strings.
  - When adding keys, add them to **every** existing `.arb` file in the same change, with the
    translation supplied by the agent. Flag any translation the user should double-check
    (nuance, phrasing) instead of silently shipping a guess.
  - If the agent notices a language file missing keys (missed by the user or from past work),
    it fills them in on its own and reports it in the ✅/❌ summary.
  - Creating a whole new language file only happens when the user asks.
- **Riverpod codegen only**: fetches as `@riverpod Future<T>` functions (AsyncValue),
  services/clients as `@Riverpod(keepAlive: true)` functions, long-running state as class
  `Notifier` (keepAlive) fed by event streams — never `AsyncNotifier` for the build process.
  Services stay plain Dart (no Riverpod, no Flutter imports), injected via constructor.
- **Run checks before presenting code**: `.fvm/flutter_sdk/bin/dart analyze` (+ tests when they
  exist) on anything presented as done. Verify third-party APIs against the installed package
  source in `~/.pub-cache/hosted/pub.dev/<pkg>-<ver>/` — never from memory.

## Project goal & roadmap

**Goal:** a cross-platform (Linux / Windows / macOS) **Aseprite builder + auto-updater** that
compiles Aseprite from source on the user's machine and keeps it updated. We never distribute
binaries (Aseprite license); no Docker / cross-compilation. Skia comes precompiled per platform.
Updates rebuild incrementally from a git clone, not fresh source archives.

Phases:

1. Build pipeline works on Linux (dev machine), deps assumed present.
2. Update flow: tag detection → incremental rebuild → swap-on-success.
3. Windows port + read-only dependency detection with one-click silent install.
4. Setup wizard for non-dev users (portable cmake/ninja, Skia mapping, macOS port).

GitHub base: `https://api.github.com/repos/aseprite/aseprite` (metadata only; asset downloads
use absolute URLs).
