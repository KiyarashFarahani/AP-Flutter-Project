import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:mono/models/playlist.dart';
import 'package:mono/models/song.dart';
import 'package:mono/playlist/playlists/new_playlist.dart';
import 'package:mono/playlist/songs/songs_list.dart';
import 'package:mono/playlist/playlists/share_playlist.dart';

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
      songs: [Song(title: 'Blind Trust', artist: 'mamad')],
    ),
    Playlist(
      title: 'test',
      songs: [
        Song(title: '1', artist: 'mamad1'),
        Song(title: '2', artist: 'mamad2'),
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
    showDialog(
      context: context,
      builder: (ctx) => NewPlaylist(_addPlaylist, playlists: _playlists),
    );
  }

  void _addSongToPlaylist(Playlist playlist, Song song) {
    setState(() {
      for (Playlist p in _playlists) {
        if (p == playlist) {
          p.songs.add(song);
          return;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
              Expanded(
                child: ListView.builder(
                  itemCount: _playlists.length,
                  itemBuilder:
                      (context, index) => Dismissible(
                        background: Container(color: colorScheme.error),
                        key: ValueKey(_playlists[index]),
                        onDismissed:
                            (direction) => _removePlaylist(_playlists[index]),
                        child: Center(
                          child: SizedBox(
                            width: 390,
                            height: 95,
                            child: Card(
                              color: colorScheme.primaryContainer,
                              margin: EdgeInsets.symmetric(vertical: 6),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => SongsList(
                                            addSongToPlaylist:
                                                _addSongToPlaylist,
                                            playlist: _playlists[index],
                                            songs: _playlists[index].songs,
                                          ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _playlists[index].title,
                                              style: textTheme.titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        colorScheme.onSurface,
                                                  ),
                                            ),
                                            Text(
                                              _playlists[index].songs.length ==
                                                      1
                                                  ? '${_playlists[index].songs.length} song'
                                                  : '${_playlists[index].songs.length} songs',
                                              style: textTheme.bodySmall
                                                  ?.copyWith(
                                                    color:
                                                        colorScheme
                                                            .onSurfaceVariant,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder: (ctx) => SharePlaylist(),
                                          );
                                        },
                                        icon: Icon(Icons.share),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                ),
              ),
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
    );
  }
}
