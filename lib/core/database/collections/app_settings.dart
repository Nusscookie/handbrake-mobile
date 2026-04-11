import 'package:isar/isar.dart';
import 'package:transcoder/core/database/enums/app_theme_preference.dart';

part 'app_settings.g.dart';

/// Singleton-style app preferences (single row with [kAppSettingsId]).
@collection
class AppSettings {
  Id id = Isar.autoIncrement;

  @enumerated
  late AppThemePreference themePreference;

  String? defaultOutputDirectory;

  late bool queueNotificationsEnabled;
}
