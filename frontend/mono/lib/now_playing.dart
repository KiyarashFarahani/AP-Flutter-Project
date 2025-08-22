import 'dart:async';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mono/services/audio_service.dart';
import 'package:mono/widgets/circular_icon_button.dart';

import 'models/song.dart';

class NowPlayingPage extends StatefulWidget {
  const NowPlayingPage(this.song ,{super.key});
  final Song song;

  @override
  State<NowPlayingPage> createState() => _NowPlayingPageState();
}

class _NowPlayingPageState extends State<NowPlayingPage> {
  late final AudioService audioService;
  bool isPlaying = true;
  bool isLiked = false;
  late StreamSubscription<PlayerState> playerStateSubscription;
  late StreamSubscription<Duration> positionSubscription;
  late StreamSubscription<Duration> durationSubscription;

  Duration currentPosition = Duration.zero;
  Duration totalDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    audioService = AudioService();

    currentPosition = audioService.position;
    totalDuration = audioService.duration;

    if (widget.song.duration != null && widget.song.duration! > 0) {
      totalDuration = Duration(seconds: widget.song.duration!);
      audioService.setDuration(totalDuration);
    }

    if (widget.song.filename != null) {
      audioService.playSong(
        widget.song.filename!,
        title: widget.song.title,
        artist: widget.song.artist,
        durationSeconds: widget.song.duration,
      );
    }
    else print("Error: Song filename is null");

    playerStateSubscription = audioService.player.onPlayerStateChanged.listen((state) {
      if (mounted) {
        setState(() {
          isPlaying = state == PlayerState.playing;
        });
      }
    });

    positionSubscription = audioService.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          currentPosition = position;
        });
      }
    });

    durationSubscription = audioService.durationStream.listen((duration) {
      if (mounted) {
        setState(() {
          totalDuration = duration;
        });
      }
    });
  }

  @override
  void dispose() {
    playerStateSubscription.cancel();
    positionSubscription.cancel();
    durationSubscription.cancel();
    super.dispose();
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
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
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),

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
                      value: totalDuration.inSeconds > 0
                          ? (currentPosition.inSeconds / totalDuration.inSeconds).clamp(0.0, 1.0)
                          : 0.0,
                      onChanged: totalDuration.inSeconds > 0 ? (value) {
                        final newPos = Duration(
                          seconds: (value * totalDuration.inSeconds).round(),
                        );
                        audioService.seekTo(newPos);
                      } : null,
                      activeColor: colorScheme.primary,
                      inactiveColor: colorScheme.primary.withOpacity(0.3),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatTime(currentPosition), style: textTheme.labelSmall),
                      Text(
                          totalDuration > Duration.zero
                              ? formatTime(totalDuration)
                              : '--:--',
                          style: textTheme.labelSmall
                      ),
                    ],
                  ),

                  const Spacer(),

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
                        onPressed: () async {
                          await audioService.togglePlayPause();
                          setState(() {
                            isPlaying = audioService.isPlaying;
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