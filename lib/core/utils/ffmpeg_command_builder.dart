import 'package:transcoder/features/audio/domain/audio_enums.dart';
import 'package:transcoder/features/audio/domain/audio_settings_state.dart';
import 'package:transcoder/features/subtitles/domain/subtitle_enums.dart';
import 'package:transcoder/features/subtitles/domain/subtitle_settings_state.dart';
import 'package:transcoder/features/video/domain/video_enums.dart';
import 'package:transcoder/features/video/domain/video_settings_state.dart';

/// Builds a complete FFmpeg CLI argument list from the current Riverpod state.
///
/// Usage:
/// ```dart
/// final args = FFmpegCommandBuilder(
///   inputPath: '/path/to/input.mkv',
///   outputPath: '/path/to/output.mp4',
///   video: videoState,
///   audioTracks: audioState.tracks,
///   subtitleTracks: subtitleState.tracks,
/// ).build();
/// // → ["-i", "/path/to/input.mkv", "-c:v", "libx265", "-crf", "22", ...]
/// ```
class FFmpegCommandBuilder {
  FFmpegCommandBuilder({
    required this.inputPath,
    required this.outputPath,
    required this.video,
    this.audioTracks = const [],
    this.subtitleTracks = const [],
  });

  final String inputPath;
  final String outputPath;
  final VideoSettingsState video;
  final List<AudioTrackConfig> audioTracks;
  final List<SubtitleTrackConfig> subtitleTracks;

  /// Build the full argument list for FFmpegKit.executeWithArguments.
  List<String> build() {
    final args = <String>[];

    // -- Inputs --------------------------------------------------------------
    args.addAll(['-i', inputPath]);

    // External subtitle inputs (each gets its own -i).
    final externalSubs = <SubtitleTrackConfig>[];
    for (final t in subtitleTracks) {
      if (t.isExternal &&
          t.externalPath != null &&
          t.action != SubtitleTrackAction.remove) {
        externalSubs.add(t);
        args.addAll(['-i', t.externalPath!]);
      }
    }

    // -- Video codec ---------------------------------------------------------
    _addVideoArgs(args);

    // -- Audio codec(s) ------------------------------------------------------
    _addAudioArgs(args);

    // -- Subtitles -----------------------------------------------------------
    _addSubtitleArgs(args, externalSubs);

    // -- Video filters -------------------------------------------------------
    _addFilterArgs(args);

    // -- Frame rate ----------------------------------------------------------
    if (video.frameRate.value != null) {
      args.addAll(['-r', video.frameRate.value!.toString()]);
    }

    // -- Output container ----------------------------------------------------
    args.addAll(['-f', video.container.ffmpegFormat]);

    // Overwrite output without prompting.
    args.add('-y');
    args.add(outputPath);

    return args;
  }

  /// Build a single-string representation (for display / logging).
  String buildCommandString() {
    return build().map((a) => a.contains(' ') ? '"$a"' : a).join(' ');
  }

  // -------------------------------------------------------------------------
  // Video
  // -------------------------------------------------------------------------

  void _addVideoArgs(List<String> args) {
    args.addAll(['-c:v', video.encoder.ffmpegName]);

    // Quality mode.
    if (video.qualityMode == QualityMode.constantQuality) {
      // Hardware encoders use -q:v (global_quality) instead of -crf.
      if (video.encoder.isHardware) {
        args.addAll(['-q:v', '${video.crf}']);
      } else {
        args.addAll(['-crf', '${video.crf}']);
      }
    } else {
      args.addAll(['-b:v', '${video.averageBitrate}k']);
    }

    // Software encoder preset / tune / profile / level.
    if (video.supportsPresetTune) {
      args.addAll(['-preset', video.preset.name]);
      if (video.tune != EncoderTune.none) {
        args.addAll(['-tune', video.tune.ffmpegValue]);
      }
    }

    if (video.profile != EncoderProfile.auto &&
        video.profile.ffmpegValue.isNotEmpty) {
      args.addAll(['-profile:v', video.profile.ffmpegValue]);
    }

    if (video.level != EncoderLevel.auto &&
        video.level.ffmpegValue.isNotEmpty) {
      args.addAll(['-level', video.level.ffmpegValue]);
    }
  }

