# Project review checklist

This is our shared tracker for the review findings and agreed improvements.
The user leads implementation; the assistant helps explain tradeoffs, review
changes, and handle explicitly requested fixes. This is not the reverted
implementation plan, and it does not authorize code changes or commits.

Check an item only after its behavior has been verified. Record evidence beside
completed items. An unchecked item can be in progress; it does not mean no code
has been written.

## User-facing progress instead of logs

The app is intended for people who do not need technical knowledge to build and
update Aseprite. Show the current operation, its progress where measurable, and
a clear result. Compilation remains part of the app; compiler, Git, and installer
output should no longer be displayed as a live log in the app.

This direction replaces the earlier live-tail, lazy-list, NES scrollbar,
auto-scroll, and frozen-reading tasks. Those are no longer requirements for the
current experience. File logging is a separate follow-up; this implementation
drains and discards diagnostic output after parsing progress.

- [x] **Replace the visible log panel with operation progress.** Removed
  BuildLogs and its scroll/follow effects. The build screen shows localized
  operation labels and progress without a technical-details viewer or invented
  step counts. Verified by `test/features/build/build_progress_test.dart`.
  Sources: [Home](../lib/core/screens/home.dart),
  [BuildProgress](../lib/features/build/widgets/build_progress.dart) and
  [BuildOperationProgress](../lib/features/build/widgets/build_operation_progress.dart).

### Progress by operation

The table describes the intended presentation as each operation is implemented;
it does not mean dependency installation or compilation exists in the pipeline
already. Each percentage belongs to the named operation, not the entire build.

| Operation | What can be measured | Suggested presentation |
| --- | --- | --- |
| Git download | Git's reported transfer progress | "Downloading source — 64%" |
| Git preparation and submodules | Separate operations with their own progress, where available | Friendly named substeps; animated indicator when the total is unknown |
| Dependency downloads, including precompiled Skia | Received bytes / total bytes, when a reliable total is available | "Downloading required components — 42%" |
| Dependency installation | Progress exposed by the chosen installer; otherwise completed components | Percentage when supported; otherwise "Installing component 2 of 4" with an animated indicator |
| CMake configuration | No universal percentage assumed | "Preparing the build…" with an animated indicator |
| Ninja compilation | Finished build tasks / total build tasks | "Building Aseprite — 73%" |

- [x] **Use the existing NES UI widgets for known and unknown totals.** In
  installed nes_ui 0.32.0, NesProgressBar requires a double value from 0 to 1 and
  has no indeterminate mode. Its pixel/smooth styles only change the fill style.
  Use NesProgressBar for known progress and NesPixelRowLoadingIndicator for
  unknown progress. The pixel-row widget repeatedly fills/resets; it is not an
  indeterminate mode of the same bordered bar. A matching custom bordered
  animation would be a separate design decision. Widget tests verify measured
  progress, indeterminate workspace/submodule progress, bounded width,
  and no animation in terminal states. Workspace directory creation remains unchanged.

- [x] **Translate Git progress into operation updates.** Retained the Git
  CLI, arguments, concurrent pipe draining, UTF-8 decoder and LineSplitter.
  `LC_ALL=C` makes parsing predictable. Parser tests cover stderr identity,
  malformed percentages, fragmented/carriage-return updates, remote diagnostics,
  and submodules. A real recursive clone through SourceService against a temporary
  local Git fixture succeeded; captured progress excerpts are replayed in tests.
  Receiving objects reaching 100% does not mean checkout or recursive submodule
  work is complete. Change the named operation when appropriate instead of
  treating every Git percentage as overall clone progress. Unknown or unparsed
  progress falls back to an animated indicator without failing the operation.
  Ordinary diagnostics preserve the current progress. Submodule progress remains
  indeterminate for the rest of the clone; the percentage experiment was rolled
  back, and tests now reflect the retained behavior. A network Aseprite clone was
  not run.
  Source: [SourceService](../lib/features/build/services/source_service.dart).

- [ ] **Separate dependency downloads from installation.** Use byte progress
  only when the download total is known. Integrate installer progress separately
  for each supported tool/platform; do not assume a universal installer API.
  Component counts describe completed components, not elapsed-time percentages.
  Steps with no reliable total use the animated indicator. Implement these
  adapters alongside the corresponding future dependency operations.

- [ ] **Read compilation progress from Ninja when compilation is added.**
  NINJA_STATUS supports finished tasks (%f), total tasks (%t), and a finished-task
  percentage (%p). Prefer a recognizable status prefix to parsing arbitrary
  compiler messages. Task percentage is not percentage of elapsed time: linking
  can take longer than many compilation tasks. Keep CMake configuration separate.

