import 'package:isar/isar.dart';

part 'video_metadata.g.dart';

/// Cached FFprobe result for a given source path (Step 3 writes [probeJson]).
@collection
class VideoMetadata {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String sourcePath;

  @Index()
  late DateTime probedAt;

  /// Structured or raw JSON: duration, resolution, frame rate, streams, etc.
  late String probeJson;
}
