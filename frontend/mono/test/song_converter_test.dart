import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mono/models/song.dart';
import 'package:mono/services/song_converter.dart';

void main() {
  group('tests for song converter', () {
    test('songToJson returns map correctly', () {
      final song = Song(
        id: 1,
        title: 'Test Song',
        artist: 'Test Artist',
        album: 'Test Album',
        genre: 'Pop',
        duration: 240,
        year: 2022,
        filePath: '/music/test.mp3',
        coverArtUrl: '/images/test.jpg',
        lyrics: 'Lyrics',
        playCount: 100,
        likes: 5,
        createdAt: DateTime.parse("2022-01-01T12:00:00Z"),
        updatedAt: DateTime.parse("2022-02-01T12:00:00Z"),
        isShareable: true,
        likedByUsers: [], // Optional mock user list
      );

      final json = songToJson(song);

      expect(json['title'], equals('Test Song'));
      expect(json['artist'], equals('Test Artist'));
      expect(json['album'], equals('Test Album'));
      expect(json['genre'], equals('Pop'));
      expect(json['duration'], equals(240));
      expect(json['year'], equals(2022));
      expect(json['filePath'], equals('/music/test.mp3'));
      expect(json['coverArtUrl'], equals('/images/test.jpg'));
      expect(json['lyrics'], equals('Lyrics'));
      expect(json['playCount'], equals(100));
      expect(json['likes'], equals(5));
      expect(json['createdAt'], equals(DateTime.parse("2022-01-01T12:00:00Z")
          .toIso8601String()));
      expect(json['updatedAt'], equals(DateTime.parse("2022-02-01T12:00:00Z")
          .toIso8601String(),));
      expect(json['isShareable'], equals(true));
      expect(json['likedByUsers'], equals([]));
    });

    test('songFromJson returns song correctly', () {
      final json = {
        'id': 1,
        'title': 'Test Song',
        'artist': 'Test Artist',
        'album': 'Test Album',
        'genre': 'Rap',
        'duration': 250,
        'year': 2025,
        'filePath': '/music/test.mp3',
        'coverArtUrl': '/images/test.jpg',
        'lyrics': 'Lyrics',
        'playCount': 102,
        'likes': 36,
        'createdAt': DateTime.parse("2022-01-01T12:00:00Z").toIso8601String(),
        'updatedAt': DateTime.parse("2022-02-01T12:00:00Z").toIso8601String(),
        'isShareable': true,
        'likedByUsers': [], //Optional mock user list
      };

      final song = songFromJson(json);

      expect(song.title, equals('Test Song'));
      expect(song.artist, equals('Test Artist'));
      expect(song.album, equals('Test Album'));
      expect(song.genre, equals('Rap'));
      expect(song.duration, equals(250));
      expect(song.year, equals(2025));
      expect(song.filePath, equals('/music/test.mp3'));
      expect(song.coverArtUrl, equals('/images/test.jpg'));
      expect(song.lyrics, equals('Lyrics'));
      expect(song.playCount, equals(102));
      expect(song.likes, equals(36));
      expect(song.createdAt, equals(DateTime.parse("2022-01-01T12:00:00Z")));
      expect(song.updatedAt, equals(DateTime.parse("2022-02-01T12:00:00Z")));
      expect(song.isShareable, equals(true));
      expect(song.likedByUsers, equals([]));
    });
  });
}