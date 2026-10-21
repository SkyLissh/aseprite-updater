import "package:nes_ui/nes_ui.dart";

import "package:flutter_test/flutter_test.dart";

import "package:aseprite_updater/features/window/widgets/widgets.dart";

import "support/window_test_app.dart";

void main() {
  testWidgets("each window button invokes only its corresponding callback", (tester) async {
    final actions = <String>[];
    await tester.pumpWidget(
      windowTestApp(
        WindowButtons(
          onClose: () => actions.add("close"),
          onMaximize: () => actions.add("maximize"),
          onMinimize: () => actions.add("minimize"),
        ),
      ),
    );

    for (final (icon, action) in [
      (NesIcons.remove, "minimize"),
      (NesIcons.add, "maximize"),
      (NesIcons.close, "close"),
    ]) {
      actions.clear();
      await tester.tap(
        find.byWidgetPredicate((widget) => widget is NesIconButton && widget.icon == icon),
      );
      await tester.pump();

      expect(actions, [action]);
    }
  });
}
