import 'dart:io';

/// Whether the current platform supports FFmpegKit (Android, iOS, macOS only).
bool get isFFmpegSupported =>
    Platform.isAndroid || Platform.isIOS || Platform.isMacOS;

/// A human-readable message when FFmpegKit isn't available.
const String kUnsupportedPlatformMessage =
    'Video transcoding is only supported on Android, iOS, and macOS.\n\n'
    'FFmpegKit does not have a Windows or Linux implementation. '
    'Please run this app on a mobile device or emulator.';
