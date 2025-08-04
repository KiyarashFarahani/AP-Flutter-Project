import 'package:flutter/material.dart';

import 'package:mono/models/song.dart';

class SongItem extends StatelessWidget {
  SongItem(this.song, {super.key});
  final Song song;
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(title: Text(song.title!), onTap: () {}),
    );
  }
}
