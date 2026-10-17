import "package:flutter/material.dart";
import "package:nes_ui/nes_ui.dart";
import "package:window_manager/window_manager.dart";

import "package:flutter_hooks/flutter_hooks.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

import "package:aseprite_updater/l10n/app_localizations.dart";
import "package:aseprite_updater/core/extensions/extensions.dart";
import "package:aseprite_updater/core/theme/theme.dart";
import "package:aseprite_updater/features/release/widgets/widgets.dart";
import "package:aseprite_updater/features/window/window.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(960, 640),
    center: true,
    titleBarStyle: .hidden,
    title: "Aseprite Updater",
    windowButtonVisibility: false,
    backgroundColor: Colors.transparent,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const ProviderScope(child: AsepriteUpdater()));
}

class AsepriteUpdater extends StatelessWidget {
  const AsepriteUpdater({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      title: "Flutter Demo",
      debugShowCheckedModeBanner: false,
      theme: updaterTheme(),
      home: const Home(),
    );
  }
}

class Home extends HookWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final window = useWindow();
    final spacing = Theme.of(context).spacing;

    return WindowShell(
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kWindowCaptionHeight),
          child: Row(
            children: [
              const Expanded(
                child: DragToMoveArea(child: SizedBox(height: kWindowCaptionHeight)),
              ),
              WindowButtons(
                onMinimize: window.minimize,
                onMaximize: window.toggleMaximize,
                onClose: window.close,
              ),
            ],
          ),
        ),
        body: SizedBox(
          width: double.infinity,
          child: Column(
            mainAxisAlignment: .center,
            children: [
              NesIcon(iconData: NesIcons.download, size: const Size.square(64)),
              SizedBox(height: spacing.lg),
              const Text("Aseprite v4.2.0"),
              SizedBox(height: spacing.lg),
              Row(
                mainAxisAlignment: .center,
                children: [
                  NesButton.text(
                    type: .normal,
                    text: l10n.changelog,
                    onPressed: () =>
                        showDialog(context: context, builder: (_) => const ReleaseModal()),
                  ),
                  SizedBox(width: spacing.lg),
                  NesButton.text(type: .primary, text: l10n.update, onPressed: () {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
