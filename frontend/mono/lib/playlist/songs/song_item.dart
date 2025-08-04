import 'package:flutter/material.dart';

import 'package:mono/models/song.dart';

class SongItem extends StatelessWidget {
  SongItem(this.song, {super.key});
  final Song song;
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Card(
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
                        song.title!,
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      subtitle: Text(
                        'Tap to play',
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
                            builder: (_) => Scaffold(
                              backgroundColor: colorScheme.surface,
                              appBar: AppBar(
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                title: Text(
                                  song.title!,
                                  style: textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              body: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.music_note,
                                      size: 80,
                                      color: colorScheme.primary,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      '🎵 Play Page Placeholder',
                                      style: textTheme.headlineSmall?.copyWith(
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
