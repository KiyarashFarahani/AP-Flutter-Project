import 'package:flutter/material.dart';
import 'package:mono/models/playlist.dart';

class NewPlaylist extends StatefulWidget {
  NewPlaylist(this.addPlaylist, {required this.playlists, super.key});
  void Function(Playlist playlist) addPlaylist;
  List<Playlist> playlists;
  @override
  State<StatefulWidget> createState() {
    return _NewPlaylistState();
  }
}

class _NewPlaylistState extends State<NewPlaylist> {
  final _titleController = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _submitPlaylist() {
    widget.addPlaylist(
      Playlist(title: _titleController.text, songs: []),
    );
    Navigator.pop(context);
  }

  void _validateAndSubmit() {
    final title = _titleController.text.trim();

    if (title.isEmpty) {
      setState(() => _errorText = 'This field cannot be empty');
      return;
    }

    final exists = widget.playlists.any((p) => p.title == title);
    if (exists) {
      setState(
        () =>
            _errorText =
                'Playlist name already exists',
      );
      return;
    }

    _errorText = null;
    _submitPlaylist();
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
            errorText: _errorText,
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
          onPressed: _validateAndSubmit,
          child: Text('Save'),
        ),
      ],
    );
  }
}
