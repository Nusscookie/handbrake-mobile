import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:transcoder/core/database/collections/app_settings.dart';
import 'package:transcoder/core/database/collections/custom_preset.dart';
import 'package:transcoder/core/database/collections/transcode_job.dart';
import 'package:transcoder/core/database/collections/video_metadata.dart';
import 'package:transcoder/core/database/constants.dart';
import 'package:transcoder/core/database/repositories/database_repositories.dart';

part 'application_isar_provider.g.dart';

/// Single long-lived Isar instance for the app.
@Riverpod(keepAlive: true)
Future<Isar> applicationIsar(ApplicationIsarRef ref) async {
  final dir = await getApplicationDocumentsDirectory();
  return Isar.open(
    [
      TranscodeJobSchema,
      CustomPresetSchema,
      VideoMetadataSchema,
      AppSettingsSchema,
    ],
    directory: dir.path,
    name: kIsarInstanceName,
  );
}

/// Repositories built on top of [applicationIsarProvider].
@Riverpod(keepAlive: true)
Future<DatabaseRepositories> databaseRepositories(
  DatabaseRepositoriesRef ref,
) async {
  final isar = await ref.watch(applicationIsarProvider.future);
  return DatabaseRepositories(isar);
}
