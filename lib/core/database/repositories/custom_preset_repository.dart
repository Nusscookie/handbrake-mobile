import 'package:isar/isar.dart';
import 'package:transcoder/core/database/collections/custom_preset.dart';

class CustomPresetRepository {
  CustomPresetRepository(this._isar);

  final Isar _isar;

  IsarCollection<CustomPreset> get _col => _isar.customPresets;

  Future<List<CustomPreset>> getAllOrderedByName() =>
      _col.where().sortByName().findAll();

  Future<List<CustomPreset>> getAllOrderedByUpdated() =>
      _col.where().sortByUpdatedAtDesc().findAll();

  Future<CustomPreset?> get(int id) => _col.get(id);

  Future<int> put(CustomPreset preset) =>
      _isar.writeTxn(() async => _col.put(preset));

  Future<bool> delete(int id) =>
      _isar.writeTxn(() async => _col.delete(id));
}
