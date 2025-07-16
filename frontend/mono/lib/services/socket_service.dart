import 'dart:io';
import 'dart:convert';

class SocketService {
  Socket? _socket;

  Future<void> connectToServer() async {
    try {
      _socket = await Socket.connect("192.168.1.10", 1234);

      print("Connected to server");

      _socket!.listen((data) {
        final response = utf8.decode(data);
        print("Server response: $response");
      });

    } catch (e) {
      print("Connection error: $e");
    }
  }

  void sendJson(Map<String, dynamic> jsonData) {
    if (_socket != null) {
      final json = jsonEncode(jsonData) + "\n";
      _socket!.write(json);
    }
  }

  void close() {
    _socket?.close();
  }
}