import 'package:flutter/material.dart';
import 'package:transcoder/core/utils/media_probe_parser.dart';

String _formatDuration(Duration? d) {
  if (d == null) return '—';
  final h = d.inHours;
  final m = d.inMinutes.remainder(60);
  final s = d.inSeconds.remainder(60);
  if (h > 0) {
    return '${h}h ${m.toString().padLeft(2, '0')}m ${s.toString().padLeft(2, '0')}s';
  }
  if (m > 0) {
    return '${m}m ${s.toString().padLeft(2, '0')}s';
  }
  return '${s}s';
}

String? _kbps(int? bps) {
  if (bps == null) return null;
  if (bps <= 0) return null;
  return '${(bps / 1000).round()} kbps';
}

String? _mb(int? bytes) {
  if (bytes == null) return null;
  if (bytes <= 0) return null;
  return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
}

class SourceMetadataPanel extends StatelessWidget {
  const SourceMetadataPanel({super.key, required this.summary});

  final SourceProbeSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final v = summary.video;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionCard(
          title: 'General',
          child: _PropertyTable(rows: [
            _Row('Container', summary.containerFormat ?? '—'),
            _Row('Duration', _formatDuration(summary.duration)),
            _Row('Size', _mb(summary.sizeBytes) ?? '—'),
            _Row('Bitrate', _kbps(summary.formatBitrateBps) ?? '—'),
          ]),
        ),
        _SectionCard(
          title: 'Video',
          child: v == null
              ? Text('No video stream', style: theme.textTheme.bodyMedium)
              : _PropertyTable(rows: [
                  _Row('Codec', v.codec),
                  _Row(
                    'Resolution',
                    v.width != null && v.height != null
                        ? '${v.width}×${v.height}'
                        : '—',
                  ),
                  _Row(
                    'Frame rate',
                    v.frameRate != null
                        ? '${v.frameRate!.toStringAsFixed(3)} fps'
                        : '—',
                  ),
                  _Row('Pixel format', v.pixelFormat ?? '—'),
                ]),
        ),
        _SectionCard(
          title: 'Audio tracks (${summary.audioTracks.length})',
          child: summary.audioTracks.isEmpty
              ? Text('None', style: theme.textTheme.bodyMedium)
              : Column(
                  children: summary.audioTracks.map((a) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Track ${a.index}: ${a.codec}',
                              style: theme.textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            _PropertyTable(rows: [
                              _Row('Language', a.language ?? 'unknown'),
                              _Row(
                                'Channels',
                                a.channels != null
                                    ? '${a.channels}${a.channelLayout != null ? ' (${a.channelLayout})' : ''}'
                                    : a.channelLayout ?? '—',
                              ),
                              _Row(
                                'Sample rate',
                                a.sampleRateHz != null
                                    ? '${a.sampleRateHz} Hz'
                                    : '—',
                              ),
                              _Row('Bitrate', _kbps(a.bitrateBps) ?? '—'),
                            ]),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
        ),
        _SectionCard(
          title: 'Subtitle tracks (${summary.subtitleTracks.length})',
          child: summary.subtitleTracks.isEmpty
              ? Text('None', style: theme.textTheme.bodyMedium)
              : Column(
                  children: summary.subtitleTracks.map((s) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      title: Text('Track ${s.index}: ${s.codec}'),
                      subtitle: Text('Language: ${s.language ?? 'unknown'}'),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _Row {
  const _Row(this.label, this.value);
  final String label;
  final String value;
}

class _PropertyTable extends StatelessWidget {
  const _PropertyTable({required this.rows});

  final List<_Row> rows;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2.2),
        1: FlexColumnWidth(3),
      },
      children: rows
          .map(
            (r) => TableRow(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 6, right: 8),
                  child: Text(r.label, style: style?.copyWith(color: style.color?.withValues(alpha: 0.7))),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(r.value, style: style),
                ),
              ],
            ),
          )
          .toList(),
    );
  }
}
