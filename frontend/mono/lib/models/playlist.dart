import 'package:uuid/uuid.dart';

import 'package:mono/models/song.dart';

final uuid = Uuid();

class Playlist {
  Playlist(
      {required this.title,
        required this.numOfSongs,
        required this.songs
      }) : id = uuid.v4();
  final String title;
  final int numOfSongs;
  final List<Song> songs;
  final String id;
}