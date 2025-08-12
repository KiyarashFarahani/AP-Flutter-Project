import 'dart:io';
import 'dart:convert';
import 'dart:async';

class SocketManager {
  static final SocketManager _instance = SocketManager._internal();
  Socket? _socket;
  Function(String)? _responseCallback;
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
      _socket = await Socket.connect(serverIp, port, timeout: const Duration(seconds: 10));
      _isConnected = true;
      print('Successfully connected to server at $serverIp:$port');

      _socket!.listen(
        (List<int> data) {
          final response = utf8.decode(data);
          print('Server says: $response');

          if (_responseCallback != null) {
            _responseCallback!(response);
            _responseCallback = null;
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

  Future<String?> sendWithResponse(String message, {Duration timeout = const Duration(seconds: 5)}) async {
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

    try {
      return await completer.future.timeout(timeout);
    } catch (e) {
      if (!completer.isCompleted) {
        completer.complete(null);
      }
      return null;
    }
  }

  Socket? get socket => _socket;
  bool get isConnected => _isConnected;
}