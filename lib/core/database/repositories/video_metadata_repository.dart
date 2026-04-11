import 'package:isar/isar.dart';
import 'package:transcoder/core/database/collections/video_metadata.dart';

class VideoMetadataRepository {
  VideoMetadataRepository(this._isar);

  final Isar _isar;

  IsarCollection<VideoMetadata> get _col => _isar.videoMetadatas;

  Future<VideoMetadata?> getBySourcePath(String sourcePath) => _col
      .where()
      .sourcePathEqualTo(sourcePath)
      .findFirst();

  Future<int> put(VideoMetadata metadata) =>
      _isar.writeTxn(() async => _col.put(metadata));

  /// Insert or replace the row for [metadata.sourcePath] (unique index).
  Future<int> upsertBySourcePath(VideoMetadata metadata) async {
    return _isar.writeTxn(() async {
      final existing = await _col
          .where()
          .sourcePathEqualTo(metadata.sourcePath)
          .findFirst();
      if (existing != null) {
        metadata.id = existing.id;
      }
      return _col.put(metadata);
    });
  }

  Future<bool> delete(int id) => _isar.writeTxn(() => _col.delete(id));

  Future<void> deleteBySourcePath(String sourcePath) async {
    await _isar.writeTxn(() async {
      final existing = await _col
          .where()
          .sourcePathEqualTo(sourcePath)
          .findFirst();
      if (existing != null) {
        await _col.delete(existing.id);
      }
    });
  }
}
