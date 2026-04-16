import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/ffmpeg_kit_config.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/return_code.dart';
import 'package:ffmpeg_kit_flutter_full_gpl/statistics.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:transcoder/core/database/collections/transcode_job.dart';
import 'package:transcoder/core/database/enums/transcode_job_status.dart';
import 'package:transcoder/core/database/providers/application_isar_provider.dart';
import 'package:transcoder/core/database/repositories/transcode_job_repository.dart';
import 'package:transcoder/core/utils/ffmpeg_command_builder.dart';
import 'package:transcoder/core/utils/platform_support.dart';
import 'package:transcoder/features/audio/application/audio_settings_controller.dart';
import 'package:transcoder/features/queue/domain/job_options_codec.dart';
import 'package:transcoder/features/queue/domain/queue_state.dart';
import 'package:transcoder/features/source/application/source_controller.dart';
import 'package:transcoder/features/subtitles/application/subtitle_settings_controller.dart';
import 'package:transcoder/features/video/application/video_settings_controller.dart';
import 'package:transcoder/features/video/domain/video_enums.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

part 'queue_controller.g.dart';

@Riverpod(keepAlive: true)
class QueueController extends _$QueueController {
  /// Session ID of the currently running FFmpeg encode (for cancellation).
  int? _activeSessionId;

  @override
  QueueState build() {
    _loadJobs();
    return const QueueState();
  }

  // -------------------------------------------------------------------------
  // Load persisted jobs from Isar.
  // -------------------------------------------------------------------------

  Future<void> _loadJobs() async {
    try {
      final repos = await ref.read(databaseRepositoriesProvider.future);
      final jobs = await repos.transcodeJobs.getAllOrderedByCreated();
      state = state.copyWith(jobs: jobs);
    } catch (_) {}
  }

  Future<void> refresh() => _loadJobs();

  // -------------------------------------------------------------------------
  // Add the current UI settings as a new queued job.
  // -------------------------------------------------------------------------

  Future<void> addCurrentToQueue() async {
    final source = ref.read(sourceControllerProvider);
    if (source.path == null) return;

    final video = ref.read(videoSettingsControllerProvider);
    final audio = ref.read(audioSettingsControllerProvider);
    final subs = ref.read(subtitleSettingsControllerProvider);

    final options = JobOptions(
      video: video,
      audioTracks: audio.tracks,
      subtitleTracks: subs.tracks,
    );

    final inputPath = source.path!;
    final baseName = p.basenameWithoutExtension(inputPath);
    final ext = _containerExtension(video.container);

    final outDir = await _outputDirectory();
    final outputPath = p.join(outDir, '${baseName}_transcoded.$ext');

    final job = TranscodeJob()
      ..inputPath = inputPath
      ..outputPath = outputPath
      ..status = TranscodeJobStatus.pending
      ..createdAt = DateTime.now()
      ..displayName = p.basename(inputPath)
      ..encodeOptionsJson = JobOptionsCodec.encode(options);

    final repos = await ref.read(databaseRepositoriesProvider.future);
    await repos.transcodeJobs.put(job);
    await _loadJobs();
  }

  // -------------------------------------------------------------------------
  // Start processing the queue sequentially.
  // -------------------------------------------------------------------------

  Future<void> startQueue() async {
    if (state.isProcessing) return;
    state = state.copyWith(isProcessing: true);

    // Keep screen on and CPU awake during encoding.
    try {
      await WakelockPlus.enable();
    } catch (_) {}

    final repos = await ref.read(databaseRepositoriesProvider.future);

    try {
      while (true) {
        final pending = await repos.transcodeJobs.getPendingOrRunningOrdered();
        final nextPending = pending
            .where((j) => j.status == TranscodeJobStatus.pending)
            .toList();
        if (nextPending.isEmpty) break;

        await _executeJob(nextPending.first, repos.transcodeJobs);
      }
    } finally {
      try {
        await WakelockPlus.disable();
      } catch (_) {}
    }

    state = state.copyWith(
      isProcessing: false,
      clearActiveJob: true,
      progress: const EncodeProgress(),
    );
  }

  // -------------------------------------------------------------------------
  // Execute a single job via FFmpegKit.
  // -------------------------------------------------------------------------

