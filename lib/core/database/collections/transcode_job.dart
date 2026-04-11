import 'package:isar/isar.dart';
import 'package:transcoder/core/database/enums/transcode_job_status.dart';

part 'transcode_job.g.dart';

/// One queued or finished transcode (HandBrake-style job).
@collection
class TranscodeJob {
  Id id = Isar.autoIncrement;

  /// Absolute path to the source media file.
  late String inputPath;

  /// Planned or final output path (set when encoding starts or completes).
  String? outputPath;

  @enumerated
  late TranscodeJobStatus status;

  @Index()
  late DateTime createdAt;

  DateTime? completedAt;

  String? errorMessage;

  /// Optional UI label (e.g. basename of [inputPath]).
  String? displayName;

  /// Full encode configuration snapshot as JSON for the FFmpeg command builder.
  late String encodeOptionsJson;
}
