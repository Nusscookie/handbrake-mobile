import 'dart:convert';

import 'package:transcoder/features/audio/domain/audio_enums.dart';
import 'package:transcoder/features/audio/domain/audio_settings_state.dart';
import 'package:transcoder/features/presets/domain/preset_codec.dart';
import 'package:transcoder/features/subtitles/domain/subtitle_enums.dart';
import 'package:transcoder/features/subtitles/domain/subtitle_settings_state.dart';
import 'package:transcoder/features/video/domain/video_settings_state.dart';

/// Full snapshot of a transcode job's configuration (video + audio + subtitles).
class JobOptions {
  const JobOptions({
    required this.video,
    required this.audioTracks,
    required this.subtitleTracks,
  });

  final VideoSettingsState video;
  final List<AudioTrackConfig> audioTracks;
  final List<SubtitleTrackConfig> subtitleTracks;
}

/// Encodes / decodes [JobOptions] to / from JSON for [TranscodeJob.encodeOptionsJson].
abstract final class JobOptionsCodec {
  static String encode(JobOptions opts) {
    return jsonEncode({
      'video': PresetCodec.encode(opts.video),
      'audio': opts.audioTracks.map(_encodeAudioTrack).toList(),
      'subtitles': opts.subtitleTracks.map(_encodeSubTrack).toList(),
    });
  }

  static JobOptions decode(String json) {
    final m = jsonDecode(json) as Map<String, dynamic>;
    return JobOptions(
      video: PresetCodec.decode(m['video'] as Map<String, dynamic>),
      audioTracks: (m['audio'] as List<dynamic>)
          .map((e) => _decodeAudioTrack(e as Map<String, dynamic>))
          .toList(),
      subtitleTracks: (m['subtitles'] as List<dynamic>)
          .map((e) => _decodeSubTrack(e as Map<String, dynamic>))
          .toList(),
    );
  }

  // -- Audio track -----------------------------------------------------------

  static Map<String, dynamic> _encodeAudioTrack(AudioTrackConfig t) => {
        'sourceIndex': t.sourceIndex,
        'sourceLabel': t.sourceLabel,
        'action': t.action.name,
        'codec': t.codec.name,
        'bitrate': t.bitrate,
        'mixdown': t.mixdown.name,
      };

  static AudioTrackConfig _decodeAudioTrack(Map<String, dynamic> m) {
    return AudioTrackConfig(
      sourceIndex: m['sourceIndex'] as int,
      sourceLabel: m['sourceLabel'] as String,
      action: _enumByName(AudioTrackAction.values, m['action']) ??
          AudioTrackAction.encode,
      codec: _enumByName(AudioCodec.values, m['codec']) ?? AudioCodec.aac,
      bitrate: m['bitrate'] as int? ?? 160,
      mixdown:
          _enumByName(AudioMixdown.values, m['mixdown']) ?? AudioMixdown.stereo,
    );
  }

  // -- Subtitle track --------------------------------------------------------

  static Map<String, dynamic> _encodeSubTrack(SubtitleTrackConfig t) => {
        'sourceIndex': t.sourceIndex,
        'sourceLabel': t.sourceLabel,
        'action': t.action.name,
        'isExternal': t.isExternal,
        if (t.externalPath != null) 'externalPath': t.externalPath,
      };

  static SubtitleTrackConfig _decodeSubTrack(Map<String, dynamic> m) {
    return SubtitleTrackConfig(
      sourceIndex: m['sourceIndex'] as int,
      sourceLabel: m['sourceLabel'] as String,
      action: _enumByName(SubtitleTrackAction.values, m['action']) ??
          SubtitleTrackAction.soft,
      isExternal: m['isExternal'] as bool? ?? false,
      externalPath: m['externalPath'] as String?,
    );
  }

  static T? _enumByName<T extends Enum>(List<T> values, dynamic name) {
    if (name is! String) return null;
    for (final v in values) {
      if (v.name == name) return v;
    }
    return null;
  }
}
