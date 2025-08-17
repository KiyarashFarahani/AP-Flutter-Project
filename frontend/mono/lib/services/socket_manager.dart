import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';

class SocketManager {
  static final SocketManager _instance = SocketManager._internal();
  Socket? _socket;
  Function(String)? _responseCallback;
  Function(List<int>)? _audioCallback;
  bool _isConnected = false;
  bool _isRequestInProgress = false;
  bool _isReconnecting = false;
  Timer? _reconnectTimer;
  final List<String> _pendingRequests = [];

  factory SocketManager() {
    return _instance;
  }

  SocketManager._internal();

  Future<void> connect() async {
    if (_isConnected && _socket != null) {
      print('Already connected to server');
      return;
    }

    if (_socket != null && !_isConnected) {
      print('Connection attempt already in progress');
      return;
    }

    const String serverIp = '10.0.2.2';
    //const String serverIp = '192.168.1.3';
    const int port = 1234;

    print('Connecting to $serverIp:$port...');

    try {
      _socket = await Socket.connect(
        serverIp,
        port,
        timeout: const Duration(seconds: 10),
      );
      _isConnected = true;
      _isRequestInProgress = false;
      _isReconnecting = false;
      print('Successfully connected to server at $serverIp:$port');


      _processPendingRequests();

      _socket!.listen(
        (data) {
          try {
            final decoded = utf8.decode(data);
            final jsonData = jsonDecode(decoded);
            _responseCallback?.call(jsonEncode(jsonData));
          } catch (_) {
               if (_audioCallback != null) {
            _audioCallback!((data));
          }
          }
        },
        onDone: () {
          print('Server closed connection');
          _handleDisconnection();
        },
        onError: (error) {
          print('Socket error: $error');
          _handleDisconnection();
        },
      );
    } catch (e) {
      print('Could not connect: $e');
      _isConnected = false;
      _isRequestInProgress = false;
      _socket = null;
      _scheduleReconnect();
    }
  }


  void _handleDisconnection() {
    _isConnected = false;
    _isRequestInProgress = false;
    _socket?.destroy();
    _socket = null;
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_isReconnecting) return;
    _isReconnecting = true;
    print('Scheduling reconnection...');
    
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 2), () async {
      if (!_isConnected) {
        print('Attempting to reconnect...');
        await connect();
      }
    });
  }

  void _processPendingRequests() {
    if (_pendingRequests.isEmpty) return;
    
    print('Processing ${_pendingRequests.length} pending requests...');
    for (final request in _pendingRequests) {
      send(request);
    }
    _pendingRequests.clear();
  }

  void send(String message) {
    if (_socket != null && _isConnected) {
      _socket!.write(message + '\n');
    } else {
      print('Socket not connected, queuing request for later');
      _pendingRequests.add(message);
      if (!_isReconnecting) {
        _scheduleReconnect();
      }
    }
  }

  Future<String?> sendWithResponse(
    String message, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (_socket == null || !_isConnected) {
      print('Socket not connected, attempting to reconnect...');
      await connect();
      if (!_isConnected) {
        print('Failed to reconnect, request cannot be processed');
        return null;
      }
    }

    if (_isRequestInProgress) {
      print('Request already in progress, waiting...');
      await Future.delayed(Duration(milliseconds: 100));
      return sendWithResponse(message, timeout: timeout);
    }

    _isRequestInProgress = true;
    Completer<String?> completer = Completer<String?>();

    try {
      _responseCallback = (String response) {
        if (!completer.isCompleted) {
          completer.complete(response);
        }
      };

      if (_socket != null && _isConnected) {
        _socket!.write(message + '\n');
        await _socket!.flush();
      } else {
        throw Exception('Socket disconnected during request');
      }

      final result = await completer.future.timeout(timeout);
      return result;
    } catch (e) {
      print('Error in sendWithResponse: $e');
      if (!completer.isCompleted) {
        completer.complete(null);
      }
      return null;
    } finally {
      _isRequestInProgress = false;
      _responseCallback = null;
    }
  }

  Future<Uint8List?> getSongBytes(String request) async {
    if (_socket == null || !_isConnected) {
      print('Socket not connected for song request, attempting to reconnect...');
      await connect();
      
      if (!_isConnected) {
        print('Failed to reconnect for song request');
        return null;
      }
    }

  final completer = Completer<Uint8List?>();
  final bytes = <int>[];
  bool metadataReceived = false;

  
  void dataHandler(List<int> chunk) {
    try {
     
      if (!metadataReceived) {
        final jsonStr = utf8.decode(chunk);
        final json = jsonDecode(jsonStr);
        print("Metadata: $json");
        metadataReceived = true;
        return;
      }
    } catch (_) {
      
      bytes.addAll(chunk);
    }
  }

  _audioCallback = dataHandler;
  _socket!.write(request + '\n');
  await _socket!.flush();

 
  await Future.delayed(Duration(seconds: 5));
  _audioCallback = null;

  if (bytes.isNotEmpty) {
    completer.complete(Uint8List.fromList(bytes));
  } else {
    completer.complete(null);
  }

  return completer.future;
}

  Future<bool> uploadSong(String filename, Uint8List fileBytes, String token) async {
    if (_socket == null || !_isConnected) {
      print('Socket not connected for upload, attempting to reconnect...');
      await connect();
      
      if (!_isConnected) {
        print('Failed to reconnect for upload');
        return false;
      }
    }

    try {
      final uploadRequest = jsonEncode({
        "action": "upload_song",
        "token": token,
        "data": {
          "filename": filename,
          "filesize": fileBytes.length,
          "token": token
        }
      });

      _socket!.write(uploadRequest + '\n');
      await _socket!.flush();

      await Future.delayed(Duration(milliseconds: 200));

      _socket!.add(fileBytes);
      await _socket!.flush();

      await Future.delayed(Duration(milliseconds: 500));

      print('Song upload completed: $filename');
      return true;
    } catch (e) {
      print('Error uploading song: $e');
      return false;
    }
  }

  void dispose() {
    _reconnectTimer?.cancel();
    _socket?.destroy();
    _socket = null;
    _isConnected = false;
    _isReconnecting = false;
  }

  Socket? get socket => _socket;
  bool get isConnected => _isConnected;
}
