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

  factory SocketManager() {
    return _instance;
  }

  SocketManager._internal();

  Future<void> connect() async {
    const String serverIp = '10.0.2.2';
    // const String serverIp = '192.168.1.3';
    const int port = 1234;

    print('Connecting to $serverIp:$port...');

    try {
      _socket = await Socket.connect(
        serverIp,
        port,
        timeout: const Duration(seconds: 10),
      );
      _isConnected = true;
      print('Successfully connected to server at $serverIp:$port');

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
          _isConnected = false;
          _socket!.destroy();
        },
        onError: (error) {
          print('Socket error: $error');
          _isConnected = false;
          _socket!.destroy();
        },
      );
    } catch (e) {
      print('Could not connect: $e');
      _isConnected = false;
    }
  }

  void send(String message) {
    if (_socket != null && _isConnected) {
      _socket!.write(message + '\n');
    } else {
      print('Socket not connected');
    }
  }

  Future<String?> sendWithResponse(
    String message, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (_socket == null || !_isConnected) {
      print('Socket not connected');
      return null;
    }

    Completer<String?> completer = Completer<String?>();

    _responseCallback = (String response) {
      if (!completer.isCompleted) {
        completer.complete(response);
      }
    };

    _socket!.write(message + '\n');
    await _socket!.flush();

    try {
      return await completer.future.timeout(timeout);
    } catch (e) {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
      return null;
    }
  }

  Future<Uint8List?> getSongBytes(String request) async {
  if (_socket == null || !_isConnected) return null;

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

  

  Socket? get socket => _socket;
  bool get isConnected => _isConnected;
}
