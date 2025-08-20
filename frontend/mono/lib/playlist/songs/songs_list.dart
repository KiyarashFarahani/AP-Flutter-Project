import 'package:flutter/material.dart';
import 'package:mono/home.dart';
import 'dart:ui';

import 'package:mono/models/song.dart';
import 'package:mono/models/playlist.dart';
import 'package:mono/playlist/songs/song_item.dart';



class SongsList extends StatefulWidget {
  const SongsList({required this.addSongToPlaylist,required this.removeSongFromPlaylist,required this.playlist, required this.songs, super.key});

  final Function(Playlist, Song) addSongToPlaylist;
  final Function(Playlist, Song) removeSongFromPlaylist;
  final Playlist playlist;
  final List<Song> songs;
  @override
  State<StatefulWidget> createState() {
    return _SongsListState();
  }
}

class _SongsListState extends State<SongsList> {


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
                  widget.playlist.title,
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
                        widget.removeSongFromPlaylist(widget.playlist, widget.songs[index]),
                    child: SongItem(widget.songs[index]),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
            final selectedSong = await Navigator.push (
              context,
              MaterialPageRoute(builder: (context) => HomePage(selectMode: true,)),
            );
            if (selectedSong != null) {
              setState(() {
                widget.addSongToPlaylist(widget.playlist, selectedSong);
              });
            }
        },
        backgroundColor: colorScheme.primaryContainer,
        elevation: 8,
        child: Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
