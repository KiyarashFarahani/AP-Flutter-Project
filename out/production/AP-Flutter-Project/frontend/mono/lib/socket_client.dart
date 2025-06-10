import 'dart:io';
import 'dart:convert';

class SocketClient {
  static final SocketClient _instance = SocketClient._internal();

  late Socket _socket;

  factory SocketClient() => _instance;

  SocketClient._internal();

  Future<void> connect() async {
    try {
      _socket = await Socket.connect('localhost', 1234); // Change to your server IP if testing on real device
      print('✅ Connected to server');

      _socket.listen(
            (data) {
          print('📥 Server says: ${utf8.decode(data)}');
        },
        onError: (error) {
          print(' Error: $error');
        },
        onDone: () {
          print('🔌 Server closed connection');
        },
      );
    } catch (e) {
      print(' Could not connect: $e');
    }
  }

  void sendTestMessage() {
    _socket.write('Hello from Flutter\n');
    print('📤 Sent: Hello from Flutter');
  }
}
