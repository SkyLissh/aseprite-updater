import "package:flutter/material.dart";
import "package:nes_ui/nes_ui.dart";

import "package:url_launcher/url_launcher.dart";
import "package:flutter_markdown_plus/flutter_markdown_plus.dart";

import "package:aseprite_updater/core/extensions/extensions.dart";
import "package:aseprite_updater/core/theme/theme.dart";

class ReleaseModal extends StatelessWidget {
  final String tagName;
  final String body;

  const ReleaseModal({required this.tagName, required this.body, super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    final palette = theme.palette;
    final spacing = theme.spacing;

    return NesDialog(
      child: SizedBox(
        width: size.width * 0.4 + 80,
        height: size.height * 0.8,
        child: Column(
          children: [
            Column(
              mainAxisAlignment: .center,
              children: [
                Text(l10n.aseprite, style: theme.textTheme.headlineLarge),
                SizedBox(height: spacing.sm),
                NesContainer(
                  backgroundColor: palette.error,
                  borderColor: palette.error,
                  padding: .symmetric(horizontal: spacing.sm, vertical: spacing.xs),
                  child: Text(tagName, style: TextStyle(color: palette.lightLabel, fontSize: 10)),
                ),
              ],
            ),
            SizedBox(height: spacing.lg),
            Expanded(
              child: NesSingleChildScrollView(
                child: Padding(
                  padding: .all(spacing.lg),
                  child: MarkdownBody(
                    data: body,
                    onTapLink: (text, href, title) {
                      if (href == null) return;
                      final uri = Uri.tryParse(href);
                      if (uri == null || !uri.hasScheme) return;
                      const allowed = {"http", "https"};
                      if (!allowed.contains(uri.scheme.toLowerCase())) return;
                      try {
                        launchUrl(uri, mode: .externalApplication);
                      } on Exception {
                        // No handler for this URL on this OS — fail silently.
                      }
                    },
                    styleSheet: MarkdownStyleSheet(textScaler: const TextScaler.linear(0.85)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
