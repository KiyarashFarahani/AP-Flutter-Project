import 'package:audioplayers/audioplayers.dart';
import 'package:mono/services/socket_manager.dart';
import 'package:mono/models/song.dart';
import 'dart:convert';
import 'dart:typed_data';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  final SocketManager _socketManager = SocketManager();

  // Current song state
  String? _currentSongTitle;
  String? _currentSongArtist;
  String? _currentSongFilename;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  // Getters
  String? get currentSongTitle => _currentSongTitle;
  String? get currentSongArtist => _currentSongArtist;
  String? get currentSongFilename => _currentSongFilename;
  bool get isPlaying => _isPlaying;
  Duration get position => _position;
  Duration get duration => _duration;
  AudioPlayer get player => _player;

  void dispose() {
    _player.onPlayerStateChanged.drain();
    _player.stop();
    _player.dispose();
    _currentSongTitle = null;
    _currentSongArtist = null;
    _currentSongFilename = null;
    _isPlaying = false;
    _position = Duration.zero;
    _duration = Duration.zero;
  }

  // Play a song by filename
  Future<void> playSong(String filename, {String? title, String? artist}) async {
    const int maxRetries = 2;
    int retryCount = 0;
    
    while (retryCount <= maxRetries) {
      try {
        print("AudioService: Starting to play song: $filename (attempt ${retryCount + 1})");

        if (_currentSongFilename == filename && _isPlaying) {
          print("AudioService: Already playing this song, skipping");
          return;
        }

        await forceStop();

        _currentSongFilename = filename;
        if (title != null) _currentSongTitle = title;
        if (artist != null) _currentSongArtist = artist;

        print("AudioService: Requesting song bytes for: $filename");

        final request = jsonEncode({
          "action": "get_song",
          "data": {"filename": filename},
        });

        final bytes = await _socketManager.getSongBytes(request);

        if (bytes != null && bytes.isNotEmpty) {
          if (!_isValidAudioData(bytes)) {
            print("Error: Received invalid or corrupted audio data: ${bytes.length} bytes");
            if (retryCount < maxRetries) {
              retryCount++;
              print("AudioService: Retrying... (${retryCount}/${maxRetries})");
              await Future.delayed(Duration(seconds: 1));
              continue;
            }
            _isPlaying = false;
            return;
          }
          
          print("AudioService: Received ${bytes.length} bytes, starting playback");

          try {
            await _player.play(BytesSource(bytes));
            _isPlaying = true;

            _player.onPlayerStateChanged.listen((state) {
              print("AudioService: Player state changed to: $state");
              if (state == PlayerState.completed) {
                _isPlaying = false;
                _position = Duration.zero;
              }
            });

            print("AudioService: Song playback started successfully");
            return;
          } catch (playError) {
            print("Error starting playback: $playError");
            if (retryCount < maxRetries) {
              retryCount++;
              print("AudioService: Playback failed, retrying... (${retryCount}/${maxRetries})");
              await Future.delayed(Duration(seconds: 1));
              continue;
            }
            _isPlaying = false;

            try {
              await _player.stop();
              await Future.delayed(Duration(milliseconds: 100));
            } catch (resetError) {
              print("Error resetting player: $resetError");
            }
            return;
          }
        } else {
          print("Error: Received empty or null bytes for song: $filename");
          if (retryCount < maxRetries) {
            retryCount++;
            print("AudioService: No data received, retrying... (${retryCount}/${maxRetries})");
            await Future.delayed(Duration(seconds: 1));
            continue;
          }
          _isPlaying = false;
          return;
        }
      } catch (e) {
        print("Error playing song: $e");
        if (retryCount < maxRetries) {
          retryCount++;
          print("AudioService: Error occurred, retrying... (${retryCount}/${maxRetries})");
          await Future.delayed(Duration(seconds: 1));
          continue;
        }
        _isPlaying = false;
        return;
      }
    }
  }

  Future<void> playSongFromSong(Song song) async {
    if (song.filename != null) {
      await playSong(song.filename!, title: song.title, artist: song.artist);
    } else {
      print("Error: Song filename is null");
    }
  }

  // Play/pause toggle
  Future<void> togglePlayPause() async {
    try {
      if (_isPlaying) {
        await _player.pause();
        _isPlaying = false;
      } else {
        await _player.resume();
        _isPlaying = true;
      }
    } catch (e) {
      print("Error in togglePlayPause: $e");
    }
  }

  // Pause playback
  Future<void> pause() async {
    try {
      await _player.pause();
      _isPlaying = false;
    } catch (e) {
      print("Error pausing: $e");
    }
  }

  // Resume playback
  Future<void> resume() async {
    try {
      await _player.resume();
      _isPlaying = true;
    } catch (e) {
      print("Error resuming: $e");
    }
  }

  // Stop playback
  Future<void> stop() async {
    try {
      await _player.stop();
      _isPlaying = false;
      _position = Duration.zero;
      _currentSongTitle = null;
      _currentSongArtist = null;
      _currentSongFilename = null;
    } catch (e) {
      print("Error stopping: $e");
    }
  }

  // Force stop and reset
  Future<void> forceStop() async {
    try {
      await _player.stop();
      await Future.delayed(Duration(milliseconds: 100));
      _player.onPlayerStateChanged.drain();
      _isPlaying = false;
      _position = Duration.zero;
      _currentSongTitle = null;
      _currentSongArtist = null;
      _currentSongFilename = null;
      print("AudioService: Force stopped and reset");
    } catch (e) {
      print("Error in forceStop: $e");
    }
  }

  // Seek to position
  Future<void> seekTo(Duration position) async {
    try {
      await _player.seek(position);
      _position = position;
    } catch (e) {
      print("Error seeking: $e");
    }
  }

  // Get current player state
  PlayerState get playerState => _player.state;

  // Check if a specific song is currently loaded
  bool isSongLoaded(String filename) {
    return _currentSongFilename == filename;
  }

  // Validate header before playing
  bool _isValidAudioData(Uint8List bytes) {
    if (bytes.length < 1024) return false;

    if (bytes.length >= 3) {
      if (bytes[0] == 0x49 && bytes[1] == 0x44 && bytes[2] == 0x33) {
        return true;
      }
      if (bytes[0] == 0xFF && (bytes[1] & 0xE0) == 0xE0) {
        return true;
      }
    }
    return bytes.length > 10000;
  }

  // Get current song info
  Map<String, dynamic> get currentSongInfo => {
    'filename': _currentSongFilename,
    'title': _currentSongTitle,
    'artist': _currentSongArtist,
    'isPlaying': _isPlaying,
    'position': _position.inSeconds,
    'duration': _duration.inSeconds,
  };

  // Placeholder next/previous
  Future<void> nextSong() async => print("Next song not implemented");
  Future<void> previousSong() async => print("Previous song not implemented");
}