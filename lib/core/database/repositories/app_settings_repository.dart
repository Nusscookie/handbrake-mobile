import 'package:isar/isar.dart';
import 'package:transcoder/core/database/collections/app_settings.dart';
import 'package:transcoder/core/database/constants.dart';
import 'package:transcoder/core/database/enums/app_theme_preference.dart';

class AppSettingsRepository {
  AppSettingsRepository(this._isar);

  final Isar _isar;

  IsarCollection<AppSettings> get _col => _isar.appSettings;

  Future<AppSettings?> getSingleton() => _col.get(kAppSettingsId);

  Future<AppSettings> getOrCreateSingleton() async {
    final existing = await _col.get(kAppSettingsId);
    if (existing != null) return existing;

    final created = AppSettings()
      ..id = kAppSettingsId
      ..themePreference = AppThemePreference.system
      ..queueNotificationsEnabled = true;

    await _isar.writeTxn(() async => _col.put(created));
    return (await _col.get(kAppSettingsId))!;
  }

  Future<int> put(AppSettings settings) =>
      _isar.writeTxn(() async => _col.put(settings));
}
