# Project review checklist

This is our shared tracker for the review findings and agreed improvements.
The user leads implementation; the assistant helps explain tradeoffs, review
changes, and handle explicitly requested fixes. This checklist does not
authorize code changes or commits.

Check an item only after its behavior has been verified. Record evidence beside
completed items. An unchecked item can be in progress; it does not mean no code
has been written.

## Current Linux milestone

The pipeline now prepares the workspace, clones the selected Aseprite tag and
submodules, downloads and extracts the configured precompiled Skia asset,
configures CMake, compiles with Ninja, and installs into a private prefix.
Deployment publishes desktop integration and the command link, then records the
installed tag before reporting completion. Required build tools and system
dependencies are assumed to be installed.

The release screen distinguishes a first installation from an existing installed
tag. The completed-build screen offers Open and Go back. Incremental updates,
interrupted-run recovery, dependency installation, and other platform ports
remain separate follow-up work.

Sources: [OrchestratorService](../lib/features/build/services/orchestrator_service.dart),
[DeploymentService](../lib/features/build/services/deployment_service.dart),
[ReleaseOverview](../lib/features/release/widgets/release_overview.dart).

## User-facing progress instead of logs

The app is intended for people who do not need technical knowledge to build and
update Aseprite. Show the current operation, its progress where measurable, and
a clear result. Compilation remains part of the app; compiler, Git, and installer
output should no longer be displayed as a live log in the app.

This direction replaces the earlier live-tail, lazy-list, NES scrollbar,
auto-scroll, and frozen-reading tasks. Those are no longer requirements for the
current experience. File logging is a separate follow-up; this implementation
drains and discards Git output without parsing progress.

- [x] **Replace the visible log panel with operation progress.** Removed
  BuildLogs and its scroll/follow effects. The build screen shows localized
  operation labels and progress without a technical-details viewer or invented
  step counts. Verified by `test/features/build/build_progress_test.dart`.
  Sources: [Home](../lib/core/screens/home.dart),
  [BuildProgress](../lib/features/build/widgets/build_progress.dart) and
  [BuildOperationProgress](../lib/features/build/widgets/build_operation_progress.dart).

### Progress by operation

The table describes the current Linux pipeline. Each percentage belongs to the
named operation, not the entire build. Automatic installation of system
dependencies remains deferred.

| Operation | What can be measured | Current presentation |
| --- | --- | --- |
| Workspace preparation | No percentage assumed | "Preparing your workspace…" with the animated indicator |
| Git clone, including checkout and submodules | No percentages or sub-operation progress | "Getting source code…" with the existing animated indicator |
| Skia download | Received bytes / total bytes, when a reliable total is available | "Downloading Skia…" with a progress bar or animated indicator |
| Skia extraction | Completed regular files / total regular files | "Extracting Skia…" with per-operation progress |
| CMake configuration | No universal percentage assumed | "Preparing the build…" with an animated indicator |
| Ninja compilation | Finished build tasks / total build tasks, when available | "Building Aseprite…" with a progress bar or animated indicator |
| Deployment | No percentage assumed | "Installing the build…" with the animated indicator |

- [x] **Use the existing NES UI widgets for known and unknown totals.** In
  installed nes_ui 0.32.0, NesProgressBar requires a double value from 0 to 1 and
  has no indeterminate mode. Its pixel/smooth styles only change the fill style.
  Use NesProgressBar for known progress and NesPixelRowLoadingIndicator for
  unknown progress. The pixel-row widget repeatedly fills/resets; it is not an
  indeterminate mode of the same bordered bar. A matching custom bordered
  animation would be a separate design decision. Widget tests verify measured
  download progress, indeterminate workspace/cloning progress, bounded width,
  and no animation in terminal states. Workspace directory creation remains unchanged.

