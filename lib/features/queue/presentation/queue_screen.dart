import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:transcoder/core/database/collections/transcode_job.dart';
import 'package:transcoder/core/database/enums/transcode_job_status.dart';
import 'package:transcoder/features/queue/application/queue_controller.dart';
import 'package:transcoder/features/queue/domain/queue_state.dart';
import 'package:transcoder/features/source/application/source_controller.dart';

class QueueScreen extends ConsumerWidget {
  const QueueScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueState = ref.watch(queueControllerProvider);
    final ctrl = ref.read(queueControllerProvider.notifier);
    final hasSource = ref.watch(
      sourceControllerProvider.select((s) => s.hasSource),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue'),
        actions: [
          if (queueState.jobs.any(_isFinished))
            IconButton(
              icon: const Icon(Icons.cleaning_services_outlined),
              tooltip: 'Clear finished',
              onPressed: () => ctrl.clearFinished(),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Add to queue button.
          if (hasSource)
            FloatingActionButton.extended(
              heroTag: 'add',
              onPressed: () async {
                await ctrl.addCurrentToQueue();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Job added to queue')),
                  );
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add to Queue'),
            ),
          if (hasSource) const SizedBox(height: 12),
          // Start queue button.
          if (!queueState.isProcessing &&
              queueState.jobs.any((j) => j.status == TranscodeJobStatus.pending))
            FloatingActionButton.extended(
              heroTag: 'start',
              onPressed: () => ctrl.startQueue(),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start'),
            ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar (visible when encoding).
          if (queueState.isProcessing)
            _ProgressPanel(
              progress: queueState.progress,
              activeJob: _findActiveJob(queueState),
              onCancel: () => ctrl.cancelCurrent(),
            ),

          // Job list.
          Expanded(
            child: queueState.jobs.isEmpty
                ? const _EmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 4, bottom: 100),
                    itemCount: queueState.jobs.length,
                    itemBuilder: (context, index) {
                      final job = queueState.jobs[index];
                      return _JobTile(
                        job: job,
                        isActive: job.id == queueState.activeJobId,
                        onRemove: job.status != TranscodeJobStatus.running
                            ? () => ctrl.removeJob(job.id)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  bool _isFinished(TranscodeJob j) =>
      j.status == TranscodeJobStatus.completed ||
      j.status == TranscodeJobStatus.failed ||
      j.status == TranscodeJobStatus.cancelled;

  TranscodeJob? _findActiveJob(QueueState qs) {
    if (qs.activeJobId == null) return null;
    try {
      return qs.jobs.firstWhere((j) => j.id == qs.activeJobId);
    } catch (_) {
      return null;
    }
  }
}

// ---------------------------------------------------------------------------
// Progress panel (persistent top area during encoding)
// ---------------------------------------------------------------------------

class _ProgressPanel extends StatelessWidget {
  const _ProgressPanel({
    required this.progress,
    required this.activeJob,
    required this.onCancel,
  });

  final EncodeProgress progress;
  final TranscodeJob? activeJob;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final jobName = activeJob?.displayName ?? 'Encoding...';

    return Container(
      width: double.infinity,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job name + cancel button.
          Row(
            children: [
              Expanded(
                child: Text(
                  jobName,
                  style: theme.textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              TextButton.icon(
                onPressed: onCancel,
                icon: const Icon(Icons.cancel_outlined, size: 18),
                label: const Text('Cancel'),
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Progress bar.
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress.fraction > 0 ? progress.fraction : null,
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 8),

          // Stats row.
          Row(
            children: [
              _StatChip(
                label: '${progress.percent}%',
                icon: Icons.percent,
              ),
              const SizedBox(width: 12),
              _StatChip(
                label: '${progress.fps.toStringAsFixed(1)} fps',
                icon: Icons.speed,
              ),
              const SizedBox(width: 12),
              _StatChip(
                label: '${progress.speed.toStringAsFixed(2)}x',
                icon: Icons.fast_forward,
              ),
              if (progress.eta != null) ...[
                const SizedBox(width: 12),
                _StatChip(
                  label: 'ETA ${_formatDuration(progress.eta!)}',
                  icon: Icons.timer_outlined,
                ),
              ],
            ],
          ),

          // Time progress.
          const SizedBox(height: 4),
          Text(
            '${_formatDuration(progress.currentTime)} / '
            '${_formatDuration(progress.totalDuration)}',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }

  static String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return '$h:$m:$s';
    return '$m:$s';
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.icon});
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.primary),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.labelMedium),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Job tile
// ---------------------------------------------------------------------------

class _JobTile extends StatelessWidget {
  const _JobTile({
    required this.job,
    required this.isActive,
    this.onRemove,
  });

  final TranscodeJob job;
  final bool isActive;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      elevation: isActive ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isActive
            ? BorderSide(color: theme.colorScheme.primary, width: 1.5)
            : BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            _statusIcon(theme),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.displayName ?? p.basename(job.inputPath),
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _subtitle(),
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.outline),
                  ),
                  if (job.errorMessage != null &&
                      job.status == TranscodeJobStatus.failed) ...[
                    const SizedBox(height: 4),
                    Text(
                      job.errorMessage!,
                      style: theme.textTheme.bodySmall
                          ?.copyWith(color: theme.colorScheme.error),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (onRemove != null)
              IconButton(
                icon: const Icon(Icons.close, size: 18),
                tooltip: 'Remove',
                onPressed: onRemove,
              ),
          ],
        ),
      ),
    );
  }

  Widget _statusIcon(ThemeData theme) {
    switch (job.status) {
      case TranscodeJobStatus.pending:
        return Icon(Icons.schedule, color: theme.colorScheme.outline);
      case TranscodeJobStatus.running:
        return SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            color: theme.colorScheme.primary,
          ),
        );
      case TranscodeJobStatus.completed:
        return Icon(Icons.check_circle, color: theme.colorScheme.primary);
      case TranscodeJobStatus.failed:
        return Icon(Icons.error, color: theme.colorScheme.error);
      case TranscodeJobStatus.cancelled:
        return Icon(Icons.cancel, color: theme.colorScheme.outline);
    }
  }

  String _subtitle() {
    switch (job.status) {
      case TranscodeJobStatus.pending:
        return 'Pending';
      case TranscodeJobStatus.running:
        return 'Encoding...';
      case TranscodeJobStatus.completed:
        final t = job.completedAt;
        if (t != null) {
          return 'Completed \u2022 ${t.hour.toString().padLeft(2, '0')}:'
              '${t.minute.toString().padLeft(2, '0')}';
        }
        return 'Completed';
      case TranscodeJobStatus.failed:
        return 'Failed';
      case TranscodeJobStatus.cancelled:
        return 'Cancelled';
    }
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.queue_outlined, size: 48, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'No jobs in the queue.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 4),
          Text(
            'Configure your settings, then tap "Add to Queue".',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.outline),
          ),
        ],
      ),
    );
  }
}
