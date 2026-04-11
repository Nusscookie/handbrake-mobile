import 'package:isar/isar.dart';
import 'package:transcoder/core/database/collections/transcode_job.dart';
import 'package:transcoder/core/database/enums/transcode_job_status.dart';

class TranscodeJobRepository {
  TranscodeJobRepository(this._isar);

  final Isar _isar;

  IsarCollection<TranscodeJob> get _col => _isar.transcodeJobs;

  Future<List<TranscodeJob>> getAllOrderedByCreated() =>
      _col.where().sortByCreatedAt().findAll();

  /// Jobs waiting or currently encoding (queue worker consumes in order).
  Future<List<TranscodeJob>> getPendingOrRunningOrdered() async {
    final pending = await _col
        .filter()
        .statusEqualTo(TranscodeJobStatus.pending)
        .sortByCreatedAt()
        .findAll();
    final running = await _col
        .filter()
        .statusEqualTo(TranscodeJobStatus.running)
        .sortByCreatedAt()
        .findAll();
    return [...pending, ...running];
  }

  Future<TranscodeJob?> get(int id) => _col.get(id);

  Future<int> put(TranscodeJob job) =>
      _isar.writeTxn(() async => _col.put(job));

  Future<bool> delete(int id) =>
      _isar.writeTxn(() async => _col.delete(id));

  Future<void> deleteAll() => _isar.writeTxn(() async {
        await _col.clear();
      });
}
