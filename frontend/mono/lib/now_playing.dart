import 'package:flutter/material.dart';

class NowPlayingPage extends StatelessWidget {
  const NowPlayingPage({super.key});

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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Album Art
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  color: colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.music_note, size: 80),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Song Title & Artist
            Text(
              "Song Title",
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              "Artist Name",
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  icon: Icon(Icons.favorite_border),
                  label: Text("Like"),
                  onPressed: () {},
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.share),
                  label: Text("Share"),
                  onPressed: () {},
                ),
                ElevatedButton.icon(
                  icon: Icon(Icons.playlist_add),
                  label: Text("Add to Playlist"),
                  onPressed: () {},
                ),
              ],
            ),

            // Seek bar (placeholder)
            Slider(
              value: 0.3,
              onChanged: (v) {},
              activeColor: colorScheme.primary,
              inactiveColor: colorScheme.primary.withOpacity(0.3),
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
                  icon: Icon(Icons.skip_previous),
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
                    elevation: 4,
                  ),
                  onPressed: () {},
                  child: const Icon(Icons.play_arrow, size: 32),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(Icons.skip_next),
                  iconSize: 36,
                  color: colorScheme.onSurface,
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
