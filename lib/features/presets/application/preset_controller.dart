import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:transcoder/core/database/collections/custom_preset.dart';
import 'package:transcoder/core/database/providers/application_isar_provider.dart';
import 'package:transcoder/features/presets/domain/preset_codec.dart';
import 'package:transcoder/features/video/application/video_settings_controller.dart';
import 'package:transcoder/features/video/domain/video_settings_state.dart';

part 'preset_controller.g.dart';

/// State that holds both built-in and custom presets.
class PresetListState {
  const PresetListState({
    this.builtIn = const [],
    this.custom = const [],
    this.isLoading = false,
  });

  final List<Preset> builtIn;
  final List<Preset> custom;
  final bool isLoading;

  PresetListState copyWith({
    List<Preset>? builtIn,
    List<Preset>? custom,
    bool? isLoading,
  }) {
    return PresetListState(
      builtIn: builtIn ?? this.builtIn,
      custom: custom ?? this.custom,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

@Riverpod(keepAlive: true)
class PresetController extends _$PresetController {
  @override
  PresetListState build() {
    _init();
    return const PresetListState(isLoading: true);
  }

  Future<void> _init() async {
    final builtIn = await _loadBuiltIn();
    final custom = await _loadCustom();
    state = PresetListState(builtIn: builtIn, custom: custom);
  }

  // -----------------------------------------------------------------------
  // Load built-in presets from the bundled JSON asset.
  // -----------------------------------------------------------------------

  Future<List<Preset>> _loadBuiltIn() async {
    try {
      final raw = await rootBundle.loadString('assets/built_in_presets.json');
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final categories = json['categories'] as List<dynamic>;
      final result = <Preset>[];

      for (final cat in categories) {
        final catMap = cat as Map<String, dynamic>;
        final catName = catMap['name'] as String;
        final presets = catMap['presets'] as List<dynamic>;

        for (final p in presets) {
          final pMap = p as Map<String, dynamic>;
          result.add(Preset(
            name: pMap['name'] as String,
            category: catName,
            settings:
                PresetCodec.decode(pMap['settings'] as Map<String, dynamic>),
            isBuiltIn: true,
          ));
        }
      }
      return result;
    } catch (_) {
      return [];
    }
  }

  // -----------------------------------------------------------------------
  // Load custom presets from Isar.
  // -----------------------------------------------------------------------

  Future<List<Preset>> _loadCustom() async {
    try {
      final repos = await ref.read(databaseRepositoriesProvider.future);
      final dbPresets = await repos.customPresets.getAllOrderedByName();
      return dbPresets.map((cp) {
        return Preset(
          name: cp.name,
          category: 'Custom',
          settings: PresetCodec.decodeFromJson(cp.presetJson),
          dbId: cp.id,
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  // -----------------------------------------------------------------------
  // Apply a preset → push its settings into the VideoSettingsController.
  // -----------------------------------------------------------------------

  void applyPreset(Preset preset) {
    final ctrl = ref.read(videoSettingsControllerProvider.notifier);
    _applySettingsToController(ctrl, preset.settings);
  }

  void _applySettingsToController(
      VideoSettingsController ctrl, VideoSettingsState s) {
    ctrl.setContainer(s.container);
    ctrl.setEncoder(s.encoder);
    ctrl.setPreset(s.preset);
    ctrl.setTune(s.tune);
    ctrl.setProfile(s.profile);
    ctrl.setLevel(s.level);
    ctrl.setQualityMode(s.qualityMode);
    ctrl.setCrf(s.crf);
    ctrl.setAverageBitrate(s.averageBitrate);
    ctrl.setFrameRate(s.frameRate);
    ctrl.setWidth(s.width);
    ctrl.setHeight(s.height);
    ctrl.setAutoCrop(s.autoCrop);
    ctrl.setCropTop(s.cropTop);
    ctrl.setCropBottom(s.cropBottom);
    ctrl.setCropLeft(s.cropLeft);
    ctrl.setCropRight(s.cropRight);
    ctrl.setDeinterlace(s.deinterlace);
    ctrl.setDenoise(s.denoise);
    ctrl.setSharpen(s.sharpen);
    ctrl.setGrayscale(s.grayscale);
    ctrl.setRotation(s.rotation);
  }

  // -----------------------------------------------------------------------
  // Save current settings as a custom preset.
  // -----------------------------------------------------------------------

  Future<void> saveCustom(String name) async {
    final videoState = ref.read(videoSettingsControllerProvider);
    final json = PresetCodec.encodeToJson(videoState);

    final repos = await ref.read(databaseRepositoriesProvider.future);
    final cp = CustomPreset()
      ..name = name
      ..presetJson = json
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();
    await repos.customPresets.put(cp);

    // Refresh custom list.
    state = state.copyWith(custom: await _loadCustom());
  }

  // -----------------------------------------------------------------------
  // Update an existing custom preset with current settings.
  // -----------------------------------------------------------------------

  Future<void> updateCustom(int dbId, String name) async {
    final videoState = ref.read(videoSettingsControllerProvider);
    final json = PresetCodec.encodeToJson(videoState);

    final repos = await ref.read(databaseRepositoriesProvider.future);
    final existing = await repos.customPresets.get(dbId);
    if (existing == null) return;

    existing
      ..name = name
      ..presetJson = json
      ..updatedAt = DateTime.now();
    await repos.customPresets.put(existing);

    state = state.copyWith(custom: await _loadCustom());
  }

  // -----------------------------------------------------------------------
  // Delete a custom preset.
  // -----------------------------------------------------------------------

  Future<void> deleteCustom(int dbId) async {
    final repos = await ref.read(databaseRepositoriesProvider.future);
    await repos.customPresets.delete(dbId);
    state = state.copyWith(custom: await _loadCustom());
  }

  /// Force refresh both built-in and custom lists.
  Future<void> refresh() async {
    state = state.copyWith(isLoading: true);
    final builtIn = await _loadBuiltIn();
    final custom = await _loadCustom();
    state = PresetListState(builtIn: builtIn, custom: custom);
  }
}
