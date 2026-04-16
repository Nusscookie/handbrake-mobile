import 'dart:io';

import 'package:permission_handler/permission_handler.dart';

/// Centralized permission checks used before key operations.
abstract final class PlatformPermissions {
  /// Request storage read permission (needed for file_picker on older Android).
  /// Returns true if granted or not needed on this platform.
  static Future<bool> ensureStorageRead() async {
    if (!Platform.isAndroid) return true;

    // Android 13+ uses granular media permissions; READ_MEDIA_VIDEO is
    // auto-granted at install on API 33+ for file_picker usage.
    // For API < 33, we need READ_EXTERNAL_STORAGE.
    final status = await Permission.storage.status;
    if (status.isGranted) return true;

    // On API 33+ this will immediately return granted.
    final result = await Permission.storage.request();
    return result.isGranted;
  }

  /// Request notification permission (Android 13+).
  static Future<bool> ensureNotifications() async {
    if (!Platform.isAndroid) return true;
    final status = await Permission.notification.status;
    if (status.isGranted) return true;
    final result = await Permission.notification.request();
    return result.isGranted;
  }
}
