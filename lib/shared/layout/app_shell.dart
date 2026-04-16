import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Adaptive shell: [NavigationBar] on narrow layouts, [NavigationRail] on wide.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  static const double tabletBreakpoint = 600;

  static const _destinations = <_NavItem>[
    _NavItem(Icons.folder_open_outlined, Icons.folder_open, 'Source'),
    _NavItem(Icons.movie_outlined, Icons.movie, 'Video'),
    _NavItem(Icons.audiotrack_outlined, Icons.audiotrack, 'Audio'),
    _NavItem(Icons.subtitles_outlined, Icons.subtitles, 'Subtitles'),
    _NavItem(Icons.bookmarks_outlined, Icons.bookmarks, 'Presets'),
    _NavItem(Icons.queue_play_next_outlined, Icons.queue_play_next, 'Queue'),
  ];

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final useRail = width >= tabletBreakpoint;

    if (useRail) {
      return Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              NavigationRail(
                extended: width >= 840,
                selectedIndex: navigationShell.currentIndex,
                onDestinationSelected: _onSelect,
                destinations: _destinations
                    .map((d) => NavigationRailDestination(
                          icon: Icon(d.icon),
                          selectedIcon: Icon(d.selectedIcon),
                          label: Text(d.label),
                        ))
                    .toList(),
              ),
              const VerticalDivider(width: 1, thickness: 1),
              Expanded(child: navigationShell),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onSelect,
        destinations: _destinations
            .map((d) => NavigationDestination(
                  icon: Icon(d.icon),
                  selectedIcon: Icon(d.selectedIcon),
                  label: d.label,
                ))
            .toList(),
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

class _NavItem {
  const _NavItem(this.icon, this.selectedIcon, this.label);
  final IconData icon;
  final IconData selectedIcon;
  final String label;
}
