import 'package:ffmpeg_kit_flutter_full_gpl/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:file_picker/file_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:transcoder/core/database/collections/video_metadata.dart';
import 'package:transcoder/core/database/providers/application_isar_provider.dart';
import 'package:transcoder/core/utils/media_probe_parser.dart';
import 'package:transcoder/core/utils/platform_support.dart';
import 'package:transcoder/core/utils/probe_json_codec.dart';
import 'package:transcoder/features/source/domain/source_state.dart';

part 'source_controller.g.dart';

const _videoExtensions = <String>[
  'mp4',
  'mkv',
  'mov',
  'avi',
  'webm',
  'ts',
  'm4v',
  'wmv',
  'flv',
  'mpeg',
  'mpg',
  '3gp',
  'ogv',
];

@Riverpod(keepAlive: true)
class SourceController extends _$SourceController {
  @override
  SourceState build() => const SourceState();

  Future<void> pickAndProbe() async {
    state = state.copyWith(isBusy: true, clearError: true);
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: _videoExtensions,
        compressionQuality: 0,
      );
      if (result == null || result.files.isEmpty) {
        state = state.copyWith(isBusy: false);
        return;
      }
      final path = result.files.single.path;
      if (path == null || path.isEmpty) {
        state = state.copyWith(
          isBusy: false,
          errorMessage: 'Could not read a file path on this platform.',
        );
        return;
      }
      await probePath(path);
    } catch (e) {
      state = state.copyWith(isBusy: false, errorMessage: e.toString());
    }
  }

  Future<void> reprobe() async {
    final path = state.path;
    if (path == null) return;
    await probePath(path);
  }

  Future<void> probePath(String path) async {
    state = state.copyWith(
      isBusy: true,
      clearError: true,
      path: path,
      clearSummary: true,
    );

    // Guard: FFmpegKit only works on Android/iOS/macOS.
    if (!isFFmpegSupported) {
      state = state.copyWith(
        isBusy: false,
        errorMessage: kUnsupportedPlatformMessage,
        clearSummary: true,
      );
      return;
    }

    try {
      final session = await FFprobeKit.getMediaInformation(path);
      final code = await session.getReturnCode();
      final media = session.getMediaInformation();

      if (!ReturnCode.isSuccess(code) || media == null) {
        final logs = await session.getLogsAsString();
        final detail = logs.trim().isEmpty ? 'FFprobe failed.' : logs;
        state = state.copyWith(
          isBusy: false,
          errorMessage: detail,
          summary: null,
          rawProbeJson: null,
        );
        return;
      }

      final summary = MediaProbeParser.parse(media);
      final json = encodeProbeMap(media.getAllProperties());

      try {
        final repos = await ref.read(databaseRepositoriesProvider.future);
        await repos.videoMetadata.upsertBySourcePath(
          VideoMetadata()
            ..sourcePath = path
            ..probedAt = DateTime.now()
            ..probeJson = json,
        );
      } catch (_) {
        // Cache is best-effort; source UI still works without Isar.
      }

      state = SourceState(
        path: path,
        summary: summary,
        rawProbeJson: json,
        isBusy: false,
      );
    } catch (e) {
      state = state.copyWith(
        isBusy: false,
        errorMessage: e.toString(),
        clearSummary: true,
      );
    }
  }

  void clear() {
    state = const SourceState();
  }
}
