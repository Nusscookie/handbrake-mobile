import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:transcoder/core/utils/media_probe_parser.dart';
import 'package:transcoder/features/subtitles/domain/subtitle_enums.dart';
import 'package:transcoder/features/subtitles/domain/subtitle_settings_state.dart';

part 'subtitle_settings_controller.g.dart';

@Riverpod(keepAlive: true)
class SubtitleSettingsController extends _$SubtitleSettingsController {
  @override
  SubtitleSettingsState build() => const SubtitleSettingsState();

  /// Populate track list from source probe data.
  void loadFromSource(List<SubtitleTrackSummary> sourceTracks) {
    final configs = sourceTracks.map((t) {
      return SubtitleTrackConfig(
        sourceIndex: t.index,
        sourceLabel: SubtitleTrackConfig.labelFrom(t),
      );
    }).toList();
    state = SubtitleSettingsState(tracks: configs);
  }

  void setTrackAction(int index, SubtitleTrackAction action) {
    if (!_validIndex(index)) return;

    // Only one track can be burned in.
    // If user selects burn-in, clear any existing burn-in first.
    if (action == SubtitleTrackAction.burnIn) {
      final updated = state.tracks.asMap().entries.map((e) {
        if (e.key == index) {
          return e.value.copyWith(action: SubtitleTrackAction.burnIn);
        }
        if (e.value.action == SubtitleTrackAction.burnIn) {
          return e.value.copyWith(action: SubtitleTrackAction.soft);
        }
        return e.value;
      }).toList();
      state = SubtitleSettingsState(tracks: updated);
    } else {
      state = state.replaceTrack(index, state.tracks[index].copyWith(action: action));
    }
  }

  /// Add an external .srt file as a new subtitle track.
  void addExternalSrt(String filePath) {
    final fileName = filePath.split('/').last.split('\\').last;
    final config = SubtitleTrackConfig(
      sourceIndex: -1,
      sourceLabel: 'External \u2014 $fileName',
      isExternal: true,
      externalPath: filePath,
    );
    state = SubtitleSettingsState(tracks: [...state.tracks, config]);
  }

  /// Remove an external subtitle track by index.
  void removeTrack(int index) {
    if (!_validIndex(index)) return;
    final copy = List<SubtitleTrackConfig>.of(state.tracks);
    copy.removeAt(index);
    state = SubtitleSettingsState(tracks: copy);
  }

  void reset() {
    state = const SubtitleSettingsState();
  }

  bool _validIndex(int index) => index >= 0 && index < state.tracks.length;
}
