import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transcoder/features/audio/application/audio_settings_controller.dart';
import 'package:transcoder/features/audio/domain/audio_enums.dart';
import 'package:transcoder/features/audio/domain/audio_settings_state.dart';
import 'package:transcoder/features/source/application/source_controller.dart';
import 'package:transcoder/shared/widgets/labeled_dropdown.dart';
import 'package:transcoder/shared/widgets/section_card.dart';

class AudioScreen extends ConsumerWidget {
  const AudioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final source = ref.watch(sourceControllerProvider);
    final audioState = ref.watch(audioSettingsControllerProvider);
    final ctrl = ref.read(audioSettingsControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio'),
        actions: [
          if (source.summary != null && source.summary!.audioTracks.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reload tracks from source',
              onPressed: () => ctrl.loadFromSource(source.summary!.audioTracks),
            ),
        ],
      ),
      body: _buildBody(context, source, audioState, ctrl),
    );
  }

  Widget _buildBody(
    BuildContext context,
    dynamic source,
    AudioSettingsState audioState,
    AudioSettingsController ctrl,
  ) {
    if (!source.hasSource) {
      return const _EmptyState(
        icon: Icons.audiotrack_outlined,
        message: 'Open a source file first to see audio tracks.',
      );
    }

    if (audioState.tracks.isEmpty &&
        source.summary != null &&
        source.summary!.audioTracks.isNotEmpty) {
      // Auto-load on first visit after source probe.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ctrl.loadFromSource(source.summary!.audioTracks);
      });
      return const Center(child: CircularProgressIndicator());
    }

    if (audioState.tracks.isEmpty) {
      return const _EmptyState(
        icon: Icons.music_off_outlined,
        message: 'No audio tracks detected in this file.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: audioState.tracks.length,
      itemBuilder: (context, index) => _AudioTrackCard(
        index: index,
        config: audioState.tracks[index],
        ctrl: ctrl,
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Per-track card
// ---------------------------------------------------------------------------

class _AudioTrackCard extends StatelessWidget {
  const _AudioTrackCard({
    required this.index,
    required this.config,
    required this.ctrl,
  });

  final int index;
  final AudioTrackConfig config;
  final AudioSettingsController ctrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isRemoved = config.action == AudioTrackAction.remove;
    final isPassthrough = config.action == AudioTrackAction.passthrough;

    return SectionCard(
      title: config.sourceLabel,
      icon: Icons.audiotrack,
      children: [
        // Action selector
        SegmentedButton<AudioTrackAction>(
          segments: AudioTrackAction.values
              .map((a) => ButtonSegment(value: a, label: Text(a.label)))
              .toList(),
          selected: {config.action},
          onSelectionChanged: (v) => ctrl.setTrackAction(index, v.first),
          showSelectedIcon: false,
        ),

        if (isRemoved)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'This track will be excluded from the output.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ),

        if (isPassthrough)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              'Audio will be copied as-is without re-encoding.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
          ),

        // Encode settings
        if (!isRemoved && !isPassthrough) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: LabeledDropdown<AudioCodec>(
                  label: 'Codec',
                  value: config.codec,
                  items: AudioCodec.values
                      .map((c) =>
                          DropdownMenuItem(value: c, child: Text(c.label)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) ctrl.setTrackCodec(index, v);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LabeledDropdown<AudioMixdown>(
                  label: 'Mixdown',
                  value: config.mixdown,
                  items: AudioMixdown.values
                      .map((m) =>
                          DropdownMenuItem(value: m, child: Text(m.label)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) ctrl.setTrackMixdown(index, v);
                  },
                ),
              ),
            ],
          ),
          if (!config.codec.isLossless) ...[
            const SizedBox(height: 16),
            _BitrateSlider(
              codec: config.codec,
              value: config.bitrate,
              onChanged: (v) => ctrl.setTrackBitrate(index, v),
            ),
          ],
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Bitrate slider
// ---------------------------------------------------------------------------

class _BitrateSlider extends StatelessWidget {
  const _BitrateSlider({
    required this.codec,
    required this.value,
    required this.onChanged,
  });

  final AudioCodec codec;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bitrate', style: theme.textTheme.bodySmall),
        const SizedBox(height: 4),
        Row(
          children: [
            SizedBox(
              width: 56,
              child: Text(
                '$value kbps',
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Expanded(
              child: Slider(
                value: value.toDouble(),
                min: codec.minBitrate.toDouble(),
                max: codec.maxBitrate.toDouble(),
                divisions: ((codec.maxBitrate - codec.minBitrate) / 8).round().clamp(1, 100),
                label: '$value kbps',
                onChanged: (v) => onChanged(v.round()),
              ),
            ),
          ],
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
          Text(message, style: theme.textTheme.bodyLarge),
        ],
      ),
    );
  }
}
