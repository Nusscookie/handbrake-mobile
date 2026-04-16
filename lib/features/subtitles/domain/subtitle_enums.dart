// Enumerations for subtitle track configuration.

enum SubtitleTrackAction {
  soft('Soft (Mux)'),
  burnIn('Burn-In'),
  remove('Remove');

  const SubtitleTrackAction(this.label);
  final String label;
}
