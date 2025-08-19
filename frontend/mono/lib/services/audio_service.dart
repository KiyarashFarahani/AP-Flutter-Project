import 'package:audioplayers/audioplayers.dart';
import 'package:mono/services/socket_manager.dart';
import 'dart:convert';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  final SocketManager _socketManager = SocketManager();

  // Current song state
  String? _currentSongTitle;
  String? _currentSongArtist;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  // Getters
  String? get currentSongTitle => _currentSongTitle;
  String? get currentSongArtist => _currentSongArtist;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  AudioPlayer get player => _player;

  void dispose() {
    _player.dispose();
  }

  // Play a song by title
  Future<void> playSong(String filename) async {
    try {
      await _player.stop();
      _position = Duration.zero;
      _isPlaying = false;

      final request = jsonEncode({
        "action": "get_song",
        "data": {"filename": filename},
      });

      final bytes = await _socketManager.getSongBytes(request);

      if (bytes != null && bytes.isNotEmpty) {
        await _player.play(BytesSource(bytes));
        _isPlaying = true;
      } else {
        print("Error: Received empty bytes for song: $filename");
      }
    } catch (e) {
      print("Error playing song: $e");
    }
  }

  // Play/pause toggle
  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.resume();
    }
    _isPlaying = !_isPlaying;
  }

  // Pause playback
  Future<void> pause() async {
    await _player.pause();
  }

  // Resume playback
  Future<void> resume() async {
    await _player.resume();
  }

  // Stop playback
  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
    _position = Duration.zero;
    _currentSongTitle = "Unknown Song";
    _currentSongArtist = "Unknown Artist";
  }

  // Seek to position
  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
    _position = position;
  }

  // Placeholder next/previous
  Future<void> nextSong() async => print("Next song not implemented");
  Future<void> previousSong() async => print("Previous song not implemented");
}