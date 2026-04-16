// Enumerations for audio track configuration.

// ---------------------------------------------------------------------------
// Track action
// ---------------------------------------------------------------------------

enum AudioTrackAction {
  encode('Encode'),
  passthrough('Passthrough'),
  remove('Remove');

  const AudioTrackAction(this.label);
  final String label;
}

// ---------------------------------------------------------------------------
// Audio codec
// ---------------------------------------------------------------------------

enum AudioCodec {
  aac('AAC', 'aac', 320),
  mp3('MP3', 'libmp3lame', 320),
  flac('FLAC', 'flac', 0),
  ac3('AC3', 'ac3', 640),
  eac3('E-AC3', 'eac3', 1536),
  opus('Opus', 'libopus', 512);

  const AudioCodec(this.label, this.ffmpegName, this.maxBitrate);
  final String label;
  final String ffmpegName;

  /// Maximum bitrate in kbps. 0 means lossless (no bitrate setting).
  final int maxBitrate;

  bool get isLossless => this == flac;

  int get minBitrate {
    switch (this) {
      case aac:
        return 32;
      case mp3:
        return 32;
      case ac3:
        return 64;
      case eac3:
        return 64;
      case opus:
        return 6;
      case flac:
        return 0;
    }
  }

  int get defaultBitrate {
    switch (this) {
      case aac:
        return 160;
      case mp3:
        return 192;
      case ac3:
        return 384;
      case eac3:
        return 448;
      case opus:
        return 128;
      case flac:
        return 0;
    }
  }
}

// ---------------------------------------------------------------------------
// Mixdown
// ---------------------------------------------------------------------------

enum AudioMixdown {
  mono('Mono', 1, 'mono'),
  stereo('Stereo', 2, 'stereo'),
  surround51('5.1 Surround', 6, '5.1'),
  surround71('7.1 Surround', 8, '7.1');

  const AudioMixdown(this.label, this.channels, this.ffmpegLayout);
  final String label;
  final int channels;
  final String ffmpegLayout;
}