- [x] **Avoid a fabricated overall percentage.** Start with named operations and
  per-operation progress. Do not assign arbitrary weights to cloning, dependency
  installation, and compilation. If a combined percentage is later considered,
  explicitly treat it as an estimate and review that design separately.

## Build state and diagnostic output

- [x] **Keep focused subscriptions.** Home still selects phase/status;
  BuildOperationProgress selects only `(operation, progress)`. Controller tests
  send 10,000 diagnostics without state publications; widget tests send 1,000
  diagnostics and verify the existing progress bar widget is retained.
  Sources: [Home](../lib/core/screens/home.dart) and
  [BuildProgress](../lib/features/build/widgets/build_progress.dart).

- [x] **Remove growing output snapshots from UI state.** BuildState now holds
  phase/status, operation/progress and errorMessage. BuildOutput is transient:
  SourceService parses progress and the controller discards diagnostic lines.
  Consumers and generated Freezed/Riverpod files use the new contract.
  Source: [BuildController](../lib/features/build/providers/build_controller.dart).

- [x] **Coalesce progress publication.** A single non-restarting 100ms timer
  publishes the latest changed value within an operation. Operation transitions
  publish immediately. Tests verify duplicate suppression, coalescing, resets,
  and cancellation on phase/operation changes, terminal states and disposal.

- [ ] **Save complete diagnostic output separately.** Agreed policy: keep one
  `<app-data-root>/logs/latest-build.log`, replacing it when the next run starts.
  Preserve all received output with a persistent buffered writer rather than
  opening/flushing per line, and finish writing on success or failure. Make the
  file location discoverable for troubleshooting without showing its contents
  in the app. Decide and review how file-write failures are reported without
  masking the build result. Source for the app-data root:
  [PathsService](../lib/features/build/services/paths_service.dart).

The existing `await for` consumption of orchestrator events is appropriate.
The concern is unnecessary output accumulation, publication frequency, and
subscriber scope; turning the controller into another stream is not itself a
fix. Widget rebuilds also do not imply a full-screen repaint for every event.

## Completion, failure, and window state

- [x] **Show a clear terminal result.** Localized idle/completed/failed headings
  replace the last operation and stop animation (widget tests). The controller
  requires BuildCompleted; 100% alone never completes a run. Failures retain error
  details in state without showing raw diagnostics. Diagnostic-file access remains
  part of the separate file-logging follow-up. Source:
  [BuildProgress](../lib/features/build/widgets/build_progress.dart).

- [x] **Handle failures deliberately.** BuildController retains errorMessage
  and failed status without rethrowing into Home's unawaited callback. Tests
  verify errors, unexpected stream termination, duplicate starts, restart/reset,
  and progress reaching 100% followed by failure. No automatic retry was added.
  Sources: [BuildController](../lib/features/build/providers/build_controller.dart)
  and [Home](../lib/core/screens/home.dart).

- [x] **Preserve the window child hierarchy.** WindowShell retains its container
  and outer Scaffold, hiding the border with transparency and removing padding
  when maximized. It owns the caption, controls and the single useWindow call;
  Home retains a nested content Scaffold without a window subscription. Tests
  verify normal/initially-maximized styling, native button forwarding, one
  listener with disposal cleanup, and child state/element preservation across
  maximize/restore. Home tests also verify the active build display remains
  mounted and the selected build is not started again.
  Source: [WindowShell](../lib/features/window/widgets/window_shell.dart).

- [x] **Localize touched build UI text.** All phase, operation and terminal
  labels use snake_case keys and context.l10n. Updated the only existing ARB
  (`app_en.arb`) and regenerated localization output.

## Verification

- [x] Add focused coverage for Git progress parsing, operation transitions,
  known/unknown totals, duplicate progress, publication coalescing, and scheduled
  work cleanup. Include fragmented and carriage-return output, submodule
  transitions, and unrecognized messages. Tests live in `test/features/build/`;
  PathsService tests cover existing/nested directories and failure propagation.
- [ ] Verify dependency byte/count progress and Ninja task progress when those
  operations are implemented; 100% followed by a failing exit must remain a
  failure, and unknown totals must not produce invented percentages.
- [x] Verify raw output does not rebuild the progress UI or accumulate in its
  state using synthetic controller/widget streams. Diagnostic-file completeness,
  flushing and file-write failures are deferred with logging.
