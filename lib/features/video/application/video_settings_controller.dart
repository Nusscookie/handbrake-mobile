import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:transcoder/features/video/domain/video_enums.dart';
import 'package:transcoder/features/video/domain/video_settings_state.dart';

part 'video_settings_controller.g.dart';

@Riverpod(keepAlive: true)
class VideoSettingsController extends _$VideoSettingsController {
  @override
  VideoSettingsState build() => const VideoSettingsState();

  // -- Container -----------------------------------------------------------

  void setContainer(OutputContainer value) {
    state = state.copyWith(container: value);
  }

  // -- Encoder -------------------------------------------------------------

  void setEncoder(VideoEncoder value) {
    // Reset profile when encoder changes (different codecs support different profiles).
    final profiles = EncoderProfile.forEncoder(value);
    final profile =
        profiles.contains(state.profile) ? state.profile : EncoderProfile.auto;

    state = state.copyWith(
      encoder: value,
      profile: profile,
      // Reset tune to none for non-software encoders.
      tune: value.isHardware ? EncoderTune.none : state.tune,
    );
  }

  void setPreset(EncoderPreset value) {
    state = state.copyWith(preset: value);
  }

  void setTune(EncoderTune value) {
    state = state.copyWith(tune: value);
  }

  void setProfile(EncoderProfile value) {
    state = state.copyWith(profile: value);
  }

  void setLevel(EncoderLevel value) {
    state = state.copyWith(level: value);
  }

  // -- Quality -------------------------------------------------------------

  void setQualityMode(QualityMode value) {
    state = state.copyWith(qualityMode: value);
  }

  void setCrf(int value) {
    state = state.copyWith(crf: value.clamp(0, state.maxCrf));
  }

  void setAverageBitrate(int kbps) {
    state = state.copyWith(averageBitrate: kbps.clamp(100, 100000));
  }

  // -- Resolution / frame rate ---------------------------------------------

  void setFrameRate(FrameRateOption value) {
    state = state.copyWith(frameRate: value);
  }

  void setWidth(int? value) {
    state = value == null
        ? state.copyWith(clearWidth: true)
        : state.copyWith(width: value);
  }

  void setHeight(int? value) {
    state = value == null
        ? state.copyWith(clearHeight: true)
        : state.copyWith(height: value);
  }

  // -- Cropping ------------------------------------------------------------

  void setAutoCrop(bool value) {
    state = state.copyWith(autoCrop: value);
  }

  void setCropTop(int value) => state = state.copyWith(cropTop: value);
  void setCropBottom(int value) => state = state.copyWith(cropBottom: value);
  void setCropLeft(int value) => state = state.copyWith(cropLeft: value);
  void setCropRight(int value) => state = state.copyWith(cropRight: value);

  // -- Filters -------------------------------------------------------------

  void setDeinterlace(DeinterlaceMode value) {
    state = state.copyWith(deinterlace: value);
  }

  void setDenoise(DenoiseMode value) {
    state = state.copyWith(denoise: value);
  }

  void setSharpen(SharpenMode value) {
    state = state.copyWith(sharpen: value);
  }

  void setGrayscale(bool value) {
    state = state.copyWith(grayscale: value);
  }

  void setRotation(RotationOption value) {
    state = state.copyWith(rotation: value);
  }

  // -- Bulk reset ----------------------------------------------------------

  void reset() {
    state = const VideoSettingsState();
  }
}
