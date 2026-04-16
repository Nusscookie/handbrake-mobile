// All enumerations used by the Video & Filters tabs.

// ---------------------------------------------------------------------------
// Video encoder
// ---------------------------------------------------------------------------

enum VideoEncoder {
  x264('H.264 (x264)', 'libx264'),
  x265('H.265 (x265)', 'libx265'),
  h264Videotoolbox('H.264 (VideoToolbox)', 'h264_videotoolbox'),
  hevcVideotoolbox('H.265 (VideoToolbox)', 'hevc_videotoolbox'),
  h264Mediacodec('H.264 (MediaCodec)', 'h264_mediacodec'),
  hevcMediacodec('H.265 (MediaCodec)', 'hevc_mediacodec'),
  vp9('VP9', 'libvpx-vp9'),
  av1('AV1 (SVT)', 'libsvtav1');

  const VideoEncoder(this.label, this.ffmpegName);
  final String label;
  final String ffmpegName;

  bool get isHardware =>
      this == h264Videotoolbox ||
      this == hevcVideotoolbox ||
      this == h264Mediacodec ||
      this == hevcMediacodec;
}

// ---------------------------------------------------------------------------
// x264 / x265 preset
// ---------------------------------------------------------------------------

enum EncoderPreset {
  ultrafast,
  superfast,
  veryfast,
  faster,
  fast,
  medium,
  slow,
  slower,
  veryslow,
  placebo;

  String get label => name;
}

// ---------------------------------------------------------------------------
// x264 / x265 tune
// ---------------------------------------------------------------------------

enum EncoderTune {
  none('None', ''),
  film('Film', 'film'),
  animation('Animation', 'animation'),
  grain('Grain', 'grain'),
  stillimage('Still Image', 'stillimage'),
  psnr('PSNR', 'psnr'),
  ssim('SSIM', 'ssim'),
  fastdecode('Fast Decode', 'fastdecode'),
  zerolatency('Zero Latency', 'zerolatency');

  const EncoderTune(this.label, this.ffmpegValue);
  final String label;
  final String ffmpegValue;
}

// ---------------------------------------------------------------------------
// H.264 / H.265 profile
// ---------------------------------------------------------------------------

enum EncoderProfile {
  auto('Auto', ''),
  baseline('Baseline', 'baseline'),
  main('Main', 'main'),
  high('High', 'high'),
  main10('Main 10', 'main10');

  const EncoderProfile(this.label, this.ffmpegValue);
  final String label;
  final String ffmpegValue;

  static List<EncoderProfile> forEncoder(VideoEncoder encoder) {
    switch (encoder) {
      case VideoEncoder.x264:
      case VideoEncoder.h264Videotoolbox:
      case VideoEncoder.h264Mediacodec:
        return [auto, baseline, main, high];
      case VideoEncoder.x265:
      case VideoEncoder.hevcVideotoolbox:
      case VideoEncoder.hevcMediacodec:
        return [auto, main, main10];
      default:
        return [auto];
    }
  }
}

// ---------------------------------------------------------------------------
// H.264 level
// ---------------------------------------------------------------------------

enum EncoderLevel {
  auto('Auto', ''),
  l30('3.0', '3.0'),
  l31('3.1', '3.1'),
  l40('4.0', '4.0'),
  l41('4.1', '4.1'),
  l42('4.2', '4.2'),
  l50('5.0', '5.0'),
  l51('5.1', '5.1'),
  l52('5.2', '5.2');

  const EncoderLevel(this.label, this.ffmpegValue);
  final String label;
  final String ffmpegValue;
}

// ---------------------------------------------------------------------------
// Quality mode
// ---------------------------------------------------------------------------

enum QualityMode {
  constantQuality('Constant Quality (CRF)'),
  averageBitrate('Average Bitrate (kbps)');

  const QualityMode(this.label);
  final String label;
}

// ---------------------------------------------------------------------------
// Frame rate
// ---------------------------------------------------------------------------

enum FrameRateOption {
  source('Same as Source', null),
  fps23976('23.976', 23.976),
  fps24('24', 24),
  fps25('25', 25),
  fps29970('29.97', 29.97),
  fps30('30', 30),
  fps50('50', 50),
  fps59940('59.94', 59.94),
  fps60('60', 60);

  const FrameRateOption(this.label, this.value);
  final String label;
  final double? value;
}

// ---------------------------------------------------------------------------
// Output container
// ---------------------------------------------------------------------------

enum OutputContainer {
  mp4('MP4', 'mp4'),
  mkv('MKV', 'matroska'),
  webm('WebM', 'webm');

  const OutputContainer(this.label, this.ffmpegFormat);
  final String label;
  final String ffmpegFormat;
}

// ---------------------------------------------------------------------------
// Filter: Deinterlace
// ---------------------------------------------------------------------------

enum DeinterlaceMode {
  off('Off'),
  yadif('Yadif'),
  yadifDouble('Yadif (Double Rate)');

  const DeinterlaceMode(this.label);
  final String label;

  String? get filterString {
    switch (this) {
      case off:
        return null;
      case yadif:
        return 'yadif=0:-1:0';
      case yadifDouble:
        return 'yadif=1:-1:0';
    }
  }
}

// ---------------------------------------------------------------------------
// Filter: Denoise
// ---------------------------------------------------------------------------

enum DenoiseMode {
  off('Off'),
  nlmeansLight('NLMeans (Light)'),
  nlmeansMedium('NLMeans (Medium)'),
  nlmeansStrong('NLMeans (Strong)'),
  hqdn3dLight('hqdn3d (Light)'),
  hqdn3dMedium('hqdn3d (Medium)'),
  hqdn3dStrong('hqdn3d (Strong)');

  const DenoiseMode(this.label);
  final String label;

  String? get filterString {
    switch (this) {
      case off:
        return null;
      case nlmeansLight:
        return 'nlmeans=s=3:p=3:r=5';
      case nlmeansMedium:
        return 'nlmeans=s=6:p=3:r=7';
      case nlmeansStrong:
        return 'nlmeans=s=10:p=5:r=9';
      case hqdn3dLight:
        return 'hqdn3d=2:1:2:3';
      case hqdn3dMedium:
        return 'hqdn3d=4:3:4:6';
      case hqdn3dStrong:
        return 'hqdn3d=7:5:7:10';
    }
  }
}

// ---------------------------------------------------------------------------
// Filter: Sharpen
// ---------------------------------------------------------------------------

enum SharpenMode {
  off('Off'),
  light('Unsharp (Light)'),
  medium('Unsharp (Medium)'),
  strong('Unsharp (Strong)');

  const SharpenMode(this.label);
  final String label;

  String? get filterString {
    switch (this) {
      case off:
        return null;
      case light:
        return 'unsharp=3:3:0.3:3:3:0.0';
      case medium:
        return 'unsharp=5:5:0.8:5:5:0.0';
      case strong:
        return 'unsharp=7:7:1.5:7:7:0.0';
    }
  }
}

// ---------------------------------------------------------------------------
// Filter: Rotation
// ---------------------------------------------------------------------------

enum RotationOption {
  none('None', null),
  cw90('90° CW', 'transpose=1'),
  cw180('180°', 'transpose=1,transpose=1'),
  ccw90('90° CCW', 'transpose=2'),
  hflip('Horizontal Flip', 'hflip'),
  vflip('Vertical Flip', 'vflip');

  const RotationOption(this.label, this.filterString);
  final String label;
  final String? filterString;
}
