import 'package:transcoder/features/video/domain/video_enums.dart';

/// Complete video encoding + filter configuration for one transcode job.
class VideoSettingsState {
  const VideoSettingsState({
    this.container = OutputContainer.mp4,
    this.encoder = VideoEncoder.x264,
    this.preset = EncoderPreset.medium,
    this.tune = EncoderTune.none,
    this.profile = EncoderProfile.auto,
    this.level = EncoderLevel.auto,
    this.qualityMode = QualityMode.constantQuality,
    this.crf = 22,
    this.averageBitrate = 5000,
    this.frameRate = FrameRateOption.source,
    this.width,
    this.height,
    this.autoCrop = true,
    this.cropTop = 0,
    this.cropBottom = 0,
    this.cropLeft = 0,
    this.cropRight = 0,
    this.deinterlace = DeinterlaceMode.off,
    this.denoise = DenoiseMode.off,
    this.sharpen = SharpenMode.off,
    this.grayscale = false,
    this.rotation = RotationOption.none,
  });

  // -- Container -----------------------------------------------------------
  final OutputContainer container;

  // -- Encoder core --------------------------------------------------------
  final VideoEncoder encoder;
  final EncoderPreset preset;
  final EncoderTune tune;
  final EncoderProfile profile;
  final EncoderLevel level;

  // -- Quality -------------------------------------------------------------
  final QualityMode qualityMode;

  /// CRF value (0 = lossless, 51 = worst). Typical range 18-28.
  final int crf;

  /// Average bitrate in kbps.
  final int averageBitrate;

  // -- Resolution / frame rate ---------------------------------------------
  final FrameRateOption frameRate;

  /// null ⇒ keep source resolution.
  final int? width;
  final int? height;

  // -- Cropping ------------------------------------------------------------
  final bool autoCrop;
  final int cropTop;
  final int cropBottom;
  final int cropLeft;
  final int cropRight;

  // -- Filters -------------------------------------------------------------
  final DeinterlaceMode deinterlace;
  final DenoiseMode denoise;
  final SharpenMode sharpen;
  final bool grayscale;
  final RotationOption rotation;

  // -- Derived helpers -----------------------------------------------------

  /// CRF range depends on codec (0-51 for x264/x265, 0-63 for VP9/AV1).
  int get maxCrf {
    switch (encoder) {
      case VideoEncoder.vp9:
      case VideoEncoder.av1:
        return 63;
      default:
        return 51;
    }
  }

  /// Whether the current encoder supports preset/tune/profile/level.
  bool get supportsPresetTune =>
      encoder == VideoEncoder.x264 || encoder == VideoEncoder.x265;

  /// Build the `-vf` filter graph string (comma-separated).
  String? buildFilterGraph() {
    final parts = <String>[];
    if (deinterlace.filterString != null) parts.add(deinterlace.filterString!);
    if (denoise.filterString != null) parts.add(denoise.filterString!);
    if (sharpen.filterString != null) parts.add(sharpen.filterString!);
    if (grayscale) parts.add('format=gray');
    if (rotation.filterString != null) parts.add(rotation.filterString!);

    final crop = _cropFilter();
    if (crop != null) parts.add(crop);

    final scale = _scaleFilter();
    if (scale != null) parts.add(scale);

    return parts.isEmpty ? null : parts.join(',');
  }

  String? _cropFilter() {
    if (autoCrop) return null;
    if (cropTop == 0 && cropBottom == 0 && cropLeft == 0 && cropRight == 0) {
      return null;
    }
    return 'crop=iw-${cropLeft + cropRight}:ih-${cropTop + cropBottom}:$cropLeft:$cropTop';
  }

  String? _scaleFilter() {
    if (width == null && height == null) return null;
    final w = width ?? -2;
    final h = height ?? -2;
    return 'scale=$w:$h';
  }

  // -- copyWith ------------------------------------------------------------

  VideoSettingsState copyWith({
    OutputContainer? container,
    VideoEncoder? encoder,
    EncoderPreset? preset,
    EncoderTune? tune,
    EncoderProfile? profile,
    EncoderLevel? level,
    QualityMode? qualityMode,
    int? crf,
    int? averageBitrate,
    FrameRateOption? frameRate,
    int? width,
    int? height,
    bool? autoCrop,
    int? cropTop,
    int? cropBottom,
    int? cropLeft,
    int? cropRight,
    DeinterlaceMode? deinterlace,
    DenoiseMode? denoise,
    SharpenMode? sharpen,
    bool? grayscale,
    RotationOption? rotation,
    bool clearWidth = false,
    bool clearHeight = false,
  }) {
    return VideoSettingsState(
      container: container ?? this.container,
      encoder: encoder ?? this.encoder,
      preset: preset ?? this.preset,
      tune: tune ?? this.tune,
      profile: profile ?? this.profile,
      level: level ?? this.level,
      qualityMode: qualityMode ?? this.qualityMode,
      crf: crf ?? this.crf,
      averageBitrate: averageBitrate ?? this.averageBitrate,
      frameRate: frameRate ?? this.frameRate,
      width: clearWidth ? null : (width ?? this.width),
      height: clearHeight ? null : (height ?? this.height),
      autoCrop: autoCrop ?? this.autoCrop,
      cropTop: cropTop ?? this.cropTop,
      cropBottom: cropBottom ?? this.cropBottom,
      cropLeft: cropLeft ?? this.cropLeft,
      cropRight: cropRight ?? this.cropRight,
      deinterlace: deinterlace ?? this.deinterlace,
      denoise: denoise ?? this.denoise,
      sharpen: sharpen ?? this.sharpen,
      grayscale: grayscale ?? this.grayscale,
      rotation: rotation ?? this.rotation,
    );
  }
}
