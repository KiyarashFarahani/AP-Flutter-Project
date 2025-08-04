import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:mono/models/song.dart';
import 'package:mono/playlist/songs/song_item.dart';
import 'package:mono/playlist/playlists/playlists.dart';

class SongsList extends StatefulWidget {
  SongsList({required this.playlistTitle, required this.songs, super.key});
  final String playlistTitle;
  final List<Song> songs;
  @override
  State<StatefulWidget> createState() {
    return _SongsListState();
  }
}

class _SongsListState extends State<SongsList> {
  _addSong(Song song) {
    setState(() {
      widget.songs.add(song);
    });
  }

  _removeSong(Song song) {
    setState(() {
      widget.songs.remove(song);
    });
  }

  @override
  Widget build(BuildContext context) {
    AppPage currentPage = AppPage.songsInPlaylists;
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
                  widget.playlistTitle,
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.songs.length,
                  itemBuilder: (context, index) => Dismissible(
                    background: Container(color: colorScheme.errorContainer),
                    key: ValueKey(widget.songs[index]),
                    onDismissed: (direction) =>
                        _removeSong(widget.songs[index]),
                    child: SongItem(widget.songs[index]),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: colorScheme.primaryContainer,
        elevation: 8,
        child: Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        height: 60,
        color: Colors.black,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(onPressed: () {},
              icon: Icon(Icons.home),),
            IconButton(onPressed: () {
              if (currentPage == AppPage.playlists) {
                return;
              }
              Navigator.push(context,
                MaterialPageRoute(builder: (context) =>
                    Playlists()
                ),
              );
            },
              icon: Icon(Icons.library_music),),
            IconButton(onPressed: () {},
              icon: Icon(Icons.person),),
          ],
        ),
      ),
    );
  }
}
