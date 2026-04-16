import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transcoder/features/video/application/video_settings_controller.dart';
import 'package:transcoder/features/video/domain/video_enums.dart';
import 'package:transcoder/features/video/domain/video_settings_state.dart';
import 'package:transcoder/shared/widgets/labeled_dropdown.dart';
import 'package:transcoder/shared/widgets/section_card.dart';

class VideoScreen extends ConsumerWidget {
  const VideoScreen({super.key});

  static const double _wideBreakpoint = 720;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(videoSettingsControllerProvider);
    final ctrl = ref.read(videoSettingsControllerProvider.notifier);
    final isWide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;

    final encoderCards = <Widget>[
      _ContainerSection(state: s, ctrl: ctrl),
      _EncoderSection(state: s, ctrl: ctrl),
      if (s.supportsPresetTune) _PresetTuneSection(state: s, ctrl: ctrl),
      _QualitySection(state: s, ctrl: ctrl),
      _ResolutionSection(state: s, ctrl: ctrl),
    ];

    final filterCards = <Widget>[
      _CropSection(state: s, ctrl: ctrl),
      _FiltersSection(state: s, ctrl: ctrl),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Video')),
      body: isWide
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [...encoderCards, const SizedBox(height: 16)],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    children: [...filterCards, const SizedBox(height: 16)],
                  ),
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                ...encoderCards,
                ...filterCards,
                const SizedBox(height: 16),
              ],
            ),
    );
  }
}

// ---------------------------------------------------------------------------
// Container
// ---------------------------------------------------------------------------

