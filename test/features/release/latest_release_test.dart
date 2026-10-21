import "package:flutter_test/flutter_test.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

import "package:aseprite_updater/features/release/providers/providers.dart";

import "support/controlled_repo.dart";
import "support/release_fixture.dart";

void main() {
  late ControlledRepo repo;
  late ProviderContainer container;

  setUp(() {
    repo = ControlledRepo();
    container = ProviderContainer(
      retry: (_, _) => null,
      overrides: [repoProvider.overrideWithValue(repo)],
    );
    container.listen(latestReleaseProvider, (_, _) {});
  });
  tearDown(() => container.dispose());

  test("publishes loading then data and shares one request between consumers", () async {
    expect(container.read(latestReleaseProvider).isLoading, isTrue);
    container.listen(latestReleaseProvider, (_, _) {});
    expect(repo.calls, 1);

    final release = releaseFixture();
    repo.result.complete(release);

    expect(await container.read(latestReleaseProvider.future), release);
    expect(container.read(latestReleaseProvider).requireValue, release);
    expect(repo.calls, 1);
  });

  test("publishes the service error without retrying", () async {
    final error = StateError("offline");
    final future = container.read(latestReleaseProvider.future);
    final assertion = expectLater(future, throwsA(same(error)));
    repo.result.completeError(error);
    await assertion;

    expect(container.read(latestReleaseProvider).error, same(error));
    expect(repo.calls, 1);
  });
}
