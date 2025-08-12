import 'dart:io';
import 'dart:convert' as convert;
import 'dart:convert';
import 'dart:async';

class SongService {
  Socket? _socket;
  bool _isConnected = false;
  Function(String)? _responseCallback;

  final String serverIp;
  final int serverPort;

  SongService({required this.serverIp, required this.serverPort});

  
  final StreamController<String> _responseController =
      StreamController.broadcast();
  StringBuffer _responseBuffer = StringBuffer();

  Future<void> connect() async {
    try {
      print("Connecting to file server at $serverIp:$serverPort...");
      _socket = await Socket.connect(
        serverIp,
        serverPort,
        timeout: const Duration(seconds: 10),
      );
      _isConnected = true;
      print("Connected to file server");

      
      _socket!.listen(
        (data) {
          final chunk = convert.utf8.decode(data);
          print('Received chunk: $chunk'); 

          _responseBuffer.write(chunk);
          final bufferContent = _responseBuffer.toString();

         
          try {
            final json = jsonDecode(bufferContent);
            _responseController.add(bufferContent);
            _responseBuffer.clear(); 
          } catch (e) {
            
          }
        },
        onDone: () {
          if (_responseBuffer.isNotEmpty) {
            _responseController.add(_responseBuffer.toString());
          }
          print('Server closed connection');
          _isConnected = false;
          _socket?.destroy();
        },
        onError: (error) {
          print('Socket error: $error');
          _isConnected = false;
          _socket?.destroy();
          _responseController.addError(error);
        },
      );
    } catch (e) {
      print("Failed to connect to file server: $e");
      _isConnected = false;
      _responseController.addError(e);
    }
  }

  bool get isConnected => _isConnected;

  Future<String?> sendWithResponse(
    String message, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    if (!_isConnected) return null;

    _socket!.write('$message\n');
    await _socket!.flush();

    try {
      return await _responseController.stream
          .firstWhere((data) => data.isNotEmpty)
          .timeout(timeout);
    } catch (e) {
      print('Response timeout: $e');
      return null;
    }
  }

  Future<List<String>> getSongList() async {
    final request = jsonEncode({"action": "list_songs"});
    final response = await sendWithResponse(
      request,
      timeout: Duration(seconds: 10),
    );

    if (response == null) throw Exception("No response from server");

    try {
      final json = jsonDecode(response);
      return (json['songs'] as List)
          .map<String>((song) => song['title'] as String)
          .toList();
    } catch (e) {
      print('JSON Parse Error: $e\nResponse: $response');
      throw Exception('Invalid server response');
    }
  }

  void dispose() {
    _responseController.close();
    close();
  }

  void close() {
    _socket?.destroy();
    _isConnected = false;
    print("SongService socket closed");
  }
}
