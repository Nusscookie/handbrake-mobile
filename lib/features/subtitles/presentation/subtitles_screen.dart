import 'package:flutter/material.dart';

/// Subtitle tracks, burn-in, external SRT (Step 5).
class SubtitlesScreen extends StatelessWidget {
  const SubtitlesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subtitles')),
      body: const Center(
        child: Text('Subtitle handling will go here.'),
      ),
    );
  }
}
