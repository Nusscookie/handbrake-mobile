import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transcoder/core/database/providers/application_isar_provider.dart';
import 'package:transcoder/core/router/app_router.dart';
import 'package:transcoder/core/theme/app_theme.dart';

void main() {
  runZonedGuarded(
    () {
      WidgetsFlutterBinding.ensureInitialized();

      // Catch Flutter framework errors (rendering, gestures, etc.).
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
      };

      runApp(const ProviderScope(child: TranscoderApp()));
    },
    // Catch unhandled async errors.
    (error, stack) {
      debugPrint('Unhandled error: $error\n$stack');
    },
  );
}

class TranscoderApp extends ConsumerWidget {
  const TranscoderApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    // Pre-warm Isar so it's ready before any tab accesses it.
    final dbAsync = ref.watch(applicationIsarProvider);

    return MaterialApp.router(
      title: 'Transcoder',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system,
      routerConfig: router,
      builder: (context, child) {
        // Show a loading screen while the database initializes.
        return dbAsync.when(
          loading: () => const _LoadingScreen(),
          error: (e, _) => _ErrorScreen(message: e.toString()),
          data: (_) => child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Initializing Transcoder...'),
          ],
        ),
      ),
    );
  }
}

class _ErrorScreen extends StatelessWidget {
  const _ErrorScreen({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Failed to initialize',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