  // -------------------------------------------------------------------------
  // Audio
  // -------------------------------------------------------------------------

  void _addAudioArgs(List<String> args) {
    final activeTracks = <AudioTrackConfig>[];
    for (final t in audioTracks) {
      if (t.action != AudioTrackAction.remove) activeTracks.add(t);
    }

    if (activeTracks.isEmpty) {
      args.add('-an'); // No audio.
      return;
    }

    // Map each output audio stream.
    for (var i = 0; i < activeTracks.length; i++) {
      final t = activeTracks[i];
      final streamSpec = ':$i';

      if (t.action == AudioTrackAction.passthrough) {
        args.addAll(['-c:a$streamSpec', 'copy']);
      } else {
        args.addAll(['-c:a$streamSpec', t.codec.ffmpegName]);
        if (!t.codec.isLossless) {
          args.addAll(['-b:a$streamSpec', '${t.bitrate}k']);
        }
        args.addAll(['-ac$streamSpec', '${t.mixdown.channels}']);
      }
    }

    // Map audio stream indices.
    for (final t in activeTracks) {
      args.addAll(['-map', '0:${t.sourceIndex}']);
    }
  }

  // -------------------------------------------------------------------------
  // Subtitles
  // -------------------------------------------------------------------------

  void _addSubtitleArgs(
      List<String> args, List<SubtitleTrackConfig> externalSubs) {
    // Burn-in is handled via -vf (subtitle filter), not here.
    // Here we handle soft-mux tracks only.

    final softTracks = <SubtitleTrackConfig>[];
    for (final t in subtitleTracks) {
      if (t.action == SubtitleTrackAction.soft) softTracks.add(t);
    }

    if (softTracks.isEmpty) {
      args.add('-sn'); // No subtitle output stream.
      return;
    }

    args.addAll(['-c:s', 'copy']);

    for (final t in softTracks) {
      if (t.isExternal && t.externalPath != null) {
        // Find the input index for this external sub.
        final extIdx = externalSubs.indexOf(t);
        if (extIdx >= 0) {
          args.addAll(['-map', '${extIdx + 1}:0']);
        }
      } else {
        args.addAll(['-map', '0:${t.sourceIndex}']);
      }
    }
  }

  // -------------------------------------------------------------------------
  // Video filters (-vf)
  // -------------------------------------------------------------------------

  void _addFilterArgs(List<String> args) {
    final filterGraph = video.buildFilterGraph();

    // Check for burn-in subtitle (rendered via filter).
    final burnIn = subtitleTracks
        .where((t) => t.action == SubtitleTrackAction.burnIn)
        .toList();

    String? subtitleFilter;
    if (burnIn.isNotEmpty) {
      final t = burnIn.first;
      if (t.isExternal && t.externalPath != null) {
        final escaped = t.externalPath!
            .replaceAll('\\', '/')
            .replaceAll(':', '\\:')
            .replaceAll("'", "\\'");
        subtitleFilter = "subtitles='$escaped'";
      } else {
        final escaped = inputPath
            .replaceAll('\\', '/')
            .replaceAll(':', '\\:')
            .replaceAll("'", "\\'");
        subtitleFilter = "subtitles='$escaped':si=${t.sourceIndex}";
      }
    }

    final parts = <String>[];
    if (filterGraph != null) parts.add(filterGraph);
    if (subtitleFilter != null) parts.add(subtitleFilter);

    if (parts.isNotEmpty) {
      args.addAll(['-vf', parts.join(',')]);
    }

    // Always map the first video stream.
    args.addAll(['-map', '0:v:0']);
  }
}