- [ ] Check measurable and unknown-progress operations, terminal results, and
  maximize/restore in the running app. Compare frame timing and memory in profile
  mode; distinguish measured improvements from static-code expectations.
- [x] Run relevant analysis/tests and record their scope and results.
  Verified on 2026-10-19: `flutter test --coverage` passes all 58 tests, including
  27 focused build tests. The obsolete MyApp test and leftover percentage
  expectations no longer block the suite. Whole-project analysis has no errors
  or warnings; 13 existing double-quote lint notices remain in generated
  `release.g.dart`. Formatting and `git diff --check` pass. Coverage is written
  to `coverage/lcov.info`; recorded non-generated Dart lines, excluding generated
  localization, total 356/447 (79.6%). No coverage threshold is imposed.
- [x] **Cover the real app and Home flow.** The smoke test mounts
  AsepriteUpdater through its real router, checks localized release content and
  listener cleanup. Home tests verify selected-tag forwarding, release-to-build
  switching, and successful/failed terminal results. An optional theme argument
  keeps app-root tests independent of font downloads; the normal theme default
  is unchanged. Sources: [smoke test](../test/widget_test.dart) and
  [Home tests](../test/home_test.dart).
- [x] **Cover releases.** Unit tests exercise JSON mapping, required-field/date
  validation, latest-release HTTP responses/errors and provider states. Widget
  tests exercise loading/error/data views, Update callbacks, changelog dialogs,
  Markdown rendering, allowed HTTP/HTTPS links and rejected link targets. Tests
  inject Dio through an optional constructor argument and use an in-memory
  adapter; production GitHub defaults are unchanged. Sources:
  [release tests](../test/features/release/).
- [x] **Cover window components without opening a native window.** Method-channel
  fakes verify initial state, maximize/unmaximize/minimize events, forwarded
  actions, button callbacks, shell styling and listener disposal. A stateful
  child and active build display stay mounted across simulated maximize/restore
  events. This does not establish native desktop behavior or frame timing.
  Sources: [window tests](../test/features/window/).

Tests use controlled responses rather than live HTTP, URL launching or native
window operations. The earlier local recursive Git clone remains manual
integration evidence; this suite replays captured output and tests source
validation, not Process.start, actual pipe draining or Git exit failures. Native
startup, Linux environment-path selection, live cloning, desktop visual checks,
frame timing and memory profiling remain outside this unit/widget testing task.

## Deferred findings and unfinished work

These are retained for visibility, not included in the current build/window work.

- [ ] **Font packaging:** chosen Google Fonts are not bundled; fresh installs
  depend on downloading them. Deferred by request. Source:
  [theme](../lib/core/theme/theme.dart).
- [ ] **Release error recovery:** the release error view has no retry action.
  Deferred by request. Source:
  [ReleaseOverview](../lib/features/release/widgets/release_overview.dart).
- [ ] **Release link errors:** launchUrl is not awaited inside its try/catch, so
  asynchronous failures escape that handler. Deferred with release work. Source:
  [ReleaseModal](../lib/features/release/widgets/release_modal.dart).
- [ ] **Orchestrator stages:** the current pipeline clones, then emits
  deploying/completed. Compilation and deployment are unfinished roadmap work,
  not implemented by this documentation update. Use the operation table as those
  stages are added; do not expand this cleanup into implementing them. Source:
  [OrchestratorService](../lib/features/build/services/orchestrator_service.dart).
- [ ] **Repeat builds/update flow:** cloning rejects an existing destination;
  incremental updates and recovery of incomplete checkouts remain future work.
  Source: [SourceService](../lib/features/build/services/source_service.dart).
- [x] **Obsolete smoke test:** replaced the missing-MyApp counter-template test
  with a real AsepriteUpdater smoke test. Source:
  [widget test](../test/widget_test.dart).
- [ ] **Minimized state:** the window hook sets isMinimized on minimization but
  does not reset it on restore. Lower priority; currently unused by visible UI.
  Source: [useWindow](../lib/features/window/hooks/use_window.dart).

## References

- [Riverpod: focused subscriptions with select](https://riverpod.dev/docs/how_to/select)
- [Git: clone progress reporting](https://git-scm.com/docs/git-clone)
- [Ninja: progress status placeholders](https://ninja-build.org/manual.html#_environment_variables)
- [Windows Installer: example of installer-specific progress messages](https://learn.microsoft.com/en-us/windows/win32/msi/handling-progress-messages-using-msisetexternalui)

NES UI widget behavior above was checked against the installed nes_ui 0.32.0
source (nes_progress_bar.dart and nes_loading_indicator.dart). Recheck the API
if the package version changes.
