import "package:flutter/material.dart";
import "package:window_manager/window_manager.dart";

import "package:flutter_hooks/flutter_hooks.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

import "package:aseprite_updater/l10n/app_localizations.dart";
import "package:aseprite_updater/core/router.dart" as app_router;
import "package:aseprite_updater/core/theme/theme.dart";

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

class AsepriteUpdater extends HookWidget {
  final ThemeData? theme;

  const AsepriteUpdater({this.theme, super.key});

  @override
  Widget build(BuildContext context) {
    final router = useMemoized(app_router.Router.new);

    return MaterialApp.router(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      title: "Flutter Demo",
      debugShowCheckedModeBanner: false,
      theme: theme ?? updaterTheme(),
      routerConfig: router.config(),
    );
  }
}
