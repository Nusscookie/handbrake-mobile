import 'package:transcoder/core/utils/media_probe_parser.dart';
import 'package:transcoder/features/audio/domain/audio_enums.dart';

/// Configuration for a single audio track in the output.
class AudioTrackConfig {
  const AudioTrackConfig({
    required this.sourceIndex,
    required this.sourceLabel,
    this.action = AudioTrackAction.encode,
    this.codec = AudioCodec.aac,
    this.bitrate = 160,
    this.mixdown = AudioMixdown.stereo,
  });

  /// FFmpeg stream index from the source file.
  final int sourceIndex;

  /// Human-readable label (e.g. "Track 1 — English, AAC, Stereo").
  final String sourceLabel;

  final AudioTrackAction action;
  final AudioCodec codec;

  /// Bitrate in kbps (ignored for passthrough / FLAC).
  final int bitrate;

  final AudioMixdown mixdown;

  AudioTrackConfig copyWith({
    AudioTrackAction? action,
    AudioCodec? codec,
    int? bitrate,
    AudioMixdown? mixdown,
  }) {
    return AudioTrackConfig(
      sourceIndex: sourceIndex,
      sourceLabel: sourceLabel,
      action: action ?? this.action,
      codec: codec ?? this.codec,
      bitrate: bitrate ?? this.bitrate,
      mixdown: mixdown ?? this.mixdown,
    );
  }

  /// Build a human-readable label from [AudioTrackSummary].
  static String labelFrom(AudioTrackSummary t) {
    final parts = <String>['Track ${t.index}'];
    if (t.language != null) parts.add(t.language!);
    parts.add(t.codec.toUpperCase());
    if (t.channels != null) {
      parts.add(_channelLabel(t.channels!));
    }
    if (t.bitrateBps != null) {
      parts.add('${(t.bitrateBps! / 1000).round()} kbps');
    }
    return parts.join(' \u2014 ');
  }

  static String _channelLabel(int ch) {
    switch (ch) {
      case 1:
        return 'Mono';
      case 2:
        return 'Stereo';
      case 6:
        return '5.1';
      case 8:
        return '7.1';
      default:
        return '${ch}ch';
    }
  }
}

/// Holds the list of audio track configurations for the current job.
class AudioSettingsState {
  const AudioSettingsState({this.tracks = const []});

  final List<AudioTrackConfig> tracks;

  AudioSettingsState copyWith({List<AudioTrackConfig>? tracks}) {
    return AudioSettingsState(tracks: tracks ?? this.tracks);
  }

  /// Replace the config at [index], return new state.
  AudioSettingsState replaceTrack(int index, AudioTrackConfig config) {
    final copy = List<AudioTrackConfig>.of(tracks);
    copy[index] = config;
    return AudioSettingsState(tracks: copy);
  }
}
