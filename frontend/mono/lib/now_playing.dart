import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mono/services/socket_manager.dart';
import 'package:mono/widgets/circular_icon_button.dart';

import 'models/song.dart';

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage(this.song ,{super.key});
  final Song song;

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {
  late final _audioPlayer;
  late final _socketManager;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool isPlaying = true;
  bool isLiked = false; // For animated favorite button

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _socketManager = SocketManager();
    _playSong(widget.song.filename!);
    // Audio Player listening for state changes
    _audioPlayer.onPositionChanged.listen((position) {
      setState(() {
        _currentPosition = position;
      });
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      setState(() {
        _totalDuration = duration;
      });
    });

    _audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSong(String filename) async {
    final request = jsonEncode({
      "action": "get_song",
      "data": {"filename": filename},
    });
    final bytes = await _socketManager.getSongBytes(request);

    if (bytes != null && bytes.isNotEmpty) {
      await _audioPlayer.play(BytesSource(bytes));
    } else {
      print("Error: Received empty bytes");
    }
  }

  Future<void> _togglePlayButton() async {
    if(isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text("Now Playing", style: textTheme.titleLarge),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Blurred background layer
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),

          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.primary.withOpacity(0.6),
                  colorScheme.inversePrimary.withOpacity(0.4),
                  colorScheme.onPrimary.withOpacity(0.2),
                ],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  // Album Art
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerHighest,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            const Icon(Icons.music_note, size: 80),
                            // Optional overlay gradient
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withOpacity(0.2),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Song Title & Artist
                  Text(
                    widget.song.title ?? "Unknown Song",
                    style: textTheme.headlineSmall?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.song.artist ?? "Unknown Artist",
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 36),

                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      CircularIconButton(
                        icon: isLiked ? Icons.favorite : Icons.favorite_border,
                        onPressed: () {
                          setState(() {
                            isLiked = !isLiked;
                          });
                        },
                        backgroundColor: colorScheme.onPrimary,
                        iconColor: isLiked ? Colors.red : colorScheme.primary,
                      ),
                      CircularIconButton(
                        icon: Icons.share,
                        onPressed: () {},
                        backgroundColor: colorScheme.onPrimary,
                        iconColor: colorScheme.primary,
                      ),
                      CircularIconButton(
                        icon: Icons.playlist_add,
                        onPressed: () {},
                        backgroundColor: colorScheme.onPrimary,
                        iconColor: colorScheme.primary,
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Seek bar
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 7,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 14,
                      ),
                    ),
                    child: Slider(
                      value: 0.3,
                      onChanged: (v) {},
                      activeColor: colorScheme.primary,
                      inactiveColor: colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("1:20", style: textTheme.labelSmall),
                      Text("3:45", style: textTheme.labelSmall),
                    ],
                  ),

                  const Spacer(),

                  // Playback Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        iconSize: 36,
                        color: colorScheme.onSurface,
                        onPressed: () {},
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                          backgroundColor: colorScheme.primary,
                          foregroundColor: colorScheme.onPrimary,
                          elevation: 6,
                        ),
                        onPressed: () {
                          setState(() {
                            _togglePlayButton();
                          });
                        },
                        child: isPlaying ? const Icon(Icons.pause, size: 32,)
                            : const Icon(Icons.play_arrow, size: 32),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        iconSize: 36,
                        color: colorScheme.onSurface,
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}