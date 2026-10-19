// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_title => 'Aseprite Updater';

  @override
  String get aseprite => 'Aseprite';

  @override
  String get changelog => 'Changelog';

  @override
  String get update => 'Update';

  @override
  String released_on(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMMd(localeName);
    final String dateString = dateDateFormat.format(date);

    return 'Released $dateString';
  }

  @override
  String get pre_release => 'Pre-release';

  @override
  String get something_went_wrong => 'Something went wrong';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get build_idle => 'Ready to build';

  @override
  String get build_completed => 'Build completed';

  @override
  String get build_failed => 'Build failed';

  @override
  String get build_preparing_workspace => 'Preparing your workspace…';

  @override
  String get build_getting_source => 'Getting source code…';

  @override
  String get build_downloading_skia => 'Downloading Skia…';

  @override
  String get build_configuring => 'Preparing the build…';

  @override
  String get build_compiling => 'Building Aseprite…';

  @override
  String get build_deploying => 'Installing the build…';

  @override
  String get build_connecting_source => 'Connecting to the source repository…';

  @override
  String get build_downloading_source => 'Downloading source…';

  @override
  String get build_resolving_source => 'Preparing source…';

  @override
  String get build_checking_out_source => 'Writing source files…';

  @override
  String get build_downloading_submodules => 'Downloading source components…';
}
