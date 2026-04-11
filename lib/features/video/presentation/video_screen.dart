import 'package:flutter/material.dart';

/// Video encoding, quality, resolution, and filters (Steps 4+).
class VideoScreen extends StatelessWidget {
  const VideoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video')),
      body: const Center(
        child: Text('Encoder settings and video filters will go here.'),
      ),
    );
  }
}