- [x] **Keep Git cloning indeterminate.** The entire clone uses one Cloning
  step and the existing animated loader. SourceService returns Future<void>;
  the orchestrator waits for it before moving on. Removed Git progress models,
  parsing, percentage fixtures, sub-operation labels and the forced-progress
  flag. Stdout and stderr are still drained concurrently, and nonzero exit
  codes still fail the run. No progress stream is exposed by the source service.
  Source: [SourceService](../lib/features/build/services/source_service.dart).

- [ ] **Separate dependency downloads from installation.** Use byte progress
  only when the download total is known. Integrate installer progress separately
  for each supported tool/platform; do not assume a universal installer API.
  Component counts describe completed components, not elapsed-time percentages.
  Steps with no reliable total use the animated indicator. Implement these
  adapters alongside the corresponding future dependency operations.

- [x] **Read compilation progress from Ninja.** CompilationService sets a
  recognizable NINJA_STATUS prefix with finished and total task counts, then
  parses only matching status lines. Unknown totals use the animated indicator.
  Task percentage is not percentage of elapsed time: linking can take longer
  than many compilation tasks. CMake configuration remains a separate operation.
  Verified by [compilation process tests](../test/features/build/services/compilation_process_test.dart)
  and [build progress tests](../test/features/build/build_progress_test.dart).

- [x] **Avoid a fabricated overall percentage.** Start with named operations and
  per-operation progress. Do not assign arbitrary weights to cloning, dependency
  installation, and compilation. If a combined percentage is later considered,
  explicitly treat it as an estimate and review that design separately.

## Build state and diagnostic output

- [x] **Keep focused subscriptions.** Home selects run status. BuildProgress
  selects the localized step heading; BuildOperationProgress selects the derived
  fraction. Measurement updates preserve the heading and progress subtree.
  Equal snapshots do not publish; widget tests send 1,000 equal snapshots and
  verify the existing progress bar widget is retained.
  Sources: [Home](../lib/core/screens/home.dart) and
  [BuildProgress](../lib/features/build/widgets/build_progress.dart).

- [x] **Remove growing output snapshots from UI state.** BuildState holds a
  sealed BuildStep snapshot, run status and errorMessage. Step variants carry
  byte counts or task counts for measurable work; Cloning has no progress data.
  No separate phase enum is stored. The orchestrator emits one cloning step
  and awaits SourceService. Git output is drained and discarded. CMake and Ninja
  failures can include captured process output in their exceptions, which the
  controller retains as errorMessage. There are no growing live-log snapshots,
  diagnostic output events, or Git progress models in UI state.
  Consumers and generated Freezed/Riverpod files use this contract.
  Source: [BuildController](../lib/features/build/providers/build_controller.dart).

- [x] **Coalesce progress publication.** A single non-restarting 100ms timer
  publishes the latest complete snapshot within a measurable step.
  Step-type transitions publish immediately. Tests verify
  duplicate suppression, raw-count updates, coalescing, resets and cancellation
  on transitions, terminal states and disposal.

- [ ] **Save complete diagnostic output separately.** Agreed policy: keep one
  `<app-data-root>/logs/latest-build.log`, replacing it when the next run starts.
  Supply one shared writer to the services, managed per run outside controller
  and UI state; do not reintroduce output events. Preserve all received output
  with a persistent buffered writer rather than opening/flushing per line, and
  finish writing on success or failure. Make the
  file location discoverable for troubleshooting without showing its contents
  in the app. Decide and review how file-write failures are reported without
  masking the build result. Source for the app-data root:
  [PathsService](../lib/core/services/paths_service.dart).

- [x] **Add application logging without claiming full build-file logging.**
  The shared logger is configured at startup: warning level in release builds
  and debug level otherwise. Release metadata, build failures, and launch errors
  are logged. This does not implement the complete diagnostic file described
  above. Sources: [logger](../lib/core/logger.dart) and [startup](../lib/main.dart).

The existing `await for` consumption of orchestrator events is appropriate.
The concern is unnecessary output accumulation, publication frequency, and
subscriber scope; turning the controller into another stream is not itself a
fix. Widget rebuilds also do not imply a full-screen repaint for every event.

