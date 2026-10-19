import "dart:convert";
import "dart:io";

import "package:flutter_test/flutter_test.dart";

import "package:aseprite_updater/features/build/models/models.dart";
import "package:aseprite_updater/features/build/services/git_progress_parser.dart";

void main() {
  late GitProgressParser parser;

  setUp(() => parser = GitProgressParser());

  test("recognizes local receiving, resolving and checkout progress", () {
    for (final (line, operation, value) in [
      ("Receiving objects:  42% (42/100), 1 MiB | 2 MiB/s", BuildOperation.downloadingSource, .42),
      ("Resolving deltas: 100% (4/4), done.", BuildOperation.resolvingSource, 1.0),
      ("Updating files:  12% (12/100)", BuildOperation.checkingOutSource, .12),
      ("Checking out files:  25% (25/100)", BuildOperation.checkingOutSource, .25),
      ("Receiving objects: 0% (0/100)", BuildOperation.downloadingSource, 0.0),
      ("Updating files: 100%", BuildOperation.checkingOutSource, 1.0),
    ]) {
      final event = parser.parse(line, isStderr: true)!;
      expect(event.operation, operation);
      expect(event.value, value);
    }
  });

  test("ignores stdout and remote or unrelated diagnostics", () {
    for (final line in [
      "remote: Counting objects: 100% (1/1), done.",
      "remote: Compressing objects: 100% (1/1), done.",
      "remote: Receiving objects: 90% (9/10)",
      "warning: detached HEAD",
      "",
    ]) {
      expect(parser.parse(line, isStderr: true), isNull);
    }
    expect(parser.parse("Receiving objects: 50% (1/2)", isStderr: false), isNull);
    expect(parser.parse("Receiving objects: 50% (1/2)", isStderr: true)!.value, .5);
    expect(parser.parse("warning: diagnostic", isStderr: true), isNull);
    expect(parser.parse("Receiving objects: 60% (3/5)", isStderr: true)!.value, .6);
  });

  test("recognized operations with unusable percentages are indeterminate", () {
    for (final percentage in ["unknown", "-1%", "101%", "NaN%", "1.5%", "20oops%", ""]) {
      final event = parser.parse("Receiving objects: $percentage (1/2)", isStderr: true)!;
      expect(event.operation, BuildOperation.downloadingSource);
      expect(event.value, isNull, reason: percentage);
    }
  });

  test("registration makes all subsequent submodule progress indeterminate", () {
    parser.parse("Cloning into '/tmp/aseprite'...", isStderr: true);
    final registration = parser.parse(
      "Submodule 'foo' (https://example.com/foo) registered for path 'foo'",
      isStderr: true,
    )!;
    expect(registration.operation, BuildOperation.downloadingSubmodules);
    expect(registration.value, isNull);
    expect(parser.parse("warning: diagnostic", isStderr: true), isNull);
    for (final line in [
      "Cloning into '/tmp/aseprite/foo'...",
      "Receiving objects: 80% (4/5)",
      "Resolving deltas: 100% (5/5), done.",
      "Updating files: 100% (5/5), done.",
    ]) {
      final event = parser.parse(line, isStderr: true)!;
      expect(event.operation, BuildOperation.downloadingSubmodules);
      expect(event.value, isNull);
    }
  });

  test("a subsequent clone header detects submodules without registration", () {
    expect(parser.parse("Cloning into '/tmp/aseprite'...", isStderr: true), isNull);
    expect(
      parser.parse("Cloning into '/tmp/aseprite/foo'...", isStderr: true)!.operation,
      BuildOperation.downloadingSubmodules,
    );
    expect(GitProgressParser().parse("Receiving objects: 50% (1/2)", isStderr: true)!.value, .5);
  });

  test("UTF-8 and LineSplitter preserve fragmented carriage-return updates", () async {
    final bytes = utf8.encode(
      "Receiving objects: 10% (1/10)\rReceiving objects: 20% (2/10)\r\n"
      "remote: diagnostic café\nResolving deltas: 100% (2/2), done.",
    );
    final events = await Stream.fromIterable(bytes.map((byte) => [byte]))
        .transform(const Utf8Decoder(allowMalformed: true))
        .transform(const LineSplitter())
        .map((line) => parser.parse(line, isStderr: true))
        .where((event) => event != null)
        .toList();
    expect(events.map((event) => event!.value), [.1, .2, 1.0]);
  });

  test("replays progress excerpts captured from a real recursive Git clone", () async {
    // Local recursive SourceService clone; only temporary paths were normalized.
    final lines = await File("test/features/build/fixtures/git_clone.txt").readAsLines();
    final events = lines.map((line) => parser.parse(line, isStderr: true)).nonNulls.toList();
    expect(events.take(4).map((event) => event.value), [.01, .5, 1.0, 1.0]);
    expect(
      events.skip(4).take(4).map((event) => event.operation),
      everyElement(BuildOperation.resolvingSource),
    );
    expect(
      events.skip(8).map((event) => event.operation),
      everyElement(BuildOperation.downloadingSubmodules),
    );
    expect(events.skip(8).map((event) => event.value), everyElement(isNull));
  });
}
