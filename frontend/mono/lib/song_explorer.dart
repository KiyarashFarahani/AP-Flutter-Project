import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'package:marquee/marquee.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mono/services/socket_manager.dart';
import 'package:mono/services/token_storage.dart';
import 'package:mono/models/song.dart';

import 'now_playing.dart';

class SongExplorer extends StatefulWidget {
  const SongExplorer({super.key});
  @override
  _SongExplorerState createState() => _SongExplorerState();
}

class _SongExplorerState extends State<SongExplorer> {
  final _socketManager = SocketManager();
  final _player = AudioPlayer();
  List<Song> songs = [];
  late List<Song> filteredSongs;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSongs();
    _searchController.addListener(_filterSongs);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterSongs() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      songs = filteredSongs
              .where((song) => song.title!.toLowerCase().contains(query))
              .toList();
    });
  }

  Future<void> _loadSongs() async {
    final listSongsRequest = jsonEncode({"action": "list_songs"});
    final response = await _socketManager.sendWithResponse(
      listSongsRequest,
      timeout: Duration(seconds: 10),
    );

    if (response == null) throw Exception("No response from server");

    try {
      final Map<String, dynamic> jsonMap = jsonDecode(response);
      final List<dynamic> songsJsonList = jsonMap['data'] as List<dynamic>;

      final List<Song> list =
          songsJsonList
              .map(
                (songsJson) => Song(
                  filename: songsJson['filename'] ?? 'Unknown',
                  title: songsJson['title'] ?? 'Unknown',
                  artist: songsJson['artist'] ?? 'Unknown',
                  cover: songsJson['cover'] ?? '',
                ),
              )
              .toList();

      setState(() => songs = filteredSongs = list,);
    } catch (e) {
      print('JSON Parse Error: $e\nResponse: $response');
      throw Exception('Invalid server response');
    }
  }

  Future<void> _downloadSong(String filename) async {
  final request = jsonEncode({
    "action": "get_song",
    "data": {"filename": filename},
  });

  final bytes = await _socketManager.getSongBytes(request);

  if (bytes != null && bytes.isNotEmpty) {
    final directory = await getExternalStorageDirectory();

    if (directory != null) {
      final file = File('${directory.path}/$filename');

      await file.writeAsBytes(bytes, flush: true);

      print('Song saved at: ${file.path}');
    } else {
      print('Could not get external storage directory');
    }
  } else {
    print('No bytes received');
  }
}

  Future<void> _addSongToAccount(String filename) async {
    try {
      final getSongIdRequest = jsonEncode({
        "action": "get_song_id_by_filename",
        "data": filename,
      });

      final songIdResponse = await _socketManager.sendWithResponse(
        getSongIdRequest,
        timeout: Duration(seconds: 10),
      );

      if (songIdResponse == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to get song information')),
        );
        return;
      }

      final songIdData = jsonDecode(songIdResponse);
      if (songIdData['status'] != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Song not found: ${songIdData['message']}')),
        );
        return;
      }

      final songId = songIdData['data']['song_id'] as int;

      final tokenData = await TokenStorage.getToken();
      if (tokenData == null || tokenData['token'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please login to add songs to your account')),
        );
        return;
      }

      final addSongRequest = jsonEncode({
        "action": "add_song_to_user",
        "token": tokenData['token'],
        "data": {"songId": songId},
      });

      final addSongResponse = await _socketManager.sendWithResponse(
        addSongRequest,
        timeout: Duration(seconds: 10),
      );

      if (addSongResponse == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add song to account')),
        );
        return;
      }

      final addSongData = jsonDecode(addSongResponse);
      if (addSongData['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Song added to your account successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorMessage = addSongData['message'] as String? ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add song: $errorMessage'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error adding song to account: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primary,
                  colorScheme.inversePrimary,
                  colorScheme.onPrimary,
                ],
              ),
            ),
          ),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Color.fromRGBO(0, 0, 0, 0.2)),
          ),
          Column(
            children: [
              AppBar(
                title: Text(
                  'Song Explorer',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                scrolledUnderElevation: 0,
                automaticallyImplyLeading: false,
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Search songs...',
                    hintStyle: textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                    ),
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    filled: true,
                    fillColor: Colors.black26,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              Expanded(
                child:
                    songs.isEmpty
                        ? Center(child: CircularProgressIndicator())
                        : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.7,
                              ),
                          itemCount: songs.length,
                          itemBuilder: (context, index) {
                            return InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => NowPlayingPage(
                                      songs[index],
                                    ),
                                  ),
                                );
                              },
                              onLongPress: () {
                                showModalBottomSheet(
                                  context: context,
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    52,
                                    52,
                                    52,
                                  ),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  builder: (context) {
                                    return Wrap(
                                      children: [
                                        ListTile(
                                          leading: const Icon(
                                            Icons.bookmark_added_outlined,
                                            color: Colors.white,
                                          ),
                                          title: Text(
                                            'Add song to account',
                                            style: textTheme.titleMedium
                                                ?.copyWith(color: Colors.white),
                                          ),
                                          onTap: () async {
                                            Navigator.pop(context);
                                            await _addSongToAccount(songs[index].filename!);
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(
                                            Icons.share,
                                            color: Colors.white,
                                          ),
                                          title: Text(
                                            'Share Song',
                                            style: textTheme.titleMedium
                                                ?.copyWith(color: Colors.white),
                                          ),
                                          onTap: () {
                                            Navigator.pop(context);
                                            // TODO: implement sharing
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(
                                            Icons.favorite_border,
                                            color: Colors.white,
                                          ),
                                          title: Text(
                                            'Like Song',
                                            style: textTheme.titleMedium
                                                ?.copyWith(color: Colors.white),
                                          ),
                                          onTap: () {
                                            Navigator.pop(context);
                                            // TODO: implement liking logic
                                          },
                                        ),
                                        ListTile(
                                          leading: const Icon(
                                            Icons.download,
                                            color: Colors.white,
                                          ),
                                          title: Text(
                                            'Download',
                                            style: textTheme.titleMedium
                                                ?.copyWith(color: Colors.white),
                                          ),
                                          onTap: () {
                                            Navigator.pop(context);
                                            _downloadSong(songs[index].filename!);
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      'assets/images/default.png',
                                      height: 120,
                                      width: double.infinity,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  buildSongTitle(
                                    songs[index].title!.replaceAll('.mp3', ''),
                                    100,
                                    textTheme,
                                    colorScheme,
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    songs[index].artist ?? 'Unknown Artist',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget buildSongTitle(
  String title,
  double maxWidth,
  TextTheme textTheme,
  ColorScheme colorScheme,
) {
  final textPainter = TextPainter(
    text: TextSpan(
      text: title,
      style: textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: colorScheme.onSurface,
      ),
    ),
    maxLines: 1,
    textDirection: TextDirection.ltr,
  )..layout();

  final textWidth = textPainter.width;

  if (textWidth > maxWidth) {
    return SizedBox(
      height: 20,
      width: maxWidth,
      child: Marquee(
        text: title,
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        scrollAxis: Axis.horizontal,
        blankSpace: 20,
        velocity: 20,
        pauseAfterRound: const Duration(seconds: 0),
      ),
    );
  } else {
    return SizedBox(
      width: maxWidth,
      child: Text(
        title,
        style: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        maxLines: 1,
        overflow: TextOverflow.clip,
      ),
    );
  }
}