class _ContainerSection extends StatelessWidget {
  const _ContainerSection({required this.state, required this.ctrl});
  final VideoSettingsState state;
  final VideoSettingsController ctrl;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Output Format',
      icon: Icons.inventory_2_outlined,
      children: [
        SegmentedButton<OutputContainer>(
          segments: OutputContainer.values
              .map((c) => ButtonSegment(value: c, label: Text(c.label)))
              .toList(),
          selected: {state.container},
          onSelectionChanged: (v) => ctrl.setContainer(v.first),
          showSelectedIcon: false,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Encoder
// ---------------------------------------------------------------------------

class _EncoderSection extends StatelessWidget {
  const _EncoderSection({required this.state, required this.ctrl});
  final VideoSettingsState state;
  final VideoSettingsController ctrl;

  @override
  Widget build(BuildContext context) {
    final profiles = EncoderProfile.forEncoder(state.encoder);

    return SectionCard(
      title: 'Video Encoder',
      icon: Icons.videocam_outlined,
      children: [
        LabeledDropdown<VideoEncoder>(
          label: 'Encoder',
          value: state.encoder,
          items: VideoEncoder.values
              .map((e) => DropdownMenuItem(value: e, child: Text(e.label)))
              .toList(),
          onChanged: (v) {
            if (v != null) ctrl.setEncoder(v);
          },
        ),
        if (profiles.length > 1) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: LabeledDropdown<EncoderProfile>(
                  label: 'Profile',
                  value: state.profile,
                  items: profiles
                      .map((p) =>
                          DropdownMenuItem(value: p, child: Text(p.label)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) ctrl.setProfile(v);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: LabeledDropdown<EncoderLevel>(
                  label: 'Level',
                  value: state.level,
                  items: EncoderLevel.values
                      .map((l) =>
                          DropdownMenuItem(value: l, child: Text(l.label)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) ctrl.setLevel(v);
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Preset / Tune (x264 / x265 only)
// ---------------------------------------------------------------------------

class _PresetTuneSection extends StatelessWidget {
  const _PresetTuneSection({required this.state, required this.ctrl});
  final VideoSettingsState state;
  final VideoSettingsController ctrl;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Encoder Preset & Tune',
      icon: Icons.tune_outlined,
      children: [
        LabeledDropdown<EncoderPreset>(
          label: 'Preset (speed ↔ quality)',
          value: state.preset,
          items: EncoderPreset.values
              .map((p) => DropdownMenuItem(value: p, child: Text(p.label)))
              .toList(),
          onChanged: (v) {
            if (v != null) ctrl.setPreset(v);
          },
        ),
        const SizedBox(height: 12),
        LabeledDropdown<EncoderTune>(
          label: 'Tune',
          value: state.tune,
          items: EncoderTune.values
              .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
              .toList(),
          onChanged: (v) {
            if (v != null) ctrl.setTune(v);
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Quality
// ---------------------------------------------------------------------------

class _QualitySection extends StatelessWidget {
  const _QualitySection({required this.state, required this.ctrl});
  final VideoSettingsState state;
  final VideoSettingsController ctrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCrf = state.qualityMode == QualityMode.constantQuality;

    return SectionCard(
      title: 'Quality',
      icon: Icons.high_quality_outlined,
      children: [
        // Mode selector
        SegmentedButton<QualityMode>(
          segments: QualityMode.values
              .map((m) => ButtonSegment(value: m, label: Text(m.label)))
              .toList(),
          selected: {state.qualityMode},
          onSelectionChanged: (v) => ctrl.setQualityMode(v.first),
          showSelectedIcon: false,
        ),
        const SizedBox(height: 16),

        if (isCrf) ...[
          // CRF slider
          Row(
            children: [
              SizedBox(
                width: 36,
                child: Text(
                  '${state.crf}',
                  style: theme.textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Slider(
                  value: state.crf.toDouble(),
                  min: 0,
                  max: state.maxCrf.toDouble(),
                  divisions: state.maxCrf,
                  label: '${state.crf}',
                  onChanged: (v) => ctrl.setCrf(v.round()),
                ),
              ),
            ],
          ),
          // Scale labels
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Low Quality',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.outline)),
                Text('Lossless',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: theme.colorScheme.outline)),
              ],
            ),
          ),
        ] else ...[
          // Average bitrate input
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  key: ValueKey('abr_${state.averageBitrate}'),
                  initialValue: state.averageBitrate.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Bitrate (kbps)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  onFieldSubmitted: (v) {
                    final parsed = int.tryParse(v);
                    if (parsed != null) ctrl.setAverageBitrate(parsed);
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Resolution & Frame Rate
// ---------------------------------------------------------------------------

class _ResolutionSection extends StatelessWidget {
  const _ResolutionSection({required this.state, required this.ctrl});
  final VideoSettingsState state;
  final VideoSettingsController ctrl;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Resolution & Frame Rate',
      icon: Icons.aspect_ratio_outlined,
      children: [
        Row(
          children: [
            Expanded(
              child: TextFormField(
                key: ValueKey('w_${state.width}'),
                initialValue: state.width?.toString() ?? '',
                decoration: const InputDecoration(
                  labelText: 'Width',
                  hintText: 'Auto',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onFieldSubmitted: (v) {
                  final parsed = int.tryParse(v);
                  ctrl.setWidth(parsed);
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.close, size: 16),
            ),
            Expanded(
              child: TextFormField(
                key: ValueKey('h_${state.height}'),
                initialValue: state.height?.toString() ?? '',
                decoration: const InputDecoration(
                  labelText: 'Height',
                  hintText: 'Auto',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onFieldSubmitted: (v) {
                  final parsed = int.tryParse(v);
                  ctrl.setHeight(parsed);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LabeledDropdown<FrameRateOption>(
          label: 'Frame Rate',
          value: state.frameRate,
          items: FrameRateOption.values
              .map(
                  (f) => DropdownMenuItem(value: f, child: Text(f.label)))
              .toList(),
          onChanged: (v) {
            if (v != null) ctrl.setFrameRate(v);
          },
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Cropping
// ---------------------------------------------------------------------------

class _CropSection extends StatelessWidget {
  const _CropSection({required this.state, required this.ctrl});
  final VideoSettingsState state;
  final VideoSettingsController ctrl;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Cropping',
      icon: Icons.crop_outlined,
      children: [
        SwitchListTile(
          title: const Text('Automatic'),
          value: state.autoCrop,
          onChanged: ctrl.setAutoCrop,
          contentPadding: EdgeInsets.zero,
        ),
        if (!state.autoCrop) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(child: _cropField('Top', state.cropTop, ctrl.setCropTop)),
              const SizedBox(width: 8),
              Expanded(
                  child:
                      _cropField('Bottom', state.cropBottom, ctrl.setCropBottom)),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                  child: _cropField('Left', state.cropLeft, ctrl.setCropLeft)),
              const SizedBox(width: 8),
              Expanded(
                  child:
                      _cropField('Right', state.cropRight, ctrl.setCropRight)),
            ],
          ),
        ],
      ],
    );
  }

  Widget _cropField(String label, int value, ValueChanged<int> onChanged) {
    return TextFormField(
      key: ValueKey('crop_${label}_$value'),
      initialValue: value.toString(),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      onFieldSubmitted: (v) {
        final parsed = int.tryParse(v);
        if (parsed != null) onChanged(parsed);
      },
    );
  }
}

// ---------------------------------------------------------------------------
// Filters
// ---------------------------------------------------------------------------

class _FiltersSection extends StatelessWidget {
  const _FiltersSection({required this.state, required this.ctrl});
  final VideoSettingsState state;
  final VideoSettingsController ctrl;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Filters',
      icon: Icons.filter_vintage_outlined,
      children: [
        LabeledDropdown<DeinterlaceMode>(
          label: 'Deinterlace',
          value: state.deinterlace,
          items: DeinterlaceMode.values
              .map((d) => DropdownMenuItem(value: d, child: Text(d.label)))
              .toList(),
          onChanged: (v) {
            if (v != null) ctrl.setDeinterlace(v);
          },
        ),
        const SizedBox(height: 12),
        LabeledDropdown<DenoiseMode>(
          label: 'Denoise',
          value: state.denoise,
          items: DenoiseMode.values
              .map((d) => DropdownMenuItem(value: d, child: Text(d.label)))
              .toList(),
          onChanged: (v) {
            if (v != null) ctrl.setDenoise(v);
          },
        ),
        const SizedBox(height: 12),
        LabeledDropdown<SharpenMode>(
          label: 'Sharpen',
          value: state.sharpen,
          items: SharpenMode.values
              .map((d) => DropdownMenuItem(value: d, child: Text(d.label)))
              .toList(),
          onChanged: (v) {
            if (v != null) ctrl.setSharpen(v);
          },
        ),
        const SizedBox(height: 12),
        LabeledDropdown<RotationOption>(
          label: 'Rotation / Flip',
          value: state.rotation,
          items: RotationOption.values
              .map((r) => DropdownMenuItem(value: r, child: Text(r.label)))
              .toList(),
          onChanged: (v) {
            if (v != null) ctrl.setRotation(v);
          },
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          title: const Text('Grayscale'),
          subtitle: const Text('Convert to black & white'),
          value: state.grayscale,
          onChanged: ctrl.setGrayscale,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