## Completion, failure, and window state

- [x] **Show a clear terminal result.** Localized idle/completed/failed headings
  replace the last operation and stop animation (widget tests). The controller
  requires BuildCompleted; 100% alone never completes a run. Failures retain error
  details and the last published step in state without showing raw diagnostics.
  Diagnostic-file access remains part of the separate file-logging follow-up. Source:
  [BuildProgress](../lib/features/build/widgets/build_progress.dart).

- [x] **Handle failures deliberately.** BuildController retains errorMessage
  and failed status without rethrowing into Home's unawaited callback. Tests
  verify errors, unexpected stream termination, duplicate starts, restart/reset,
  and progress reaching 100% followed by failure. No automatic retry was added.
  Sources: [BuildController](../lib/features/build/providers/build_controller.dart)
  and [Home](../lib/core/screens/home.dart).

- [x] **Offer completion actions and handle launch failures.** Open launches
  the installed executable; Go back returns to the release screen. A failed
  launch logs the exception and stack trace and shows a localized error snackbar
  while preserving completed build state. The local launch callback checks
  context.mounted before showing feedback after an asynchronous failure.
  Widget tests cover success, failure, another launch attempt, Back availability,
  and failure after the widget is removed. Source:
  [BuildProgress](../lib/features/build/widgets/build_progress.dart).

- [x] **Represent installed and available releases separately.** ReleaseState
  contains the latest release metadata and an optional installed tag.
  ReleaseService reads the plain-text `installed/release` record; deployment
  writes the selected tag after installation and integration succeed. The
  notifier watches a separate service provider, and update checks preserve the
  installed tag. Tests override the service rather than replacing notifier
  initialization and cover newer tags, invalidation, initial-error recovery,
  deployment persistence, and tag forwarding. Sources:
  [release provider](../lib/features/release/providers/release.dart),
  [ReleaseService](../lib/features/release/services/release_service.dart),
  [deployment tests](../test/features/build/services/deployment_service_test.dart).

- [x] **Localize and cover the first-install view.** With no installed tag,
  ReleaseOverview shows the localized start message and Start build button.
  Update and Changelog are absent; starting a build forwards the latest tag.
  Verified by [release overview tests](../test/features/release/release_overview_test.dart).

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

- [x] Add focused coverage for indeterminate cloning, step transitions,
  known/unknown download and compilation totals, duplicate progress,
  publication coalescing and scheduled work cleanup. Tests live in `test/features/build/`;
  PathsService tests cover existing/nested directories and failure propagation.
- [x] Verify Skia download/extraction progress and Ninja task progress.
  Service and widget tests cover measured and unknown totals; orchestrator and
  controller tests verify that progress followed by failure remains a failure.
  Sources: [build tests](../test/features/build/).
- [x] Verify equal snapshots do not rebuild the progress UI, and measurement
  updates preserve its heading. Raw diagnostics are not published as live-log
  snapshots; captured failure output can be retained in errorMessage.
  Diagnostic-file completeness, flushing and file-write failures remain deferred.
- [ ] Check measurable and unknown-progress operations, terminal results, and
  maximize/restore in the running app. Compare frame timing and memory in profile
  mode; distinguish measured improvements from static-code expectations.
- [x] Run relevant analysis/tests and record their scope and results.
  Latest implementation validation on 2026-11-02: the full suite passed with
  **167 tests passed and 4 skipped**. Whole-project analysis reported no errors
  or warnings, with 20 existing generated-code informational notices. Commands:
  `.fvm/flutter_sdk/bin/flutter test --no-pub --reporter expanded` and
  `.fvm/flutter_sdk/bin/dart analyze`. These recorded results precede this
  documentation-only update; no additional test run is needed for the prose.
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

HTTP, application launching, and window operations use controlled responses in
tests. Compilation and deployment tests also exercise small native-tool fixtures;
they do not build or launch the real Aseprite application. Source validation and
orchestrator waiting/failure behavior are covered. A live network clone, complete
Aseprite build, native desktop visual checks, frame timing, and memory profiling
were not part of the latest automated verification.

