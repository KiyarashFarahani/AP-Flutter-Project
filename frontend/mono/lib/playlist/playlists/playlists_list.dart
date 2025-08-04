import 'package:flutter/material.dart';

import 'package:mono/models/playlist.dart';
import 'package:mono/playlist/playlists/playlist_item.dart';

class PlaylistsList extends StatelessWidget {
  PlaylistsList(this.playlists, this._removePlaylist, {super.key});
  List<Playlist>? playlists;
  final void Function(Playlist playlist) _removePlaylist;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return ListView.builder(
      itemCount: playlists!.length,
      itemBuilder: (context, index) => Dismissible(
        background: Container(color: colorScheme.error),
        key: ValueKey(playlists![index]),
        onDismissed: (direction) => _removePlaylist(playlists![index]),
        child: PlaylistItem(playlists![index]),
      ),
    );
  }
}
