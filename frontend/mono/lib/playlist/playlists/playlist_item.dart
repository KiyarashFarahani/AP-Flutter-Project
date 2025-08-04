import 'package:flutter/material.dart';

import 'package:mono/models/playlist.dart';
import 'package:mono/playlist/songs/songs_list.dart';

class PlaylistItem extends StatelessWidget {
  const PlaylistItem(this.playlist, {super.key});
  final Playlist playlist;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SizedBox(
      width: 700,
      height: 80,
      child: Card(
        color: colorScheme.primaryContainer,
        child: ListTile(
          title: Text(
            playlist.title,
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontSize: 20,
            ),
          ),
          subtitle: Text(
            playlist.numOfSongs == 1
                ? '${playlist.numOfSongs.toString()} song'
                : '${playlist.numOfSongs.toString()} songs',
            style: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontSize: 15,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SongsList(
                  playlistTitle: playlist.title,
                  songs: playlist.songs,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