## Deferred findings and unfinished work

These remain outside the completed Linux milestone. Recovery is explicitly
deferred; the items below document follow-up work rather than extend this PR.

- [ ] **Font packaging:** chosen Google Fonts are not bundled; fresh installs
  depend on downloading them. Deferred by request. Source:
  [theme](../lib/core/theme/theme.dart).
- [ ] **Release error recovery:** the release error view has no retry action.
  Deferred by request. Source:
  [ReleaseOverview](../lib/features/release/widgets/release_overview.dart).
- [ ] **Release link errors:** launchUrl is not awaited inside its try/catch, so
  asynchronous failures escape that handler. Deferred with release work. Source:
  [ReleaseModal](../lib/features/release/widgets/release_modal.dart).
- [ ] **Repeat builds/update flow:** cloning rejects an existing destination;
  incremental updates and recovery of incomplete checkouts remain future work.
  Source: [SourceService](../lib/features/build/services/source_service.dart).
- [x] **Obsolete smoke test:** replaced the missing-MyApp counter-template test
  with a real AsepriteUpdater smoke test. Source:
  [widget test](../test/widget_test.dart).
- [ ] **Minimized state:** the window hook sets isMinimized on minimization but
  does not reset it on restore. Lower priority; currently unused by visible UI.
  Source: [useWindow](../lib/features/window/hooks/use_window.dart).

### Interrupted-run recovery (deferred)

The intended direction is to preserve valid work and retry incomplete operations,
rather than delete the entire workspace after an interruption. This is not
implemented and does not block the current Linux milestone. The exact persistence
format, validation rules, and platform-specific activation mechanism still need
design work before implementation.

- [ ] **Record the intended build inputs.** Persist the selected Aseprite tag
  and relevant Skia/build inputs so recovery continues the original target,
  even if a newer release becomes available. Validate artifacts on disk instead
  of trusting a saved phase or a directory's existence alone.
- [ ] **Reuse or repair source checkouts.** Reuse a valid updater-owned checkout
  for the target tag and ensure submodules are ready. Recreate only an incomplete
  checkout that cannot be repaired; do not delete unrelated user files.
- [ ] **Keep completed Skia work.** Reuse a validated archive matching the
  required release and asset. Initially restart incomplete downloads; HTTP range
  resuming can be considered later. Extract into a temporary directory and
  publish it only after successful completion.
- [ ] **Reuse compatible build output.** Reconfigure and rerun Ninja using the
  existing build directory when inputs remain compatible. Let Ninja determine
  which outputs need rebuilding; discard only incompatible or unusable build
  output instead of restarting the entire pipeline.
- [ ] **Protect the last working installation.** Stage and validate a replacement
  separately before a recoverable activation step. Current deployment installs
  directly into `installed/`; saving the release tag last does not prevent an
  interrupted install from leaving partially updated files. This protection is
  future work, not a guarantee of the current implementation.
- [ ] **Coordinate processes and recovery UI.** Stop build processes cleanly
  during normal shutdown and prevent concurrent or leftover processes from
  writing to the same workspace during recovery. On reopening, offer to continue
  the recorded target or explicitly start over. Keep installed-release identity
  separate from an unfinished build attempt.

## References

- [Riverpod: focused subscriptions with select](https://riverpod.dev/docs/how_to/select)
- [Git: clone progress reporting](https://git-scm.com/docs/git-clone)
- [Ninja: progress status placeholders](https://ninja-build.org/manual.html#_environment_variables)
- [Windows Installer: example of installer-specific progress messages](https://learn.microsoft.com/en-us/windows/win32/msi/handling-progress-messages-using-msisetexternalui)

NES UI widget behavior above was checked against the installed nes_ui 0.32.0
source (nes_progress_bar.dart and nes_loading_indicator.dart). Recheck the API
if the package version changes.
