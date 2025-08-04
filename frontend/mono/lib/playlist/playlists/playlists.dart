import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:mono/models/playlist.dart';
import 'package:mono/models/song.dart';
import 'package:mono/playlist/playlists/new_playlist.dart';
import 'package:mono/playlist/playlists/playlists_list.dart';
import 'package:mono/home.dart';

class Playlists extends StatefulWidget {
  const Playlists({super.key});
  @override
  State<StatefulWidget> createState() {
    return _PlaylistsState();
  }
}

enum AppPage { playlists, songsInPlaylists, home }

class _PlaylistsState extends State<Playlists> {
  final List<Playlist> _playlists = [
    Playlist(
      title: 'fav',
      numOfSongs: 1,
      songs: [Song(title: 'Blind Trust')],
    ),
    Playlist(
      title: 'test',
      numOfSongs: 2,
      songs: [
        Song(title: '1'),
        Song(title: '2'),
      ],
    ),
  ];

  void _addPlaylist(Playlist playlist) {
    setState(() {
      _playlists.add(playlist);
    });
  }

  void _removePlaylist(Playlist playlist) {
    final _playlistIndex = _playlists.indexOf(playlist);
    setState(() {
      _playlists.remove(playlist);
    });
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 5),
        content: Text('Playlist deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _playlists.insert(_playlistIndex, playlist);
            });
          },
        ),
      ),
    );
  }

  void _addNewPlaylis() {
    showDialog(context: context, builder: (ctx) => NewPlaylist(_addPlaylist));
  }

  @override
  Widget build(BuildContext context) {
    AppPage currentPage = AppPage.playlists;
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.inversePrimary,
                  colorScheme.onPrimary,
                ],
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Color.fromRGBO(0, 0, 0, 0.2)),
          ),
          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                foregroundColor: colorScheme.onPrimary,
                title: Text(
                  'Your playlists',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),

              Expanded(child: PlaylistsList(_playlists, _removePlaylist)),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewPlaylis,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 8,
        child: const Icon(Icons.add, size: 28),
      ),
      bottomNavigationBar: Container(
        height: 60,
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(onPressed: () {
              if (currentPage == AppPage.home) {
                  return;
                }
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => HomePage()),
                      (route) => false,
                );
            }, icon: Icon(Icons.home)),
            IconButton(
              onPressed: () {
                if (currentPage == AppPage.playlists) {
                  return;
                }
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => Playlists()),
                      (route) => false,
                );
              },
              icon: Icon(Icons.library_music),
            ),
            IconButton(onPressed: () {}, icon: Icon(Icons.person)),
          ],
        ),
      ),
    );
  }
}
