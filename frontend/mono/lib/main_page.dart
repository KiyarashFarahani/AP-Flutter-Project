
import 'package:flutter/material.dart';
import 'package:mono/home.dart';
import 'package:mono/playlist/playlists/playlists.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  var _currentIndex = 0;

  final _pages = const [
    HomePage(),
    Playlists(),
    //Profile()
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
        indicatorColor: colorScheme.primaryContainer,
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_music),
            label: 'Playlists',
          ),
          NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          NavigationDestination(
            icon: Badge(child: Icon(Icons.search)),
            label: 'Search',
          ),
        ],
      ),
    );
  }
}