  Future<void> _executeJob(
    TranscodeJob job,
    TranscodeJobRepository jobRepo,
  ) async {
    // Mark running.
    job.status = TranscodeJobStatus.running;
    await jobRepo.put(job);
    state = state.copyWith(
      activeJobId: job.id,
      progress: const EncodeProgress(),
    );
    await _loadJobs();

    // Guard: FFmpegKit only works on Android/iOS/macOS.
    if (!isFFmpegSupported) {
      job.status = TranscodeJobStatus.failed;
      job.errorMessage = kUnsupportedPlatformMessage;
      await jobRepo.put(job);
      await _loadJobs();
      return;
    }

    try {
      final options = JobOptionsCodec.decode(job.encodeOptionsJson);

      // Try to get source duration from the currently loaded source.
      // If the source has changed, fall back to zero (progress bar still works
      // but won't show a percentage).
      final sourceState = ref.read(sourceControllerProvider);
      final totalDuration = sourceState.summary?.duration ?? Duration.zero;

      final args = FFmpegCommandBuilder(
        inputPath: job.inputPath,
        outputPath: job.outputPath ?? '',
        video: options.video,
        audioTracks: options.audioTracks,
        subtitleTracks: options.subtitleTracks,
      ).build();

      // Register statistics callback before executing.
      FFmpegKitConfig.enableStatisticsCallback((Statistics stats) {
        _onStatistics(stats, totalDuration);
      });

      // executeWithArguments is blocking (returns after encode completes).
      final session = await FFmpegKit.executeWithArguments(args);
      _activeSessionId = session.getSessionId();

      final returnCode = await session.getReturnCode();

      if (ReturnCode.isSuccess(returnCode)) {
        job.status = TranscodeJobStatus.completed;
        job.completedAt = DateTime.now();
      } else if (ReturnCode.isCancel(returnCode)) {
        job.status = TranscodeJobStatus.cancelled;
      } else {
        job.status = TranscodeJobStatus.failed;
        final logs = await session.getLogsAsString();
        job.errorMessage =
            logs.length > 500 ? logs.substring(logs.length - 500) : logs;
      }
    } catch (e) {
      job.status = TranscodeJobStatus.failed;
      job.errorMessage = e.toString();
    }

    await jobRepo.put(job);
    _activeSessionId = null;
    await _loadJobs();
  }

  // -------------------------------------------------------------------------
  // Parse FFmpeg statistics into EncodeProgress.
  // -------------------------------------------------------------------------

  void _onStatistics(Statistics stats, Duration totalDuration) {
    final timeMs = stats.getTime().toInt();
    if (timeMs <= 0) return;

    final currentTime = Duration(milliseconds: timeMs);
    final totalMs = totalDuration.inMilliseconds;

    final fraction =
        totalMs > 0 ? (timeMs.toDouble() / totalMs).clamp(0.0, 1.0) : 0.0;
    final fps = stats.getVideoFps();
    final speed = stats.getSpeed();

    Duration? eta;
    if (fraction > 0.001 && fraction < 1.0 && speed > 0) {
      final remainingMs = totalMs - timeMs;
      eta = Duration(milliseconds: (remainingMs / speed).round());
    }

    state = state.copyWith(
      progress: EncodeProgress(
        fraction: fraction,
        fps: fps,
        currentTime: currentTime,
        totalDuration: totalDuration,
        eta: eta,
        speed: speed,
      ),
    );
  }

  // -------------------------------------------------------------------------
  // Cancel the currently running encode.
  // -------------------------------------------------------------------------

  Future<void> cancelCurrent() async {
    final sid = _activeSessionId;
    if (sid != null) {
      await FFmpegKit.cancel(sid);
    }
  }

  // -------------------------------------------------------------------------
  // Remove a single job (only non-running).
  // -------------------------------------------------------------------------

  Future<void> removeJob(int jobId) async {
    final repos = await ref.read(databaseRepositoriesProvider.future);
    await repos.transcodeJobs.delete(jobId);
    await _loadJobs();
  }

  /// Remove all completed / failed / cancelled jobs.
  Future<void> clearFinished() async {
    final repos = await ref.read(databaseRepositoriesProvider.future);
    final toRemove = state.jobs.where((j) =>
        j.status == TranscodeJobStatus.completed ||
        j.status == TranscodeJobStatus.failed ||
        j.status == TranscodeJobStatus.cancelled);
    for (final j in toRemove) {
      await repos.transcodeJobs.delete(j.id);
    }
    await _loadJobs();
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------

  Future<String> _outputDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  static String _containerExtension(OutputContainer container) {
    switch (container) {
      case OutputContainer.mkv:
        return 'mkv';
      case OutputContainer.webm:
        return 'webm';
      case OutputContainer.mp4:
        return 'mp4';
    }
  }
}
