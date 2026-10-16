import "package:aseprite_updater/l10n/app_localizations.dart";
import "package:flutter/material.dart";

extension Localization on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
