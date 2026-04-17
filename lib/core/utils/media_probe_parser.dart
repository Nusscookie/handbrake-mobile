import 'package:ffmpeg_kit_flutter_new/media_information.dart';
import 'package:ffmpeg_kit_flutter_new/stream_information.dart';

/// Parsed, UI-friendly view of [MediaInformation] (HandBrake-style source panel).
class SourceProbeSummary {
  const SourceProbeSummary({
    this.containerFormat,
    this.duration,
    this.sizeBytes,
    this.formatBitrateBps,
    this.video,
    required this.audioTracks,
    required this.subtitleTracks,
  });

  final String? containerFormat;
  final Duration? duration;
  final int? sizeBytes;
  final int? formatBitrateBps;
  final VideoTrackSummary? video;
  final List<AudioTrackSummary> audioTracks;
  final List<SubtitleTrackSummary> subtitleTracks;
}

class VideoTrackSummary {
  const VideoTrackSummary({
    required this.index,
    required this.codec,
    this.width,
    this.height,
    this.frameRate,
    this.pixelFormat,
  });

  final int index;
  final String codec;
  final int? width;
  final int? height;
  final double? frameRate;
  final String? pixelFormat;
}

class AudioTrackSummary {
  const AudioTrackSummary({
    required this.index,
    required this.codec,
    this.language,
    this.channels,
    this.channelLayout,
    this.bitrateBps,
    this.sampleRateHz,
  });

  final int index;
  final String codec;
  final String? language;
  final int? channels;
  final String? channelLayout;
  final int? bitrateBps;
  final int? sampleRateHz;
}

class SubtitleTrackSummary {
  const SubtitleTrackSummary({
    required this.index,
    required this.codec,
    this.language,
  });

  final int index;
  final String codec;
  final String? language;
}

abstract final class MediaProbeParser {
  static SourceProbeSummary? parse(MediaInformation? info) {
    if (info == null) return null;

    final duration = _parseDurationSeconds(info.getDuration());
    final sizeBytes = _parseInt(info.getSize());
    final formatBitrate = _parseInt(info.getBitrate());

    final streams = info.getStreams();
    StreamInformation? videoStream;
    for (final s in streams) {
      if (s.getType() == 'video') {
        videoStream = s;
        break;
      }
    }

    VideoTrackSummary? video;
    if (videoStream != null) {
      final idx = videoStream.getIndex() ?? 0;
      video = VideoTrackSummary(
        index: idx,
        codec: videoStream.getCodec() ?? 'unknown',
        width: videoStream.getWidth(),
        height: videoStream.getHeight(),
        frameRate: _parseFrameRate(videoStream.getAverageFrameRate()) ??
            _parseFrameRate(videoStream.getRealFrameRate()),
        pixelFormat: videoStream.getFormat(),
      );
    }

    final audioTracks = <AudioTrackSummary>[];
    final subtitleTracks = <SubtitleTrackSummary>[];

    for (final s in streams) {
      final type = s.getType();
      if (type == 'audio') {
        audioTracks.add(_parseAudio(s));
      } else if (type == 'subtitle') {
        subtitleTracks.add(_parseSubtitle(s));
      }
    }

    audioTracks.sort((a, b) => a.index.compareTo(b.index));
    subtitleTracks.sort((a, b) => a.index.compareTo(b.index));

    return SourceProbeSummary(
      containerFormat: info.getFormat(),
      duration: duration,
      sizeBytes: sizeBytes,
      formatBitrateBps: formatBitrate,
      video: video,
      audioTracks: audioTracks,
      subtitleTracks: subtitleTracks,
    );
  }

  static AudioTrackSummary _parseAudio(StreamInformation s) {
    final tags = s.getTags();
    return AudioTrackSummary(
      index: s.getIndex() ?? 0,
      codec: s.getCodec() ?? 'unknown',
      language: _tagLanguage(tags),
      channels: s.getNumberProperty('channels')?.toInt(),
      channelLayout: s.getChannelLayout(),
      bitrateBps: _parseInt(s.getBitrate()),
      sampleRateHz: _parseInt(s.getSampleRate()),
    );
  }

  static SubtitleTrackSummary _parseSubtitle(StreamInformation s) {
    final tags = s.getTags();
    return SubtitleTrackSummary(
      index: s.getIndex() ?? 0,
      codec: s.getCodec() ?? 'unknown',
      language: _tagLanguage(tags),
    );
  }

  static String? _tagLanguage(Map<dynamic, dynamic>? tags) {
    if (tags == null) return null;
    final v = tags['language'] ?? tags['LANGUAGE'] ?? tags['lang'];
    if (v == null) return null;
    final s = v.toString();
    return s.isEmpty ? null : s;
  }

  static Duration? _parseDurationSeconds(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    final v = double.tryParse(raw);
    if (v == null) return null;
    return Duration(milliseconds: (v * 1000).round());
  }

  static int? _parseInt(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return int.tryParse(raw);
  }

  static double? _parseFrameRate(String? raw) {
    if (raw == null || raw.isEmpty || raw == '0/0') return null;
    final parts = raw.split('/');
    if (parts.length == 2) {
      final n = double.tryParse(parts[0]);
      final d = double.tryParse(parts[1]);
      if (n != null && d != null && d != 0) return n / d;
    }
    return double.tryParse(raw);
  }
}
