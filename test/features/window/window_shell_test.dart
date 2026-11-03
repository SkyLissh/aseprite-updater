import "package:flutter/material.dart";
import "package:nes_ui/nes_ui.dart";

import "package:flutter_hooks/flutter_hooks.dart";
import "package:flutter_test/flutter_test.dart";
import "package:window_manager/window_manager.dart";

import "package:aseprite_updater/core/theme/theme.dart";
import "package:aseprite_updater/features/window/widgets/widgets.dart";

import "support/window_manager_fake.dart";
import "support/window_test_app.dart";

void main() {
  testWidgets("keeps its container and changes padding and border with maximized state", (
    tester,
  ) async {
    final native = WindowManagerFake()..install();
    addTearDown(native.uninstall);
    await tester.pumpWidget(windowTestApp(const WindowShell(child: Text("Window content"))));
    await tester.pump();

    expect(find.text("Window content"), findsOneWidget);
    expect(find.byType(NesContainer), findsOneWidget);
    final theme = Theme.of(tester.element(find.byType(WindowShell)));
    var shell = tester.widget<NesContainer>(find.byType(NesContainer));
    expect(shell.padding, EdgeInsets.all(theme.spacing.sm));
    expect(shell.borderColor, theme.palette.darkIconPrimary);

    native.emit("maximize");
    await tester.pump();
    expect(find.text("Window content"), findsOneWidget);
    expect(find.byType(NesContainer), findsOneWidget);
    shell = tester.widget<NesContainer>(find.byType(NesContainer));
    expect(shell.padding, EdgeInsets.zero);
    expect(shell.borderColor, Colors.transparent);

    native.emit("unmaximize");
    await tester.pump();
    expect(find.text("Window content"), findsOneWidget);
    expect(find.byType(NesContainer), findsOneWidget);
    shell = tester.widget<NesContainer>(find.byType(NesContainer));
    expect(shell.padding, EdgeInsets.all(theme.spacing.sm));
    expect(shell.borderColor, theme.palette.darkIconPrimary);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets("owns one window listener and forwards caption button actions", (tester) async {
    final native = WindowManagerFake()..install();
    final listenersBefore = windowManager.listeners.length;
    addTearDown(native.uninstall);
    await tester.pumpWidget(windowTestApp(const WindowShell(child: Text("Window content"))));
    await tester.pump();

    expect(windowManager.listeners.length, listenersBefore + 1);
    expect(find.byType(WindowButtons), findsOneWidget);
    expect(find.byType(DragToMoveArea), findsOneWidget);

    for (final (icon, expected) in [
      (NesIcons.remove, ["minimize"]),
      (NesIcons.add, ["isMaximized", "maximize"]),
      (NesIcons.add, ["isMaximized", "unmaximize"]),
      (NesIcons.close, ["close"]),
    ]) {
      native.calls.clear();
      await tester.tap(
        find.byWidgetPredicate((widget) => widget is NesIconButton && widget.icon == icon),
      );
      await tester.pump();

      expect(native.calls.map((call) => call.method), expected);
    }

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(windowManager.listeners.length, listenersBefore);
  });

  testWidgets("preserves child state and its element across maximize and restore", (tester) async {
    final native = WindowManagerFake()..install();
    addTearDown(native.uninstall);
    final child = HookBuilder(
      builder: (_) {
        final count = useState(0);

        return TextButton(onPressed: () => count.value++, child: Text("Count: ${count.value}"));
      },
    );
    await tester.pumpWidget(windowTestApp(WindowShell(child: child)));
    await tester.pump();
    await tester.tap(find.text("Count: 0"));
    await tester.pump();
    final element = tester.element(find.byWidget(child));

    for (final event in ["maximize", "unmaximize"]) {
      native.emit(event);
      await tester.pump();

      expect(find.text("Count: 1"), findsOneWidget);
      expect(tester.element(find.byWidget(child)), same(element));
    }

    await tester.tap(find.text("Count: 1"));
    await tester.pump();
    expect(find.text("Count: 2"), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });

  testWidgets("initial maximized state keeps the container with no visible border or inset", (
    tester,
  ) async {
    final native = WindowManagerFake()..isMaximized = true;
    native.install();
    addTearDown(native.uninstall);
    await tester.pumpWidget(windowTestApp(const WindowShell(child: Text("Window content"))));
    await tester.pump();

    final shell = tester.widget<NesContainer>(find.byType(NesContainer));
    expect(shell.padding, EdgeInsets.zero);
    expect(shell.borderColor, Colors.transparent);
    expect(find.text("Window content"), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
