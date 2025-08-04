import 'package:flutter/material.dart';
import 'package:mono/models/playlist.dart';

class NewPlaylist extends StatefulWidget {
  NewPlaylist(this.addPlaylist, {super.key});
  void Function(Playlist playlist) addPlaylist;
  @override
  State<StatefulWidget> createState() {
    return _NewPlaylistState();
  }
}

class _NewPlaylistState extends State<NewPlaylist> {
  final _titleController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submitPlaylist() {
    widget.addPlaylist(
      Playlist(title: _titleController.text, numOfSongs: 0, songs: []),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return AlertDialog(
      backgroundColor: colorScheme.secondaryContainer,
      contentPadding: EdgeInsets.fromLTRB(24, 15, 24, 10),
      title: Text(
        'Add new playlist',
        style: TextStyle(color: colorScheme.onSecondaryContainer),
      ),
      content: SizedBox(
        width: 400,
        height: 50,
        child: TextField(
          controller: _titleController,
          maxLength: 30,
          decoration: InputDecoration(
            hintText: 'Enter playlist name',
            fillColor: colorScheme.onSecondaryContainer,
            hoverColor: colorScheme.scrim,
          ),
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: colorScheme.secondaryFixed,
            foregroundColor: colorScheme.onSurfaceVariant,
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
          onPressed: _submitPlaylist,
          child: Text('Save'),
        ),
      ],
    );
  }
}
