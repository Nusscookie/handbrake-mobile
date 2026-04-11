import 'package:isar/isar.dart';

part 'custom_preset.g.dart';

/// User-saved preset; built-in presets stay in assets JSON (Step 6).
@collection
class CustomPreset {
  Id id = Isar.autoIncrement;

  @Index()
  late String name;

  /// Serialized preset payload (video/audio/filters/container, etc.).
  late String presetJson;

  @Index()
  late DateTime updatedAt;

  late DateTime createdAt;
}
