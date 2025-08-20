import 'dart:convert';

import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:mono/models/playlist.dart';
import 'package:mono/models/song.dart';
import 'package:mono/playlist/playlists/new_playlist.dart';
import 'package:mono/playlist/songs/songs_list.dart';
import 'package:mono/playlist/playlists/share_playlist.dart';
import 'package:mono/services/token_storage.dart';
import 'package:mono/services/socket_manager.dart';

class Playlists extends StatefulWidget {
  const Playlists({super.key});
  @override
  State<StatefulWidget> createState() {
    return _PlaylistsState();
  }
}

enum AppPage { playlists, songsInPlaylists, home }

class _PlaylistsState extends State<Playlists> {
  final _socketManager = SocketManager();
  List<Playlist> _playlists = [];

  @override
  void initState() {
    _getPlaylists();
    super.initState();
  }

  void _getPlaylists() async {
    final tokenData = await TokenStorage.getToken();
    if (tokenData == null || tokenData['token'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to log in to manage playlists.'),
        ),
      );
      return;
    }
    final getPlaylists = jsonEncode({
      "action": "get_playlists",
      "token": tokenData['token'],
      "data": {"id": tokenData['userId']},
    });
    final getPlaylistsResponse = await _socketManager.sendWithResponse(
      getPlaylists,
      timeout: Duration(seconds: 10),
    );
    if (getPlaylistsResponse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Couldn’t load your playlists. Please try again.'),
        ),
      );
      return;
    }
    final getPlaylistsData = jsonDecode(getPlaylistsResponse);
    if (getPlaylistsData['status'] == 200) {
      List<dynamic> playlistsJson = getPlaylistsData['data'];
      List<Playlist> playlists =
          playlistsJson
              .map((p) => Playlist.fromJson(p as Map<String, dynamic>))
              .toList();

      setState(() {
        _playlists = playlists;
      });
    }
  }

  void _addPlaylist(Playlist playlist) async {
    try {
      final tokenData = await TokenStorage.getToken();
      if (tokenData == null || tokenData['token'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You need to log in to manage playlists.'),
          ),
        );
        return;
      }
      final createPlaylist = jsonEncode({
        "action": "create_playlist",
        "token": tokenData['token'],
        "data": {"name": playlist.title},
      });
      final createPlaylistResponse = await _socketManager.sendWithResponse(
        createPlaylist,
        timeout: Duration(seconds: 10),
      );
      if (createPlaylistResponse == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Couldn’t create playlist.')),
        );
        return;
      }
      final createPLaylistData = jsonDecode(createPlaylistResponse);
      if (createPLaylistData['status'] == 200) {
        setState(() {
          _playlists.add(playlist);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Playlist ${playlist.title} created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorMessage =
            createPLaylistData['message'] as String? ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Couldn’t create playlist. ${errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error craeting playlist: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _removePlaylist(Playlist playlist) async {
    final tokenData = await TokenStorage.getToken();
    if (tokenData == null || tokenData['token'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to log in to manage playlists.'),
        ),
      );
      return;
    }
    final removePlaylist = jsonEncode({
      "action": "delete_playlist",
      "token": tokenData['token'],
      "data": {"playlist": playlist},
    });
    final removePlaylistResponse = await _socketManager.sendWithResponse(
      removePlaylist,
    );
    if (removePlaylistResponse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Couldn’t remove playlist. Please try again.'),
        ),
      );
      return;
    }
    final removePlaylistData = jsonDecode(removePlaylistResponse);
    if (removePlaylistData['status'] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Playlist ${playlist.title} was removed.'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        _playlists.remove(playlist);
      });
    }

    /*final _playlistIndex = _playlists.indexOf(playlist);
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 5),
        content: Text('Playlist deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _playlists.insert(_playlistIndex, playlist);
            });
          },
        ),
      ),
    );*/
  }

  void _removeSongFromPLaylist(Playlist playlist, Song song) async {
    final tokenData = await TokenStorage.getToken();
    if (tokenData == null || tokenData['token'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You need to log in to manage playlists.'),
        ),
      );
      return;
    }
    final getSongId = jsonEncode({
      "action": "get_song_id_by_filename",
      "data": song.title,
    });
    final songIdResponse = await _socketManager.sendWithResponse(
      getSongId,
      timeout: Duration(seconds: 10),
    );
    if (songIdResponse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn’t find details for ${song.title}')),
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
    final getPlaylistId = jsonEncode({
      "action": "get_playlist_id_by_name",
      "token": tokenData['token'],
      "data": playlist.title,
    });
    final playlistIdResponse = await _socketManager.sendWithResponse(
      getPlaylistId,
      timeout: Duration(seconds: 10),
    );
    if (playlistIdResponse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn’t find details for ${playlist.title}')),
      );
      return;
    }
    final playlistIdData = jsonDecode(playlistIdResponse);
    if (playlistIdData['status'] != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Playlist not found: ${playlistIdData['message']}'),
        ),
      );
      return;
    }
    final playlistId = playlistIdData['data']['playlist_id'] as int;
    final removeSong = jsonEncode({
      "action": "delete_song_from_playlist",
      "token": tokenData['token'],
      "data": {"playlist_id": playlistId, "song_id": songId},
    });
    final removeSongResponse = await _socketManager.sendWithResponse(
      removeSong,
      timeout: Duration(seconds: 10),
    );
    if (removeSongResponse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Couldn’t remove ${song.title} from ${playlist.title}. Please try again.',
          ),
        ),
      );
      return;
    }
    final removeSongData = jsonDecode(removeSongResponse);
    if (removeSongData['status'] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${song.title} removed from ${playlist.title}'),
          backgroundColor: Colors.green,
        ),
      );
      setState(() {
        playlist.songs.remove(song);
      });
    }
  }

  void _addNewPlaylist() {
    showDialog(
      context: context,
      builder: (ctx) => NewPlaylist(_addPlaylist, playlists: _playlists),
    );
  }

  void _addSongToPlaylist(Playlist playlist, Song song) async {
    try {
      final tokenData = await TokenStorage.getToken();
      if (tokenData == null || tokenData['token'] == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You need to log in to manage playlists.'),
          ),
        );
        return;
      }
      final getSongId = jsonEncode({
        "action": "get_song_id_by_filename",
        "data": song.title,
      });
      final songIdResponse = await _socketManager.sendWithResponse(
        getSongId,
        timeout: Duration(seconds: 10),
      );
      if (songIdResponse == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Couldn’t find details for ${song.title}')),
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
      final getPlaylistId = jsonEncode({
        "action": "get_playlist_id_by_name",
        "token": tokenData['token'],
        "data": playlist.title,
      });
      final playlistIdResponse = await _socketManager.sendWithResponse(
        getPlaylistId,
        timeout: Duration(seconds: 10),
      );
      if (playlistIdResponse == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Couldn’t find details for ${playlist.title}'),
          ),
        );
        return;
      }
      final playlistIdData = jsonDecode(playlistIdResponse);
      if (playlistIdData['status'] != 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Playlist not found: ${playlistIdData['message']}'),
          ),
        );
        return;
      }
      final playlistId = playlistIdData['data']['playlist_id'] as int;
      final addSongToPlaylist = jsonEncode({
        "action": "add_song_to_playlist",
        "token": tokenData['token'],
        "data": {"playlist_id": playlistId, "song_id": songId},
      });
      final addSongToPlaylistResponse = await _socketManager.sendWithResponse(
        addSongToPlaylist,
        timeout: Duration(seconds: 10),
      );
      if (addSongToPlaylistResponse == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Couldn’t add ${song.title} to ${playlist.title}'),
          ),
        );
        return;
      }
      final addSongToPlaylistData = jsonDecode(addSongToPlaylistResponse);
      if (addSongToPlaylistData['status'] == 200) {
        setState(() {
          for (Playlist p in _playlists) {
            if (p == playlist) {
              p.songs.add(song);
              return;
            }
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${song.title} added to ${playlist.title}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final errorMessage =
            addSongToPlaylistData['message'] as String? ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Couldn’t add ${song.title} to ${playlist.title} $errorMessage',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error adding song to playlist: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _sharePlaylist(String username, Playlist playlist) async {
    final tokenData = await TokenStorage.getToken();
    if (tokenData == null || tokenData['token'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please login to add songs to your account'),
        ),
      );
      return;
    }
    final getPlaylistId = jsonEncode({
      "action": "get_playlist_id_by_name",
      "token": tokenData['token'],
      "data": playlist.title,
    });
    final playlistIdResponse = await _socketManager.sendWithResponse(
      getPlaylistId,
      timeout: Duration(seconds: 10),
    );
    if (playlistIdResponse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Couldn’t find details for ${playlist.title}')),
      );
      return;
    }
    final playlistIdData = jsonDecode(playlistIdResponse);
    if (playlistIdData['status'] != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Playlist not found: ${playlistIdData['message']}'),
        ),
      );
      return;
    }
    final playlistId = playlistIdData['data']['playlist_id'] as int;

    final sharePlaylist = jsonEncode({
      "action": "share_playlist",
      "token": tokenData['token'],
      "data": {"recipient_username": username, "playlist_id": playlistId},
    });
    final sharePlaylistResponse = await _socketManager.sendWithResponse(
      sharePlaylist,
      timeout: Duration(seconds: 10),
    );
    if (sharePlaylistResponse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Couldn’t share ${playlist.title} with $username.'),
        ),
      );
      return;
    }
    final sharePlaylistData = jsonDecode(sharePlaylistResponse);
    if (sharePlaylistData['status'] == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${playlist.title} shared with ${username}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      final errorMessage =
          sharePlaylistData['message'] as String? ?? 'Unknown error';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Couldn’t share ${playlist.title} with $username: $errorMessage',
          ),
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
                backgroundColor: Colors.transparent,
                foregroundColor: colorScheme.onPrimary,
                title: Text(
                  'Your playlists',
                  style: textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _playlists.length,
                  itemBuilder:
                      (context, index) => Dismissible(
                        background: Container(color: colorScheme.error),
                        key: ValueKey(_playlists[index]),
                        onDismissed:
                            (direction) => _removePlaylist(_playlists[index]),
                        child: Center(
                          child: SizedBox(
                            width: 390,
                            height: 95,
                            child: Card(
                              color: colorScheme.primaryContainer,
                              margin: EdgeInsets.symmetric(vertical: 6),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => SongsList(
                                            removeSongFromPlaylist:
                                                _removeSongFromPLaylist,
                                            addSongToPlaylist:
                                                _addSongToPlaylist,
                                            playlist: _playlists[index],
                                            songs: _playlists[index].songs,
                                          ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _playlists[index].title,
                                              style: textTheme.titleMedium
                                                  ?.copyWith(
                                                    fontWeight: FontWeight.w600,
                                                    color:
                                                        colorScheme.onSurface,
                                                  ),
                                            ),
                                            Text(
                                              _playlists[index].songs.length ==
                                                      1
                                                  ? '${_playlists[index].songs.length} song'
                                                  : '${_playlists[index].songs.length} songs',
                                              style: textTheme.bodySmall
                                                  ?.copyWith(
                                                    color:
                                                        colorScheme
                                                            .onSurfaceVariant,
                                                  ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () {
                                          showDialog(
                                            context: context,
                                            builder:
                                                (ctx) => SharePlaylist(
                                                  sharePlaylist: _sharePlaylist,
                                                  playlist: _playlists[index],
                                                ),
                                          );
                                        },
                                        icon: Icon(Icons.share),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNewPlaylist,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 8,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}
