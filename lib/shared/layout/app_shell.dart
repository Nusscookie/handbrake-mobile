import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Adaptive shell: [NavigationBar] on narrow layouts, [NavigationRail] on wide.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const double tabletBreakpoint = 600;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final useRail = width >= tabletBreakpoint;

    if (useRail) {
      return Scaffold(
        body: Row(
          children: [
            NavigationRail(
              extended: width >= 840,
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: (i) => _onSelect(i),
              destinations: const [
                NavigationRailDestination(
                  icon: Icon(Icons.folder_open_outlined),
                  selectedIcon: Icon(Icons.folder_open),
                  label: Text('Source'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.movie_outlined),
                  selectedIcon: Icon(Icons.movie),
                  label: Text('Video'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.audiotrack_outlined),
                  selectedIcon: Icon(Icons.audiotrack),
                  label: Text('Audio'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.subtitles_outlined),
                  selectedIcon: Icon(Icons.subtitles),
                  label: Text('Subtitles'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.queue_play_next_outlined),
                  selectedIcon: Icon(Icons.queue_play_next),
                  label: Text('Queue'),
                ),
              ],
            ),
            const VerticalDivider(width: 1, thickness: 1),
            Expanded(child: navigationShell),
          ],
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (i) => _onSelect(i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.folder_open_outlined),
            selectedIcon: Icon(Icons.folder_open),
            label: 'Source',
          ),
          NavigationDestination(
            icon: Icon(Icons.movie_outlined),
            selectedIcon: Icon(Icons.movie),
            label: 'Video',
          ),
          NavigationDestination(
            icon: Icon(Icons.audiotrack_outlined),
            selectedIcon: Icon(Icons.audiotrack),
            label: 'Audio',
          ),
          NavigationDestination(
            icon: Icon(Icons.subtitles_outlined),
            selectedIcon: Icon(Icons.subtitles),
            label: 'Subtitles',
          ),
          NavigationDestination(
            icon: Icon(Icons.queue_play_next_outlined),
            selectedIcon: Icon(Icons.queue_play_next),
            label: 'Queue',
          ),
        ],
      ),
    );
  }

  void _onSelect(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }
}
