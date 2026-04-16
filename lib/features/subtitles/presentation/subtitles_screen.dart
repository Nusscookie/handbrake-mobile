import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transcoder/features/source/application/source_controller.dart';
import 'package:transcoder/features/subtitles/application/subtitle_settings_controller.dart';
import 'package:transcoder/features/subtitles/domain/subtitle_enums.dart';
import 'package:transcoder/features/subtitles/domain/subtitle_settings_state.dart';
import 'package:transcoder/shared/widgets/section_card.dart';

class SubtitlesScreen extends ConsumerWidget {
  const SubtitlesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final source = ref.watch(sourceControllerProvider);
    final subState = ref.watch(subtitleSettingsControllerProvider);
    final ctrl = ref.read(subtitleSettingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Subtitles'),
        actions: [
          if (source.summary != null &&
              source.summary!.subtitleTracks.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reload tracks from source',
              onPressed: () =>
                  ctrl.loadFromSource(source.summary!.subtitleTracks),
            ),
        ],
      ),
      floatingActionButton: source.hasSource
          ? FloatingActionButton.extended(
              onPressed: () => _importSrt(ctrl),
              icon: const Icon(Icons.add),
              label: const Text('Import SRT'),
            )
          : null,
      body: _buildBody(context, source, subState, ctrl),
    );
  }

  Widget _buildBody(
    BuildContext context,
    dynamic source,
    SubtitleSettingsState subState,
    SubtitleSettingsController ctrl,
  ) {
    if (!source.hasSource) {
      return const _EmptyState(
        icon: Icons.subtitles_outlined,
        message: 'Open a source file first to see subtitle tracks.',
      );
    }

    if (subState.tracks.isEmpty &&
        source.summary != null &&
        source.summary!.subtitleTracks.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ctrl.loadFromSource(source.summary!.subtitleTracks);
      });
      return const Center(child: CircularProgressIndicator());
    }

    if (subState.tracks.isEmpty) {
      return const _EmptyState(
        icon: Icons.subtitles_off_outlined,
        message: 'No subtitle tracks detected.\nUse the + button to import an SRT file.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: subState.tracks.length,
      itemBuilder: (context, index) => _SubtitleTrackCard(
        index: index,
        config: subState.tracks[index],
        ctrl: ctrl,
      ),
    );
  }

  Future<void> _importSrt(SubtitleSettingsController ctrl) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['srt'],
    );
    if (result == null || result.files.isEmpty) return;
    final path = result.files.single.path;
    if (path != null && path.isNotEmpty) {
      ctrl.addExternalSrt(path);
    }
  }
}

// ---------------------------------------------------------------------------
// Per-track card
// ---------------------------------------------------------------------------

class _SubtitleTrackCard extends StatelessWidget {
  const _SubtitleTrackCard({
    required this.index,
    required this.config,
    required this.ctrl,
  });

  final int index;
  final SubtitleTrackConfig config;
  final SubtitleSettingsController ctrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRemoved = config.action == SubtitleTrackAction.remove;

    return SectionCard(
      title: config.sourceLabel,
      icon: config.isExternal ? Icons.file_open_outlined : Icons.subtitles,
      children: [
        Row(
          children: [
            Expanded(
              child: SegmentedButton<SubtitleTrackAction>(
                segments: SubtitleTrackAction.values
                    .map((a) => ButtonSegment(value: a, label: Text(a.label)))
                    .toList(),
                selected: {config.action},
                onSelectionChanged: (v) =>
                    ctrl.setTrackAction(index, v.first),
                showSelectedIcon: false,
              ),
            ),
            if (config.isExternal) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Remove external subtitle',
                onPressed: () => ctrl.removeTrack(index),
              ),
            ],
          ],
        ),

        const SizedBox(height: 8),

        if (isRemoved)
          Text(
            'This track will be excluded from the output.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.outline),
          )
        else if (config.action == SubtitleTrackAction.burnIn)
          Text(
            'Subtitles will be permanently rendered into the video. '
            'Only one track can be burned in.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.tertiary),
          )
        else
          Text(
            'Subtitles will be muxed as a selectable track.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.outline),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            message,
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
