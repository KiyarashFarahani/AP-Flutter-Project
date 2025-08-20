import 'package:flutter/material.dart';
import 'package:mono/models/playlist.dart';

class SharePlaylist extends StatefulWidget{
  const SharePlaylist({required this.sharePlaylist,required this.playlist,super.key});
  final void Function(String username, Playlist playlist) sharePlaylist;
  final Playlist playlist;
  @override
  State<StatefulWidget> createState() {
    return _SharePlaylistState();
  }
}

class _SharePlaylistState extends State<SharePlaylist> {
  final _usernameController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      backgroundColor: colorScheme.primaryContainer,
      contentPadding: EdgeInsets.fromLTRB(24, 15, 24, 10),
      title: Text('Share playlist',
      style: TextStyle(color: colorScheme.onSecondaryContainer),
      ),
      content: SizedBox(
        width: 400,
        height: 50,
        child: TextField(
          controller: _usernameController,
          decoration: InputDecoration(
            hintText: 'To: username',
            fillColor: colorScheme.onSecondaryContainer,
            hoverColor: colorScheme.scrim,
          ),
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: colorScheme.secondary,
            foregroundColor: colorScheme.onSecondary,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          onPressed: () {
            Navigator.pop(context);
            widget.sharePlaylist(_usernameController.text, widget.playlist);
          },
          child: Text('Share'),
        ),
      ],
    );
  }
}