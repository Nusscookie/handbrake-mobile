import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:transcoder/core/utils/media_probe_parser.dart';
import 'package:transcoder/features/audio/domain/audio_enums.dart';
import 'package:transcoder/features/audio/domain/audio_settings_state.dart';

part 'audio_settings_controller.g.dart';

@Riverpod(keepAlive: true)
class AudioSettingsController extends _$AudioSettingsController {
  @override
  AudioSettingsState build() => const AudioSettingsState();

  /// Populate track list from source probe data.
  void loadFromSource(List<AudioTrackSummary> sourceTracks) {
    final configs = sourceTracks.map((t) {
      final mixdown = _guessMixdown(t.channels);
      return AudioTrackConfig(
        sourceIndex: t.index,
        sourceLabel: AudioTrackConfig.labelFrom(t),
        mixdown: mixdown,
      );
    }).toList();
    state = AudioSettingsState(tracks: configs);
  }

  void setTrackAction(int index, AudioTrackAction action) {
    if (!_validIndex(index)) return;
    state = state.replaceTrack(index, state.tracks[index].copyWith(action: action));
  }

  void setTrackCodec(int index, AudioCodec codec) {
    if (!_validIndex(index)) return;
    final track = state.tracks[index];
    // When codec changes, clamp bitrate to new codec's valid range.
    final clampedBitrate = codec.isLossless
        ? 0
        : track.bitrate.clamp(codec.minBitrate, codec.maxBitrate);
    state = state.replaceTrack(
      index,
      track.copyWith(
        codec: codec,
        bitrate: clampedBitrate == 0 ? codec.defaultBitrate : clampedBitrate,
      ),
    );
  }

  void setTrackBitrate(int index, int kbps) {
    if (!_validIndex(index)) return;
    final track = state.tracks[index];
    final clamped = kbps.clamp(track.codec.minBitrate, track.codec.maxBitrate);
    state = state.replaceTrack(index, track.copyWith(bitrate: clamped));
  }

  void setTrackMixdown(int index, AudioMixdown mixdown) {
    if (!_validIndex(index)) return;
    state = state.replaceTrack(index, state.tracks[index].copyWith(mixdown: mixdown));
  }

  void reset() {
    state = const AudioSettingsState();
  }

  bool _validIndex(int index) => index >= 0 && index < state.tracks.length;

  static AudioMixdown _guessMixdown(int? channels) {
    switch (channels) {
      case 1:
        return AudioMixdown.mono;
      case 6:
        return AudioMixdown.surround51;
      case 8:
        return AudioMixdown.surround71;
      default:
        return AudioMixdown.stereo;
    }
  }
}
