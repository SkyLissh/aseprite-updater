import "package:flutter/material.dart";
import "package:flutter/rendering.dart";
import "package:nes_ui/nes_ui.dart";

import "package:google_fonts/google_fonts.dart";
import "package:flutter_hooks/flutter_hooks.dart";

import "package:aseprite_updater/features/build/build.dart";
import "package:aseprite_updater/core/theme/theme.dart";

class BuildLogs extends HookWidget {
  final BuildStatus status;
  final List<String> output;

  const BuildLogs({required this.status, required this.output, super.key});

  @override
  Widget build(BuildContext context) {
    final scrollController = useScrollController();
    final followOutput = useRef(true);

    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);

    useEffect(() {
      if (status == BuildStatus.running) {
        followOutput.value = true;
      }

      return null;
    }, [status]);

    useEffect(() {
      var cancelled = false;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (cancelled || !followOutput.value || !scrollController.hasClients) {
          return;
        }

        scrollController.jumpTo(scrollController.position.maxScrollExtent);
      });

      return () {
        cancelled = true;
      };
    }, [output.length, status, scrollController]);

    return NesContainer(
      label: "Building",
      width: size.width * 0.4 + 80,
      height: 240,
      child: NotificationListener<UserScrollNotification>(
        onNotification: (notification) {
          if (notification.depth != 0) return false;

          if (notification.direction == ScrollDirection.forward) {
            followOutput.value = false;
          } else {
            followOutput.value = notification.metrics.extentAfter <= 24;
          }

          return false;
        },
        child: NesSingleChildScrollView(
          scrollController: scrollController,
          child: Padding(
            padding: .all(theme.spacing.md),
            child: Text(
              output.join("\n"),
              style: GoogleFonts.pixelifySans(
                textStyle: theme.textTheme.bodyMedium,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                height: 1.4,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
