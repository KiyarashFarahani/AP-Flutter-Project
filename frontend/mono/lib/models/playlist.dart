import 'package:uuid/uuid.dart';

import 'package:mono/models/song.dart';

final uuid = Uuid();

class Playlist {
  Playlist(
      {required this.title,
        required this.songs
      }) : id = uuid.v4();
  final String title;
  final List<Song> songs;
  final String id;

  factory Playlist.fromJson(Map<String, dynamic> json) {
    var songsJson = json['songs'] as List<dynamic>;
    List<Song> songsList = songsJson.map((s) => Song.fromJson(s)).toList();

    return Playlist(
      title: json['name'] as String,
      songs: songsList,
    );
  }

  Map<String, dynamic> toJson() => {
    "name": title,
    "songs": songs.map((s) => s.toJson()).toList(),
  };
}