import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transcoder/features/presets/application/preset_controller.dart';
import 'package:transcoder/features/presets/domain/preset_codec.dart';
import 'package:transcoder/features/video/domain/video_enums.dart';

class PresetsScreen extends ConsumerWidget {
  const PresetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presetState = ref.watch(presetControllerProvider);
    final ctrl = ref.read(presetControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Presets')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSaveDialog(context, ctrl),
        icon: const Icon(Icons.save_outlined),
        label: const Text('Save Current'),
      ),
      body: presetState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : _PresetList(
              builtIn: presetState.builtIn,
              custom: presetState.custom,
              ctrl: ctrl,
            ),
    );
  }

  Future<void> _showSaveDialog(
      BuildContext context, PresetController ctrl) async {
    final nameCtrl = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Preset'),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Preset name',
            border: OutlineInputBorder(),
          ),
          onSubmitted: (v) => Navigator.pop(ctx, v.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, nameCtrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    nameCtrl.dispose();
    if (name != null && name.isNotEmpty) {
      await ctrl.saveCustom(name);
    }
  }
}

// ---------------------------------------------------------------------------
// Preset list (built-in + custom grouped)
// ---------------------------------------------------------------------------

class _PresetList extends StatelessWidget {
  const _PresetList({
    required this.builtIn,
    required this.custom,
    required this.ctrl,
  });

  final List<Preset> builtIn;
  final List<Preset> custom;
  final PresetController ctrl;

  @override
  Widget build(BuildContext context) {
    // Group built-in by category.
    final categories = <String, List<Preset>>{};
    for (final p in builtIn) {
      categories.putIfAbsent(p.category, () => []).add(p);
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        // Custom presets section.
        if (custom.isNotEmpty) ...[
          _SectionHeader(title: 'Custom Presets'),
          for (final p in custom)
            _PresetTile(
              preset: p,
              ctrl: ctrl,
              onDelete: p.dbId != null
                  ? () => _confirmDelete(context, p)
                  : null,
            ),
          const Divider(height: 32),
        ],

        // Built-in presets by category.
        for (final entry in categories.entries) ...[
          _SectionHeader(title: entry.key),
          for (final p in entry.value)
            _PresetTile(preset: p, ctrl: ctrl),
        ],
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, Preset preset) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Preset'),
        content: Text('Delete "${preset.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && preset.dbId != null) {
      await ctrl.deleteCustom(preset.dbId!);
    }
  }
}

// ---------------------------------------------------------------------------
// Section header
// ---------------------------------------------------------------------------

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Preset tile
// ---------------------------------------------------------------------------

class _PresetTile extends StatelessWidget {
  const _PresetTile({
    required this.preset,
    required this.ctrl,
    this.onDelete,
  });

  final Preset preset;
  final PresetController ctrl;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final s = preset.settings;
    final qualityLabel = s.qualityMode == QualityMode.constantQuality
        ? 'CRF ${s.crf}'
        : '${s.averageBitrate} kbps';
    final subtitle =
        '${s.encoder.label}  \u2022  $qualityLabel  \u2022  ${s.container.label}';

    return ListTile(
      leading: Icon(
        preset.isBuiltIn ? Icons.bookmark_outline : Icons.tune,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(preset.name),
      subtitle: Text(subtitle),
      trailing: onDelete != null
          ? IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            )
          : null,
      onTap: () {
        ctrl.applyPreset(preset);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Applied "${preset.name}"'),
            duration: const Duration(seconds: 2),
          ),
        );
      },
    );
  }
}
