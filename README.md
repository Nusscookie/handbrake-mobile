# Transcoder – HandBrake Mobile Clone

A production-grade Flutter video transcoding application for iOS and Android, inspired by HandBrake. Transcoder enables users to select video files, configure advanced encoding options (video, audio, subtitles), and queue batch transcoding jobs for sequential execution.

## Features

### Source Management
- **File Selection**: Browse and select video files via native file picker
- **Media Probing**: Use FFprobe to extract media information (codecs, streams, duration, resolution)
- **Metadata Caching**: Isar database caches probe results for faster re-selection of recent files
- **Multi-Format Support**: Supports MP4, MKV, MOV, AVI, WebM, TS, M4V, WMV, FLV, MPEG, 3GP, OGV and more

### Video Encoding
- **Codec Selection**: H.264 (x264), H.265 (x265), VP9, AV1
- **Quality Modes**: Constant Rate Factor (CRF) 0–51 or Average Bitrate (ABR)
- **Encoder Presets**: ultra-fast through veryslow
- **Resolution**: Custom width/height with aspect ratio preservation
- **Filters**: Deinterlace, denoise, scale, and crop
- **Output Container**: MP4, MKV, WebM

### Audio Encoding
- **Per-Track Configuration**: Encode multiple audio tracks independently
- **Codec Support**: AAC, MP3, FLAC, AC3, E-AC3, Opus
- **Bitrate Selection**: Codec-dependent ranges
- **Audio Mixdown**: Mono, stereo, 2.1, 5.1, 6.1, 7.1

### Subtitle Handling
- **Track Modes**: Soft-mux, Burn-in (single track), External SRT
- **Single Burn-in Constraint**: Only one subtitle track can be burned in per job
- **SRT Import**: Import external SRT files

### Presets
- **11 Built-in Presets**: General, Devices, Web categories
- **Custom Presets**: Save and manage your own presets
- **One-Click Apply**: Instantly apply all settings from a preset

### Queue & Batch Processing
- **Sequential Execution**: Queue multiple jobs; they process one-by-one
- **Real-Time Progress**: Track fraction, duration, speed, ETA, FPS
- **Job Status**: Pending → Running → Completed/Failed/Cancelled
- **Error Logging**: Last 500 bytes of FFmpeg logs for failed jobs
- **Cancel Support**: Stop the active encode
- **Wakelock**: Screen stays on during encoding

## Architecture

### Tech Stack
- **Framework**: Flutter 3.x with Material 3
- **State**: Riverpod (Notifier pattern)
- **Database**: Isar (embedded NoSQL)
- **Video**: FFmpeg/FFprobe via ffmpeg_kit_flutter_full_gpl
- **Routing**: GoRouter

### Feature Architecture

```
lib/features/{feature}/
├── domain/        # Business logic, enums, models
├── application/   # Controllers, use cases
└── presentation/  # UI screens
```

Features: source, video, audio, subtitles, presets, queue

### Database (Isar)

**Collections:**
- `TranscodeJob`: Encoding jobs with status/options
- `CustomPreset`: User presets
- `VideoMetadata`: Probe cache
- `AppSettings`: App configuration

### State Management

Immutable state with `copyWith`:

```dart
@Riverpod(keepAlive: true)
class VideoSettingsController extends _$VideoSettingsController {
  @override
  VideoSettingsState build() => const VideoSettingsState();
  
  void setEncoder(VideoEncoder encoder) {
    state = state.copyWith(encoder: encoder);
  }
}
```

### Responsive Design

- **Mobile (< 600 dp)**: Bottom nav, single-column
- **Tablet (600–839 dp)**: Collapsed rail, two-column editors
- **Wide (≥ 840 dp)**: Expanded rail, spacious layout

## Platform Support

### Supported
- ✅ Android 5.0+ (API 21+)
- ✅ iOS 11+
- ✅ macOS 11+

### Unsupported
- ❌ Windows, Linux, Web (FFmpegKit unavailable)

Graceful error handling on unsupported platforms via `platform_support.dart`.

## Building & Running

### Prerequisites
- Flutter 3.x+
- Android SDK 21+
- iOS 11+ with Xcode 14+

### Setup

```bash
git clone https://github.com/your-org/transcoder.git
cd transcoder
flutter pub get
dart run build_runner build
```

### Run

```bash
flutter run                    # Debug
flutter build apk --release    # Android release
flutter build ipa --release    # iOS release
```

### Generate Code

```bash
dart run build_runner build    # Build once
dart run build_runner watch    # Watch mode
```

## Configuration

### Built-in Presets

Edit `assets/built_in_presets.json`:

```json
{
  "presets": [
    {
      "name": "Custom",
      "category": "General",
      "settings": {
        "encoder": "h264",
        "crf": 28,
        "preset": "fast",
        "container": "mp4"
      }
    }
  ]
}
```

### Android Permissions

`android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.READ_MEDIA_VIDEO" />
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE" />
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PROCESSING" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

### iOS Permissions

`ios/Runner/Info.plist`:

```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Access videos for transcoding</string>
<key>NSPhotoLibraryAddUsageDescription</key>
<string>Save transcoded videos</string>
<key>UIBackgroundModes</key>
<array>
  <string>audio</string>
  <string>processing</string>
</array>
```

## Debugging

### FFmpeg Logging

In `queue_controller.dart`:

```dart
FFmpegKitConfig.enableStatisticsCallback((stats) {
  print('Time: ${stats.getTime()}ms, Speed: ${stats.getSpeed()}x');
});
```

### Common Issues

1. **MissingPluginException on Windows/Web**: FFmpegKit only on Android/iOS/macOS; check `isFFmpegSupported` in `platform_support.dart`
2. **Bitrate Out of Range**: AudioSettingsController clamps to codec min/max; see `audio_enums.dart`
3. **Multiple Burn-in**: SubtitleSettingsController enforces single burn-in; switch others to soft-mux
4. **Invalid Filter**: VideoSettingsState.buildFilterGraph() combines filters; inspect FFmpeg logs

## File Structure

```
lib/
├── core/
│   ├── database/
│   │   ├── collections/ (TranscodeJob, CustomPreset, VideoMetadata, AppSettings)
│   │   ├── enums/ (TranscodeJobStatus, AppThemePreference)
│   │   ├── providers/ (Isar, repositories)
│   │   └── repositories/
│   └── utils/ (platform_support, ffmpeg_command_builder)
├── features/
│   ├── source/ (file selection, probing)
│   ├── video/ (codec, quality, filters)
│   ├── audio/ (per-track audio)
│   ├── subtitles/ (soft-mux, burn-in, SRT)
│   ├── presets/ (built-in, custom)
│   └── queue/ (execution, progress)
├── shared/
│   ├── layout/ (app_shell, adaptive nav)
│   ├── widgets/ (reusable UI components)
│   └── routing/ (app_router)
└── main.dart, app.dart
```

## Contributing

1. Follow three-layer feature architecture
2. Use immutable state with `copyWith`
3. Use Riverpod Notifier for all state
4. Test on both Android and iOS

## License

GNU General Public License v3.0 (GPLv3)

## Acknowledgments

- **HandBrake**: Workflow inspiration
- **FFmpeg**: Video encoding
- **Flutter**: UI framework
- **Riverpod**: State management
- **Isar**: Local persistence
