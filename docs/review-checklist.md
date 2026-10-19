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
  progress, indeterminate workspace/submodule progress, bounded width, and no
  animation in terminal states. Workspace directory creation remains unchanged.

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
  Ordinary diagnostics preserve the current progress. Submodule progress stays
  indeterminate for the rest of the clone. A network Aseprite clone was not run.
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

- [ ] **Preserve the window child hierarchy.** WindowShell currently returns the
  child directly when maximized and wraps it otherwise, remounting descendants.
  Keep the same container and child structure; conditionally hide its border
  instead. Verify maximize/restore preserves descendant state and the active
  progress display without restarting the operation or remounting its subtree.
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
  Verified on 2026-10-19: all 26 focused build tests pass; scoped analysis of
  `lib/features/build` and `test/features/build` reports no issues. Formatting,
  full build_runner generation, localization generation and `git diff --check`
  pass. Whole-project tests have 27 passing tests and the existing missing-MyApp
  smoke-test failure. Whole-project analysis retains the baseline 22 findings:
  that error and 21 existing lint notices. No unrelated files were changed.
  Manual integration used a real recursive local Git clone through SourceService;
  network Aseprite cloning, desktop visual inspection, maximize/restore, frame
  timing and memory profiling were not performed.

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
- [ ] **Obsolete smoke test:** replace the missing-MyApp counter-template test
  when explicitly taken up. Source: [widget test](../test/widget_test.dart).
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
