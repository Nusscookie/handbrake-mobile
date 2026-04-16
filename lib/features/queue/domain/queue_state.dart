import 'package:transcoder/core/database/collections/transcode_job.dart';

/// Live progress info for the currently-running encode.
class EncodeProgress {
  const EncodeProgress({
    this.fraction = 0,
    this.fps = 0,
    this.currentTime = Duration.zero,
    this.totalDuration = Duration.zero,
    this.eta,
    this.speed = 0,
  });

  /// 0.0 → 1.0
  final double fraction;
  final double fps;
  final Duration currentTime;
  final Duration totalDuration;
  final Duration? eta;

  /// Encoding speed (e.g. 1.5× means 1.5 seconds of video per wall-clock second).
  final double speed;

  int get percent => (fraction * 100).round().clamp(0, 100);
}

/// Full queue UI state.
class QueueState {
  const QueueState({
    this.jobs = const [],
    this.activeJobId,
    this.progress = const EncodeProgress(),
    this.isProcessing = false,
  });

  final List<TranscodeJob> jobs;

  /// Isar ID of the job currently encoding, or null.
  final int? activeJobId;

  final EncodeProgress progress;
  final bool isProcessing;

  QueueState copyWith({
    List<TranscodeJob>? jobs,
    int? activeJobId,
    EncodeProgress? progress,
    bool? isProcessing,
    bool clearActiveJob = false,
  }) {
    return QueueState(
      jobs: jobs ?? this.jobs,
      activeJobId: clearActiveJob ? null : (activeJobId ?? this.activeJobId),
      progress: progress ?? this.progress,
      isProcessing: isProcessing ?? this.isProcessing,
    );
  }
}
