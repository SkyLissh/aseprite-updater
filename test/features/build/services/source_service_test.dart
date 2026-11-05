import "dart:io";

import "package:flutter_test/flutter_test.dart";

import "package:aseprite_updater/features/build/services/source_service.dart";

void main() {
  late Directory temporary;
  late Directory remote;
  late Directory checkout;

  Future<String> git(Directory directory, List<String> arguments) async {
    final result = await Process.run("git", arguments, workingDirectory: directory.path);
    if (result.exitCode != 0) {
      throw ProcessException("git", arguments, result.stderr.toString(), result.exitCode);
    }
    return result.stdout.toString().trim();
  }

  setUp(() async {
    temporary = await Directory.systemTemp.createTemp("updater-source-");
    remote = await Directory("${temporary.path}/remote").create();
    checkout = Directory("${temporary.path}/checkout");
    await git(remote, ["init"]);
    await git(remote, ["config", "user.name", "Source test"]);
    await git(remote, ["config", "user.email", "source@example.invalid"]);
    await File("${remote.path}/source.txt").writeAsString("first");
    await git(remote, ["add", "."]);
    await git(remote, ["commit", "-m", "First release"]);
    await git(remote, ["tag", "v1"]);
    await git(temporary, ["clone", "--branch", "v1", remote.path, checkout.path]);
    await File("${remote.path}/source.txt").writeAsString("second");
    await git(remote, ["commit", "-am", "Second release"]);
    await git(remote, ["tag", "v2"]);
  });

  tearDown(() async => temporary.delete(recursive: true));

  test("reads and trims the required Skia tag from the checkout", () async {
    final file = File.fromUri(checkout.uri.resolve("laf/misc/skia-tag.txt"));
    await file.parent.create(recursive: true);
    await file.writeAsString(" m124-08a5439a6b\n");

    expect(await SourceService(checkout).requiredSkia(), "m124-08a5439a6b");
  });

  test("rejects a missing required Skia tag file", () async {
    await expectLater(SourceService(checkout).requiredSkia(), throwsStateError);
  });

  for (final content in ["", " \n\t"]) {
    test("rejects an empty or whitespace-only required Skia tag: ${content.isEmpty}", () async {
      final file = File.fromUri(checkout.uri.resolve("laf/misc/skia-tag.txt"));
      await file.parent.create(recursive: true);
      await file.writeAsString(content);

      await expectLater(SourceService(checkout).requiredSkia(), throwsStateError);
    });
  }

  test("update fetches a new tag and switches the existing checkout to it", () async {
    final marker = await File("${checkout.path}/keep.txt").writeAsString("keep");

    await SourceService(checkout).update(tag: "v2");

    expect(await File("${checkout.path}/source.txt").readAsString(), "second");
    expect(await git(checkout, ["rev-parse", "HEAD"]), await git(remote, ["rev-parse", "v2"]));
    expect(await git(checkout, ["rev-parse", "--abbrev-ref", "HEAD"]), "HEAD");
    expect(await marker.readAsString(), "keep");
  });

  test("update rejects blank tags and missing or invalid checkouts", () async {
    await expectLater(SourceService(checkout).update(tag: " "), throwsArgumentError);
    await expectLater(
      SourceService(Directory("${temporary.path}/missing")).update(tag: "v2"),
      throwsStateError,
    );
    await expectLater(SourceService(temporary).update(tag: "v2"), throwsStateError);
  });

  test("a failed fetch leaves the current source untouched", () async {
    await git(checkout, ["remote", "set-url", "origin", "${temporary.path}/missing"]);

    await expectLater(SourceService(checkout).update(tag: "v2"), throwsA(isA<ProcessException>()));

    expect(await File("${checkout.path}/source.txt").readAsString(), "first");
  });

  test("an unknown tag fails without switching the current source", () async {
    await expectLater(
      SourceService(checkout).update(tag: "missing"),
      throwsA(isA<ProcessException>()),
    );

    expect(await File("${checkout.path}/source.txt").readAsString(), "first");
  });

  test("update checks out the submodule commit recorded by the selected tag", () async {
    final dependency = await Directory("${temporary.path}/dependency").create();
    await git(dependency, ["init"]);
    await git(dependency, ["config", "user.name", "Source test"]);
    await git(dependency, ["config", "user.email", "source@example.invalid"]);
    await File("${dependency.path}/dependency.txt").writeAsString("first");
    await git(dependency, ["add", "."]);
    await git(dependency, ["commit", "-m", "First dependency"]);
    await git(remote, [
      "-c",
      "protocol.file.allow=always",
      "submodule",
      "add",
      dependency.path,
      "dep",
    ]);
    await git(remote, ["commit", "-am", "Add dependency"]);
    await git(remote, ["tag", "v3"]);
    await git(checkout, ["fetch", "origin", "--tags"]);
    await git(checkout, ["checkout", "--detach", "v3"]);
    await git(checkout, ["-c", "protocol.file.allow=always", "submodule", "update", "--init"]);

    await File("${dependency.path}/dependency.txt").writeAsString("second");
    await git(dependency, ["commit", "-am", "Second dependency"]);
    final commit = await git(dependency, ["rev-parse", "HEAD"]);
    await git(Directory("${remote.path}/dep"), ["fetch", "origin"]);
    await git(Directory("${remote.path}/dep"), ["checkout", "--detach", commit]);
    await git(remote, ["commit", "-am", "Update dependency"]);
    await git(remote, ["tag", "v4"]);
    await git(Directory("${checkout.path}/dep"), ["config", "protocol.file.allow", "always"]);

    await SourceService(checkout).update(tag: "v4");

    expect(await File("${checkout.path}/dep/dependency.txt").readAsString(), "second");
    expect(await git(Directory("${checkout.path}/dep"), ["rev-parse", "HEAD"]), commit);
  });
}
