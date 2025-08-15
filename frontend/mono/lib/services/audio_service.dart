import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:mono/services/socket_manager.dart';
import 'dart:convert';

class AudioService extends ChangeNotifier {
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

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  // Initialize audio player listeners
  void initialize() {
    _player.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });

    _player.onPositionChanged.listen((pos) {
      _position = pos;
      notifyListeners();
    });

    _player.onDurationChanged.listen((dur) {
      _duration = dur;
      notifyListeners();
    });

    _player.onPlayerComplete.listen((_) {
      _isPlaying = false;
      _position = Duration.zero;
      notifyListeners();
    });
  }

  // Play a song by title
  Future<void> playSong(String songTitle, {String? artist}) async {
    try {
      // Stop current playback
      await _player.stop();

      // Update current song info
      _currentSongTitle = songTitle;
      _currentSongArtist = artist;
      _position = Duration.zero;
      _isPlaying = false;
      notifyListeners();

      // Get song bytes from server
      final request = jsonEncode({
        "action": "get_song",
        "data": {"filename": songTitle},
      });

      final bytes = await _socketManager.getSongBytes(request);

      if (bytes != null && bytes.isNotEmpty) {
        // Play the song
        await _player.play(BytesSource(bytes));
        _isPlaying = true;
        notifyListeners();
      } else {
        print("Error: Received empty bytes for song: $songTitle");
      }
    } catch (e) {
      print("Error playing song: $e");
    }
  }

  // Play/pause toggle
  Future<void> togglePlayPause() async {
    if (_currentSongTitle == null) return;

    if (_isPlaying) {
      await _player.pause();
    } else {
      await _player.resume();
    }
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
    _currentSongTitle = null;
    _currentSongArtist = null;
    notifyListeners();
  }

  // Seek to position
  Future<void> seekTo(Duration position) async {
    await _player.seek(position);
  }

  // Skip to next song (placeholder for future implementation)
  Future<void> nextSong() async {
    // TODO: Implement next song logic
    print("Next song functionality not implemented yet");
  }

  // Skip to previous song (placeholder for future implementation)
  Future<void> previousSong() async {
    // TODO: Implement previous song logic
    print("Previous song functionality not implemented yet");
  }
}
