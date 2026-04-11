import 'package:isar/isar.dart';
import 'package:transcoder/core/database/repositories/app_settings_repository.dart';
import 'package:transcoder/core/database/repositories/custom_preset_repository.dart';
import 'package:transcoder/core/database/repositories/transcode_job_repository.dart';
import 'package:transcoder/core/database/repositories/video_metadata_repository.dart';

/// Typed accessors for all local persistence (queue, presets, probe cache, settings).
class DatabaseRepositories {
  DatabaseRepositories(Isar isar)
      : transcodeJobs = TranscodeJobRepository(isar),
        customPresets = CustomPresetRepository(isar),
        videoMetadata = VideoMetadataRepository(isar),
        appSettings = AppSettingsRepository(isar);

  final TranscodeJobRepository transcodeJobs;
  final CustomPresetRepository customPresets;
  final VideoMetadataRepository videoMetadata;
  final AppSettingsRepository appSettings;
}
