import 'package:flutter/material.dart';
import 'package:mono/services/audio_service.dart';

class MiniPlayerBar extends StatefulWidget {
  const MiniPlayerBar({Key? key}) : super(key: key);

  @override
  State<MiniPlayerBar> createState() => _MiniPlayerBarState();
}

class _MiniPlayerBarState extends State<MiniPlayerBar> {
  final audioService = AudioService();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      padding: EdgeInsets.symmetric(horizontal: 16),
      color: Colors.grey[900],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Song info
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                audioService.currentSongTitle ?? "Unknown Song",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              Text(
                audioService.currentSongArtist ?? "Unknown Artist",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),

          // Controls
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.skip_previous, color: Colors.white),
                onPressed: () => audioService.previousSong(),
              ),
              IconButton(
                icon: Icon(audioService.isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white),
                onPressed: () {
                  setState(() {
                    audioService.togglePlayPause();
                  });
                },
              ),
              IconButton(
                icon: Icon(Icons.skip_next, color: Colors.white),
                onPressed: () => audioService.nextSong(),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Colors.white),
                onPressed: () {
                  audioService.stop();
                  setState(() {}); // refresh the bar
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}