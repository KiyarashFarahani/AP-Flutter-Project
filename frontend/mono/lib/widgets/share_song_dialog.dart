import 'package:flutter/material.dart';
import 'package:mono/models/song.dart';

class ShareSongDialog extends StatefulWidget {
  const ShareSongDialog({
    required this.shareSong,
    required this.song,
    super.key
  });

  final void Function(String username, Song song) shareSong;
  final Song song;

  @override
  State<StatefulWidget> createState() {
    return _ShareSongDialogState();
  }
}

class _ShareSongDialogState extends State<ShareSongDialog> {
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
      contentPadding: const EdgeInsets.fromLTRB(24, 15, 24, 10),
      title: Text(
        'Share Song',
        style: TextStyle(color: colorScheme.onSecondaryContainer),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Share "${widget.song.title ?? 'Unknown'}" with:',
            style: TextStyle(
              color: colorScheme.onSecondaryContainer.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 400,
            child: TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                hintText: 'Enter username',
                prefixIcon: Icon(
                  Icons.person,
                  color: colorScheme.onSecondaryContainer.withOpacity(0.6),
                ),
                fillColor: colorScheme.onSecondaryContainer,
                hoverColor: colorScheme.scrim,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
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
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
          ),
          onPressed: () {
            final username = _usernameController.text.trim();
            if (username.isNotEmpty) {
              Navigator.pop(context);
              widget.shareSong(username, widget.song);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a username'),
                  duration: Duration(seconds: 2),
                ),
              );
            }
          },
          child: const Text('Share'),
        ),
      ],
    );
  }
}