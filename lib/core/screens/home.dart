import "package:flutter/material.dart";

import "package:auto_route/auto_route.dart";
import "package:flutter_hooks/flutter_hooks.dart";
import "package:hooks_riverpod/hooks_riverpod.dart";

import "package:aseprite_updater/features/build/build.dart";
import "package:aseprite_updater/features/release/release.dart";
import "package:aseprite_updater/features/window/window.dart";

enum Section { build, release }

@RoutePage(name: "HomeRoute")
class Home extends HookWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final section = useState(Section.release);

    return WindowShell(
      child: Scaffold(
        body: SizedBox(
          width: double.infinity,
          child: switch (section.value) {
            .build => Consumer(
              builder: (context, ref, _) {
                final status = ref.watch(buildControllerProvider.select((state) => state.status));
                final phase = ref.watch(buildControllerProvider.select((state) => state.phase));

                return BuildProgress(status: status, phase: phase);
              },
            ),
            .release => Consumer(
              builder: (context, ref, _) => ReleaseOverview(
                onUpdate: (tag) {
                  section.value = .build;
                  ref.read(buildControllerProvider.notifier).run(tag: tag);
                },
              ),
            ),
          },
        ),
      ),
    );
  }
}
