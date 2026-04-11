import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:transcoder/features/source/application/source_controller.dart';
import 'package:transcoder/features/source/presentation/widgets/source_metadata_panel.dart';

/// Source file picker, FFprobe metadata, and structured source info.
class SourceScreen extends ConsumerWidget {
  const SourceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(sourceControllerProvider);
    final controller = ref.read(sourceControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Source'),
        actions: [
          if (state.hasSource)
            IconButton(
              tooltip: 'Clear',
              onPressed: state.isBusy ? null : controller.clear,
              icon: const Icon(Icons.close),
            ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              FilledButton.icon(
                onPressed: state.isBusy ? null : controller.pickAndProbe,
                icon: const Icon(Icons.folder_open),
                label: const Text('Choose video'),
              ),
              if (state.path != null) ...[
                const SizedBox(height: 16),
                Text(
                  p.basename(state.path!),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                SelectableText(
                  state.path!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (state.hasSource && state.summary != null) ...[
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: state.isBusy ? null : controller.reprobe,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Re-scan file'),
                  ),
                ],
              ],
              if (state.errorMessage != null) ...[
                const SizedBox(height: 16),
                Material(
                  color: Theme.of(context).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: SelectableText(
                      state.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ),
              ],
              if (state.summary != null) ...[
                const SizedBox(height: 16),
                SourceMetadataPanel(summary: state.summary!),
              ],
              if (!state.hasSource && state.errorMessage == null)
                Padding(
                  padding: const EdgeInsets.only(top: 32),
                  child: Text(
                    'Pick a video file to inspect streams and metadata. '
                    'Results are cached locally for faster re-open.',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
          if (state.isBusy)
            const Positioned(
              left: 0,
              right: 0,
              top: 0,
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
