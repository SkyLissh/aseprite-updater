import "package:flutter/material.dart";

import "package:flutter_hooks/flutter_hooks.dart";
import "package:flutter_test/flutter_test.dart";
import "package:window_manager/window_manager.dart";

import "package:aseprite_updater/features/window/hooks/hooks.dart";

import "support/window_manager_fake.dart";
import "support/window_test_app.dart";

void main() {
  late WindowManagerFake native;
  late WindowState state;

  setUp(() => native = WindowManagerFake()..install());
  tearDown(() => native.uninstall());

  Future<void> showHook(WidgetTester tester) async {
    await tester.pumpWidget(
      windowTestApp(
        HookBuilder(
          builder: (_) {
            state = useWindow();

            return const SizedBox.shrink();
          },
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets("reads initial maximized and minimized state from the plugin", (tester) async {
    native.isMaximized = true;
    native.isMinimized = true;
    await showHook(tester);

    expect(state.isMaximized, isTrue);
    expect(state.isMinimized, isTrue);
  });

  testWidgets("updates state from maximize, unmaximize and minimize events", (tester) async {
    await showHook(tester);
    expect(state.isMaximized, isFalse);
    expect(state.isMinimized, isFalse);

    native.emit("maximize");
    await tester.pump();
    expect(state.isMaximized, isTrue);

    native.emit("unmaximize");
    await tester.pump();
    expect(state.isMaximized, isFalse);

    native.emit("minimize");
    await tester.pump();
    expect(state.isMinimized, isTrue);
  });

  testWidgets("toggle maximizes or restores according to current native state", (tester) async {
    await showHook(tester);
    native.calls.clear();
    await state.toggleMaximize();
    expect(native.calls.map((call) => call.method), ["isMaximized", "maximize"]);

    native.calls.clear();
    await state.toggleMaximize();
    expect(native.calls.map((call) => call.method), ["isMaximized", "unmaximize"]);
  });

  testWidgets("forwards minimize, close, dragging and window menu actions", (tester) async {
    await showHook(tester);
    native.calls.clear();
    await state.minimize();
    await state.close();
    await state.startDrag();
    await state.showPopupMenu();

    expect(native.calls.map((call) => call.method), [
      "minimize",
      "close",
      "startDragging",
      "popUpWindowMenu",
    ]);
  });

  testWidgets("registers one listener and removes it on disposal", (tester) async {
    final before = windowManager.listeners.length;
    await showHook(tester);
    expect(windowManager.listeners.length, before + 1);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(windowManager.listeners.length, before);

    native.emit("maximize");
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}
