import 'package:mono/models/song.dart';

Song songFromJson(Map<String, dynamic> json) {
  return Song.fromJson(json);
}

Map<String, dynamic> songToJson(Song song) {
  return song.toJson();
}
