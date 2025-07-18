import 'dart:io';
import 'dart:convert';

class SocketManager {
  static final SocketManager _instance = SocketManager._internal();
  Socket? _socket;

  factory SocketManager() {
    return _instance;
  }

  SocketManager._internal();

  Future<void> connect() async {
    const String serverIp = '10.0.2.2'; 
    const int port = 1234;

    try {
      _socket = await Socket.connect(serverIp, port);
      print('Connected to server');

      _socket!.listen(
        (List<int> data) {
          final response = utf8.decode(data);
          print('Server says: $response');
        },
        onDone: () {
          print('Server closed connection');
          _socket!.destroy();
        },
        onError: (error) {
          print('Socket error: $error');
          _socket!.destroy();
        },
      );
    } catch (e) {
      print('Could not connect: $e');
    }
  }

  void send(String message) {
    _socket?.write(message + '\n');
  }

  Socket? get socket => _socket;
}
