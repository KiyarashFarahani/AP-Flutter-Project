import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mono/services/song_service.dart';

class SongExplorer extends StatefulWidget {
  const SongExplorer({super.key});
  @override
  _SongExplorerState createState() => _SongExplorerState();
}

class _SongExplorerState extends State<SongExplorer> {
  List<String> songs = [];

  @override
  void initState() {
    super.initState();
    loadSongs();
  }



// Modify loadSongs
void loadSongs() async {
  try {
    final songService = SongService(serverIp: '10.0.2.2', serverPort: 4321);
    await songService.connect();
    
    if (!songService.isConnected) {
      throw Exception('Connection failed');
    }
    
    final list = await songService.getSongList(); 
    setState(() => songs = list);
  } catch (e) {
    print('Error loading songs: $e');
    setState(() => songs = ['Error: ${e.toString()}']);
  }
}

  @override
 Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Song Explorer")),
      body: songs.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: songs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(songs[index]),
                  onTap: () {
                    print("Selected: ${songs[index]}");
                    // later: send "get_song" request here
                  },
                );
              },
            ),
    );
  }
}
