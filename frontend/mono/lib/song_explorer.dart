import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:async';
import 'package:mono/services/socket_manager.dart';

class SongExplorer extends StatefulWidget {
  const SongExplorer({super.key});
  @override
  _SongExplorerState createState() => _SongExplorerState();
}

class _SongExplorerState extends State<SongExplorer> {
  final _socketManager = SocketManager();
  StreamController<List<int>> _audioStreamController = StreamController<List<int>>();
  final _player = AudioPlayer();
  List<String> songs = [];

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    final List<String> list;
    final listSongsRequest = jsonEncode({"action": "list_songs"});
    final response = await _socketManager.sendWithResponse(
      listSongsRequest,
      timeout: Duration(seconds: 10),
    );

    if (response == null) throw Exception("No response from server");
    
    print('from songExplorer1:' + response);
    
    try {
      final Map<String, dynamic> jsonMap = jsonDecode(response);
       final List<dynamic> dataList = jsonMap['data'] ?? [];
      
      list =
          dataList
      .map<String>((item) => (item as Map<String, dynamic>)['title'] as String)
      .toList();
    } catch (e) {
      print('JSON Parse Error: $e\nResponse: $response');
      throw Exception('Invalid server response');
    }
    setState(() => songs = list);
  }

  Future<void> _playSong(String filename) async {
    final request = jsonEncode({"action": "get_song", "data": {"filename": filename}});
    final bytes = await _socketManager.getSongBytes(request);
    
    if (bytes != null && bytes.isNotEmpty) {
      await _player.play(BytesSource(bytes)); 
    } else {
      print("Error: Received empty bytes");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Song Explorer")),
      body:
          songs.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: songs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(songs[index]),
                    onTap: () {
                      _playSong(songs[index]);
                    },
                  );
                },
              ),
    );
  }
}
