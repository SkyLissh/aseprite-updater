import "dart:async";

import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

import "package:aseprite_updater/features/release/providers/providers.dart";
import "package:aseprite_updater/features/release/models/models.dart";

import "support/controlled_repo.dart";
import "support/release_fixture.dart";

void main() {
  late ControlledRepo repo;
  late ProviderContainer container;

  setUp(() {
    repo = ControlledRepo();
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [releaseServiceProvider.overrideWithValue(repo)],
    );
    container.listen(releasesProvider, (_, _) {});
  });
  tearDown(() => container.dispose());

  test("publishes loading then data and shares one request between consumers", () async {
    expect(container.read(releasesProvider).isLoading, isTrue);
    container.listen(releasesProvider, (_, _) {});
    expect(repo.calls, 1);

    final release = releaseFixture();
    repo.result.complete(release);

    expect(
      await container.read(releasesProvider.future),
      ReleaseState(latest: release, current: "v1.2.0"),
    );
    expect(
      container.read(releasesProvider).requireValue,
      ReleaseState(latest: release, current: "v1.2.0"),
    );
    expect(repo.calls, 1);
  });

  test("checking the same tag preserves the installed release state", () async {
    repo.result.complete(releaseFixture());
    final before = await container.read(releasesProvider.future);

    await container.read(releasesProvider.notifier).searchUpdates();

    expect(container.read(releasesProvider).requireValue, same(before));
    expect(repo.calls, 2);
  });

  test("a newer tag updates the latest release and preserves the installed tag", () async {
    repo.result.complete(releaseFixture());
    final before = await container.read(releasesProvider.future);
    final latest = releaseFixture().copyWith(tagName: "v1.4.0");
    repo.result = Completer<Release>();

    final check = container.read(releasesProvider.notifier).searchUpdates();

    expect(container.read(releasesProvider).requireValue, same(before));

    repo.result.complete(latest);
    await check;

    expect(
      container.read(releasesProvider).requireValue,
      ReleaseState(latest: latest, current: "v1.2.0"),
    );
    expect(repo.calls, 2);
  });

  test("invalidation reloads the latest and installed releases", () async {
    repo.result.complete(releaseFixture());
    await container.read(releasesProvider.future);
    final notifier = container.read(releasesProvider.notifier);
    final latest = releaseFixture().copyWith(tagName: "v1.4.0");
    repo.result = Completer<Release>();
    repo.current = "v1.3.0";

    container.invalidate(releasesProvider);
    final reloaded = container.read(releasesProvider.future);
    repo.result.complete(latest);

    expect(await reloaded, ReleaseState(latest: latest, current: "v1.3.0"));
    expect(container.read(releasesProvider.notifier), same(notifier));
    expect(repo.calls, 2);
  });

  test("a failed update check propagates and preserves the loaded state", () async {
    repo.result.complete(releaseFixture());
    final before = await container.read(releasesProvider.future);
    repo.result = Completer<Release>();
    final error = StateError("offline");
    final check = container.read(releasesProvider.notifier).searchUpdates();
    final assertion = expectLater(check, throwsA(same(error)));
    repo.result.completeError(error);
    await assertion;

    expect(container.read(releasesProvider).requireValue, same(before));
    expect(repo.calls, 2);
  });

  test("publishes the service error without retrying", () async {
    final error = StateError("offline");
    final future = container.read(releasesProvider.future);
    final assertion = expectLater(future, throwsA(same(error)));
    repo.result.completeError(error);
    await assertion;

    expect(container.read(releasesProvider).error, same(error));
    expect(repo.calls, 1);
  });

  test("invalidation can recover from an initial service error", () async {
    final initial = container.read(releasesProvider.future);
    final error = StateError("offline");
    final assertion = expectLater(initial, throwsA(same(error)));
    repo.result.completeError(error);
    await assertion;

    repo.result = Completer<Release>();
    container.invalidate(releasesProvider);
    final retried = container.read(releasesProvider.future);
    final release = releaseFixture();
    repo.result.complete(release);

    expect(await retried, ReleaseState(latest: release, current: "v1.2.0"));
    expect(container.read(releasesProvider).hasError, isFalse);
    expect(repo.calls, 2);
  });
}
