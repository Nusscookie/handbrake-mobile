import 'package:transcoder/core/utils/media_probe_parser.dart';

/// UI + probe state for the Source tab.
class SourceState {
  const SourceState({
    this.path,
    this.summary,
    this.rawProbeJson,
    this.isBusy = false,
    this.errorMessage,
  });

  final String? path;
  final SourceProbeSummary? summary;
  final String? rawProbeJson;
  final bool isBusy;
  final String? errorMessage;

  bool get hasSource => path != null;

  SourceState copyWith({
    String? path,
    SourceProbeSummary? summary,
    String? rawProbeJson,
    bool? isBusy,
    String? errorMessage,
    bool clearPath = false,
    bool clearSummary = false,
    bool clearError = false,
  }) {
    return SourceState(
      path: clearPath ? null : (path ?? this.path),
      summary: clearSummary ? null : (summary ?? this.summary),
      rawProbeJson: clearSummary ? null : (rawProbeJson ?? this.rawProbeJson),
      isBusy: isBusy ?? this.isBusy,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
