/// Persisted queue job lifecycle (mirrors runtime FFmpeg execution).
enum TranscodeJobStatus {
  pending,
  running,
  completed,
  failed,
  cancelled,
}
