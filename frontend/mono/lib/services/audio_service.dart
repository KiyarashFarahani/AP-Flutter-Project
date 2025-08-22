import 'package:audioplayers/audioplayers.dart';
import 'package:mono/services/socket_manager.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'dart:io';
import 'package:mono/services/token_storage.dart';

class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  final AudioPlayer _player = AudioPlayer();
  final SocketManager _socketManager = SocketManager();

  String? _currentSongTitle;
  String? _currentSongArtist;
  String? _currentSongFilename;
  bool _isPlaying = false;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  final StreamController<Duration> _positionController = StreamController<Duration>.broadcast();
  final StreamController<Duration> _durationController = StreamController<Duration>.broadcast();

  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration> get durationStream => _durationController.stream;

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
    _positionController.close();
    _durationController.close();
    _currentSongTitle = null;
    _currentSongArtist = null;
    _currentSongFilename = null;
    _isPlaying = false;
    _position = Duration.zero;
    _duration = Duration.zero;
  }

  Future<void> playSong(String filename, {String? title, String? artist, int? durationSeconds}) async {
    const int maxRetries = 2;
    int retryCount = 0;

    while (retryCount <= maxRetries) {
      try {
        await _player.stop();
        await Future.delayed(Duration(milliseconds: 100));

        _currentSongFilename = filename;
        if (title != null) _currentSongTitle = title;
        if (artist != null) _currentSongArtist = artist;

        if (durationSeconds != null && durationSeconds > 0) {
          _duration = Duration(seconds: durationSeconds);
          _durationController.add(_duration);
        }

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
                _positionController.add(_position);
              }
            });

            _player.onPositionChanged.listen((position) {
              _position = position;
              _positionController.add(_position);
            });

            _player.onDurationChanged.listen((duration) {
              _duration = duration;
              _durationController.add(_duration);
            });

            _detectDuration();

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
        print("Error in playSong: $e");
        if (retryCount < maxRetries) {
          retryCount++;
          print("AudioService: General error, retrying... (${retryCount}/${maxRetries})");
          await Future.delayed(Duration(seconds: 1));
          continue;
        }
        _isPlaying = false;
        return;
      }
    }
  }

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
      print("Error toggling play/pause: $e");
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
      _isPlaying = false;
      _position = Duration.zero;
      _positionController.add(_position);
      _currentSongTitle = null;
      _currentSongArtist = null;
      _currentSongFilename = null;
    } catch (e) {
      print("Error stopping: $e");
    }
  }

  Future<void> forceStop() async {
    try {
      await _player.stop();
      await Future.delayed(Duration(milliseconds: 100));
      _player.onPlayerStateChanged.drain();
      _isPlaying = false;
      _position = Duration.zero;
      _positionController.add(_position);
      _currentSongTitle = null;
      _currentSongArtist = null;
      _currentSongFilename = null;
      print("AudioService: Force stopped and reset");
    } catch (e) {
      print("Error in forceStop: $e");
    }
  }

  Future<void> seekTo(Duration position) async {
    try {
      await _player.seek(position);
      _position = position;
      _positionController.add(_position);
    } catch (e) {
      print("Error seeking: $e");
    }
  }

  PlayerState get playerState => _player.state;

  bool isSongLoaded(String filename) {
    return _currentSongFilename == filename;
  }

  void setDuration(Duration duration) {
    if (duration > Duration.zero) {
      _duration = duration;
      _durationController.add(_duration);
    }
  }

  void _detectDuration() {
    final delays = [500, 1000, 2000, 3000];

    for (int i = 0; i < delays.length; i++) {
      Future.delayed(Duration(milliseconds: delays[i]), () async {
        if (_duration == Duration.zero) {
          try {
            final playerDuration = await _player.getDuration();
            if (playerDuration != null && playerDuration > Duration.zero) {
              _duration = playerDuration;
              _durationController.add(_duration);
              print("AudioService: Duration detected: ${_formatDuration(_duration)}");
            }
          } catch (e) {
            print("Error getting duration: $e");
          }
        }
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  bool _isValidAudioData(Uint8List bytes) {
    if (bytes.length < 1024) return false;

    final header = bytes.sublist(0, 12);

    if (header[0] == 0xFF && (header[1] & 0xE0) == 0xE0) {
      return true;
    }

    if (header[0] == 0x49 && header[1] == 0x44 && header[2] == 0x33) {
      return true;
    }

    final headerString = String.fromCharCodes(header.sublist(0, 4));
    if (headerString == 'RIFF') {
      return true;
    }

    if (headerString == 'fLaC') {
      return true;
    }

    if (header[0] == 0x4F && header[1] == 0x67 && header[2] == 0x67 && header[3] == 0x53) {
      return true;
    }

    return false;
  }

  Future<bool> uploadSong(String filePath, String filename) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        print('File does not exist: $filePath');
        return false;
      }

      final fileBytes = await file.readAsBytes();
      final token = await TokenStorage.getToken();
      if (token == null) {
        print('No authentication token found');
        return false;
      }

      final uploadRequest = jsonEncode({
        "action": "upload_song",
        "token": token,
        "data": {
          "filename": filename,
          "filesize": fileBytes.length,
          "token": token
        }
      });

      _socketManager.socket!.write(uploadRequest + '\n');
      await _socketManager.socket!.flush();

      await Future.delayed(Duration(milliseconds: 200));

      _socketManager.socket!.add(fileBytes);
      await _socketManager.socket!.flush();

      await Future.delayed(Duration(milliseconds: 500));

      print('Song upload completed: $filename');
      return true;
    } catch (e) {
      print('Error uploading song: $e');
      return false;
    }
  }

  Map<String, dynamic> getPlayerInfo() {
    return {
      'isPlaying': _isPlaying,
      'currentSong': _currentSongTitle,
      'currentArtist': _currentSongArtist,
      'position': _position.inSeconds,
      'duration': _duration.inSeconds,
    };
  }

  // Placeholder next/previous
  Future<void> nextSong() async => print("Next song not implemented");
  Future<void> previousSong() async => print("Previous song not implemented");
}