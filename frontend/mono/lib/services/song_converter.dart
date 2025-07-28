import 'package:mono/models/song.dart';
import 'dart:convert';
import 'dart:typed_data';

Song songFromJson(Map<String, dynamic> json) {
  return Song.fromJson(json);
}

Map<String, dynamic> songToJson(Song song) {
  return song.toJson();
}
