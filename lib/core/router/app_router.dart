import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:transcoder/features/audio/presentation/audio_screen.dart';
import 'package:transcoder/features/queue/presentation/queue_screen.dart';
import 'package:transcoder/features/source/presentation/source_screen.dart';
import 'package:transcoder/features/subtitles/presentation/subtitles_screen.dart';
import 'package:transcoder/features/video/presentation/video_screen.dart';
import 'package:transcoder/shared/layout/app_shell.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.source,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.source,
                name: AppRoutes.sourceName,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SourceScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.video,
                name: AppRoutes.videoName,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: VideoScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.audio,
                name: AppRoutes.audioName,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: AudioScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.subtitles,
                name: AppRoutes.subtitlesName,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SubtitlesScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.queue,
                name: AppRoutes.queueName,
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: QueueScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

/// Route paths and [GoRoute] names for type-safe references later.
abstract final class AppRoutes {
  static const source = '/source';
  static const sourceName = 'source';
  static const video = '/video';
  static const videoName = 'video';
  static const audio = '/audio';
  static const audioName = 'audio';
  static const subtitles = '/subtitles';
  static const subtitlesName = 'subtitles';
  static const queue = '/queue';
  static const queueName = 'queue';
}
