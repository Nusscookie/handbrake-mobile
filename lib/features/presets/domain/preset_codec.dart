import 'dart:convert';

import 'package:transcoder/features/video/domain/video_enums.dart';
import 'package:transcoder/features/video/domain/video_settings_state.dart';

/// A named preset that can be applied to the Video settings tab.
class Preset {
  const Preset({
    required this.name,
    required this.category,
    required this.settings,
    this.isBuiltIn = false,
    this.dbId,
  });

  final String name;
  final String category;
  final VideoSettingsState settings;
  final bool isBuiltIn;

  /// Database ID for custom presets (null for built-in).
  final int? dbId;
}

/// Encodes / decodes [VideoSettingsState] to / from JSON maps.
abstract final class PresetCodec {
  // -----------------------------------------------------------------------
  // Encode
  // -----------------------------------------------------------------------

  static Map<String, dynamic> encode(VideoSettingsState s) {
    return {
      'container': s.container.name,
      'encoder': s.encoder.name,
      'preset': s.preset.name,
      'tune': s.tune.name,
      'profile': s.profile.name,
      'level': s.level.name,
      'qualityMode': s.qualityMode.name,
      'crf': s.crf,
      'averageBitrate': s.averageBitrate,
      'frameRate': s.frameRate.name,
      if (s.width != null) 'width': s.width,
      if (s.height != null) 'height': s.height,
      'autoCrop': s.autoCrop,
      'cropTop': s.cropTop,
      'cropBottom': s.cropBottom,
      'cropLeft': s.cropLeft,
      'cropRight': s.cropRight,
      'deinterlace': s.deinterlace.name,
      'denoise': s.denoise.name,
      'sharpen': s.sharpen.name,
      'grayscale': s.grayscale,
      'rotation': s.rotation.name,
    };
  }

  static String encodeToJson(VideoSettingsState s) => jsonEncode(encode(s));

  // -----------------------------------------------------------------------
  // Decode
  // -----------------------------------------------------------------------

  static VideoSettingsState decode(Map<String, dynamic> m) {
    return VideoSettingsState(
      container: _enumByName(OutputContainer.values, m['container']) ??
          OutputContainer.mp4,
      encoder:
          _enumByName(VideoEncoder.values, m['encoder']) ?? VideoEncoder.x264,
      preset:
          _enumByName(EncoderPreset.values, m['preset']) ?? EncoderPreset.medium,
      tune: _enumByName(EncoderTune.values, m['tune']) ?? EncoderTune.none,
      profile: _enumByName(EncoderProfile.values, m['profile']) ??
          EncoderProfile.auto,
      level:
          _enumByName(EncoderLevel.values, m['level']) ?? EncoderLevel.auto,
      qualityMode: _enumByName(QualityMode.values, m['qualityMode']) ??
          QualityMode.constantQuality,
      crf: m['crf'] as int? ?? 22,
      averageBitrate: m['averageBitrate'] as int? ?? 5000,
      frameRate: _enumByName(FrameRateOption.values, m['frameRate']) ??
          FrameRateOption.source,
      width: m['width'] as int?,
      height: m['height'] as int?,
      autoCrop: m['autoCrop'] as bool? ?? true,
      cropTop: m['cropTop'] as int? ?? 0,
      cropBottom: m['cropBottom'] as int? ?? 0,
      cropLeft: m['cropLeft'] as int? ?? 0,
      cropRight: m['cropRight'] as int? ?? 0,
      deinterlace: _enumByName(DeinterlaceMode.values, m['deinterlace']) ??
          DeinterlaceMode.off,
      denoise:
          _enumByName(DenoiseMode.values, m['denoise']) ?? DenoiseMode.off,
      sharpen:
          _enumByName(SharpenMode.values, m['sharpen']) ?? SharpenMode.off,
      grayscale: m['grayscale'] as bool? ?? false,
      rotation: _enumByName(RotationOption.values, m['rotation']) ??
          RotationOption.none,
    );
  }

  static VideoSettingsState decodeFromJson(String json) =>
      decode(jsonDecode(json) as Map<String, dynamic>);

  // -----------------------------------------------------------------------
  // Helpers
  // -----------------------------------------------------------------------

  static T? _enumByName<T extends Enum>(List<T> values, dynamic name) {
    if (name is! String) return null;
    for (final v in values) {
      if (v.name == name) return v;
    }
    return null;
  }
}
