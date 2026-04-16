import 'package:transcoder/core/utils/media_probe_parser.dart';
import 'package:transcoder/features/subtitles/domain/subtitle_enums.dart';

/// Configuration for a single subtitle track in the output.
class SubtitleTrackConfig {
  const SubtitleTrackConfig({
    required this.sourceIndex,
    required this.sourceLabel,
    this.action = SubtitleTrackAction.soft,
    this.isExternal = false,
    this.externalPath,
  });

  /// FFmpeg stream index (-1 for external SRT files).
  final int sourceIndex;

  final String sourceLabel;
  final SubtitleTrackAction action;

  /// True if this track was imported from an external .srt file.
  final bool isExternal;

  /// File path for external subtitle (only when [isExternal] is true).
  final String? externalPath;

  SubtitleTrackConfig copyWith({
    SubtitleTrackAction? action,
  }) {
    return SubtitleTrackConfig(
      sourceIndex: sourceIndex,
      sourceLabel: sourceLabel,
      action: action ?? this.action,
      isExternal: isExternal,
      externalPath: externalPath,
    );
  }

  static String labelFrom(SubtitleTrackSummary t) {
    final parts = <String>['Track ${t.index}'];
    if (t.language != null) parts.add(t.language!);
    parts.add(t.codec.toUpperCase());
    return parts.join(' \u2014 ');
  }
}

/// Holds the list of subtitle track configurations for the current job.
class SubtitleSettingsState {
  const SubtitleSettingsState({this.tracks = const []});

  final List<SubtitleTrackConfig> tracks;

  SubtitleSettingsState copyWith({List<SubtitleTrackConfig>? tracks}) {
    return SubtitleSettingsState(tracks: tracks ?? this.tracks);
  }

  SubtitleSettingsState replaceTrack(int index, SubtitleTrackConfig config) {
    final copy = List<SubtitleTrackConfig>.of(tracks);
    copy[index] = config;
    return SubtitleSettingsState(tracks: copy);
  }

  /// Only one track can be burned in at a time.
  bool get hasBurnIn =>
      tracks.any((t) => t.action == SubtitleTrackAction.burnIn);
}
