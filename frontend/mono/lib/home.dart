import 'package:flutter/material.dart';
import 'dart:ui';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:io';
import 'package:mono/services/socket_manager.dart';
import 'package:mono/models/song.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mono/services/token_storage.dart';

import 'now_playing.dart';
import 'song_explorer.dart';
import 'main_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final _socketManager = SocketManager();
  List<Song> songs = [];
  String filter = 'Date';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSongsWithRetry();
  }

  Future<void> _loadSongsWithRetry() async {
    print('Waiting for socket connection...');

    int attempts = 0;
    while (!_socketManager.isConnected && attempts < 10) {
      attempts++;
      print('attempt $attempts / 10');

      if (!_socketManager.isConnected) {

        try {
          await _socketManager.connect();
          await Future.delayed(Duration(milliseconds: 500));
        }
        catch (e) {
          print('Connection attempt $attempts failed: $e');
        }
      }
      
      await Future.delayed(Duration(milliseconds: 500));
    }
    
    if (_socketManager.isConnected) {
      print('Socket connected, loading songs...');
      await _loadSongs();
    } else {
      print('Failed to establish connection after 10 attempts');
      setState(() {
        isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect to server. Pull down to retry.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
            action: SnackBarAction(
              label: 'Retry',
              onPressed: () => _refreshAndReconnect(),
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadSongs() async {
    print('Starting to load songs...');
    try {
      final List<Song> list;
      final listSongsRequest = jsonEncode({"action": "list_songs"});
      print('Sending request: $listSongsRequest');
      
      final response = await _socketManager.sendWithResponse(
        listSongsRequest,
        timeout: Duration(seconds: 10),
      );

      print('Received response: $response');
      if (response == null) throw Exception("No response from server");
      
      try {
        final Map<String, dynamic> jsonMap = jsonDecode(response);
        print('Parsed JSON: $jsonMap');
        final List<dynamic> dataList = jsonMap['data'] ?? [];
        print('Data list: $dataList');
        
        list = dataList
            .map<Song>((item) => Song.fromJson(item as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print('JSON Parse Error: $e\nResponse: $response');
        throw Exception('Invalid server response');
      }
      
      setState(() {
        songs = list;
        isLoading = false;
      });
      print('Songs loaded successfully: ${songs.length} songs');
    } catch (e) {
      print('Error loading songs: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _addSong() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(
                Icons.folder,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Add from local files'),
              onTap: () async {
                Navigator.pop(context);
                await _pickAndUploadSong();
              },
            ),
            ListTile(
              leading: Icon(
                Icons.cloud_download,
                color: Theme.of(context).colorScheme.primary,
              ),
              title: const Text('Choose from server'),
              onTap: () {
                Navigator.pop(context);
                _showServerSongPicker();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _sortSongs() {
    if (songs.isEmpty) return;
    
    setState(() {
      if (filter == 'Date') {
        songs = songs.reversed.toList();
      } else {
        songs.sort((a, b) => (a.title ?? '').compareTo(b.title ?? ''));
      }
    });
  }

  Future<void> _pickAndUploadSong() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp3', 'wav', 'm4a', 'aac'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 20),
                  Expanded(
                    child: Text(
                      'Uploading ${file.name}...',
                      overflow: TextOverflow.ellipsis,
                      maxLines: 2,
                    ),
                  ),
                ],
              ),
            );
          },
        );

        try {
          Uint8List? bytes;
          if (file.bytes != null && file.bytes!.isNotEmpty) {
            // file is already in memory
            bytes = file.bytes!;
          } else if (file.path != null) {
            // file is on disk. read it:
            try {
              final fileObj = File(file.path!);
              if (await fileObj.exists()) {
                bytes = await fileObj.readAsBytes();
              }
            } catch (e) {
              print('Error reading file from path: $e');
            }
          }
          
          if (bytes != null && bytes.isNotEmpty) {
            print('File read successfully: ${file.name}, size: ${bytes.length} bytes');
            final success = await _socketManager.uploadSong(
              file.name,
              bytes,
              await _getStoredToken(),
            );

            Navigator.pop(context);

            if (success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Song uploaded successfully!'),
                  backgroundColor: Colors.green,
                ),
              );

              await _loadSongs();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Upload response unclear. Checking if file was received...'),
                  backgroundColor: Colors.orange,
                  duration: Duration(seconds: 3),
                ),
              );
              
              await Future.delayed(Duration(seconds: 2));
              await _loadSongs();
            }
          } else {
            Navigator.pop(context);
            String errorMessage = 'Could not read file. ';
            if (file.bytes == null && file.path == null) {
              errorMessage += 'File data is not available.';
            } else if (file.bytes != null && file.bytes!.isEmpty) {
              errorMessage += 'File is empty.';
            } else if (file.path != null) {
              errorMessage += 'File path is invalid or file does not exist.';
            }
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        } catch (e) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error uploading song: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking file: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showServerSongPicker() {
    final mainPage = MainPage.of(context);
    if (mainPage != null) {
      mainPage.switchToTab(2); // SongExplorer's index
    }
  }

  Future<void> _refreshAndReconnect() async {
    print('Starting refresh and reconnect process...');

    if (!_socketManager.isConnected) {
      print('Socket disconnected, attempting to reconnect...');
      
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reconnecting to server...'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 2),
          ),
        );

        await _socketManager.connect();
        await Future.delayed(Duration(milliseconds: 500));
        
        if (_socketManager.isConnected) {
          print('Successfully reconnected to server');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reconnected successfully!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          print('Failed to reconnect to server');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to reconnect. Please check your connection.'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 3),
            ),
          );
          return;
        }
      } catch (e) {
        print('Error during reconnection: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Reconnection error: $e'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
    } else {
      print('Socket is already connected, proceeding with refresh...');
    }

    await _loadSongs();
    print('Refresh and reconnect process completed');
  }

  Future<String> _getStoredToken() async {
    final tokenData = await TokenStorage.getToken();
    return tokenData?['token'] ?? '';
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
                elevation: 0,
                scrolledUnderElevation: 0,
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    Text(
                      'Your Songs',
                      style: textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _socketManager.isConnected 
                            ? Colors.green 
                            : Colors.red,
                      ),
                    ),
                  ],
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: filter,
                        icon: Icon(
                          Icons.filter_list,
                          color: Colors.white,
                        ),
                        dropdownColor: colorScheme.primaryContainer.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(12),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        items: ['Date', 'Alphabetical']
                            .map((e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() => filter = val);
                            _sortSongs();
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _socketManager.isConnected 
                                  ? 'Loading your songs...'
                                  : 'Connecting to server...',
                              style: textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            if (!_socketManager.isConnected) ...[
                              const SizedBox(height: 8),
                              Text(
                                'Please wait while we establish connection',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                                        : songs.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.music_off,
                                      size: 64,
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No songs found',
                                      style: textTheme.headlineSmall?.copyWith(
                                        color: Colors.white.withOpacity(0.7),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Add some songs to get started',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                        : RefreshIndicator(
                            onRefresh: () async {
                              return _refreshAndReconnect();
                            },
                            color: Colors.white,
                            backgroundColor: colorScheme.primary,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              itemCount: songs.length,
                              itemBuilder: (context, index) => Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 4,
                              shadowColor: Colors.black.withOpacity(0.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                leading: Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.music_note,
                                    color: colorScheme.onPrimaryContainer,
                                    size: 24,
                                  ),
                                ),
                                title: Text(
                                  songs[index].title ?? 'Unknown Title',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                subtitle: Text(
                                  songs[index].artist ?? 'Unknown Artist',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                trailing: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: colorScheme.primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Icon(
                                    Icons.play_arrow,
                                    color: colorScheme.onPrimary,
                                    size: 20,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => NowPlayingPage(songs[index]),
                                    ),
                                  );
                                 },
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
        key: const ValueKey('home_fab'),
        heroTag: 'home_upload_fab',
        onPressed: _addSong,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 8,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }
}