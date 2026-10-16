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
}
