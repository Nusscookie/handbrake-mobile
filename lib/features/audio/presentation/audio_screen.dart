import 'package:flutter/material.dart';

/// Audio tracks, codecs, mixdown (Step 5).
class AudioScreen extends StatelessWidget {
  const AudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio')),
      body: const Center(
        child: Text('Audio encoding options will go here.'),
      ),
    );
  }
}
