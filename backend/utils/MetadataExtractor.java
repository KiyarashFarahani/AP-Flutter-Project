package backend.utils;

import backend.model.Song;
import org.jaudiotagger.audio.AudioFile;
import org.jaudiotagger.audio.AudioFileIO;
import org.jaudiotagger.tag.FieldKey;
import org.jaudiotagger.tag.Tag;
import org.jaudiotagger.tag.images.Artwork;

import java.io.File;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.HashSet;

public class MetadataExtractor {
    public static List<Song> extractMetadataFromDirectory(String musicDirectoryPath) {
        List<Song> songs = new ArrayList<>();
        File musicDir = new File(musicDirectoryPath);
        
        if (!musicDir.exists() || !musicDir.isDirectory()) return songs;
        
        File[] musicFiles = musicDir.listFiles((dir, name) -> 
            name.toLowerCase().endsWith(".mp3") || 
            name.toLowerCase().endsWith(".wav") || 
            name.toLowerCase().endsWith(".flac") ||
            name.toLowerCase().endsWith(".m4a")
        );
        
        if (musicFiles == null) return songs;
        
        for (File musicFile : musicFiles) {
            try {
                Song song = extractMetadataFromFile(musicFile);
                if (song != null)
                    songs.add(song);
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
        return songs;
    }

    public static Song extractMetadataFromFile(File musicFile) {
        try {
            AudioFile audioFile = AudioFileIO.read(musicFile);
            Tag tag = audioFile.getTag();

            String title = musicFile.getName().replaceFirst("[.][^.]+$", "");
            String artist = "Unknown Artist";
            String album = "Unknown Album";
            String genre = "Unknown Genre";
            int duration = (int) audioFile.getAudioHeader().getTrackLength();
            int year = 0;
            String coverArtUrl = null;
            String lyrics = null;

            if (tag != null) {
                String tagTitle = tag.getFirst(FieldKey.TITLE);
                if (tagTitle != null && !tagTitle.trim().isEmpty()) {
                    title = tagTitle.trim();
                }

                String tagArtist = tag.getFirst(FieldKey.ARTIST);
                if (tagArtist != null && !tagArtist.trim().isEmpty()) {
                    artist = tagArtist.trim();
                }

                String tagAlbum = tag.getFirst(FieldKey.ALBUM);
                if (tagAlbum != null && !tagAlbum.trim().isEmpty()) {
                    album = tagAlbum.trim();
                }
                
                String tagGenre = tag.getFirst(FieldKey.GENRE);
                if (tagGenre != null && !tagGenre.trim().isEmpty()) {
                    genre = tagGenre.trim();
                }
                
                String tagYear = tag.getFirst(FieldKey.YEAR);
                if (tagYear != null && !tagYear.trim().isEmpty()) {
                    try {
                        year = Integer.parseInt(tagYear.trim());
                    } catch (Exception e) {}
                }

                String tagLyrics = tag.getFirst(FieldKey.LYRICS);
                if (tagLyrics != null && !tagLyrics.trim().isEmpty()) {
                    lyrics = tagLyrics.trim();
                }

                Artwork artwork = tag.getFirstArtwork();
                if (artwork != null && artwork.getBinaryData() != null) {
                    //TODO
                    coverArtUrl = "cover";
                }
            }

            Song song = new Song(
                title, artist, album, genre, duration, year,
                musicFile.getPath(), coverArtUrl, lyrics
            );
            
            song.setPlayCount(0);
            song.setLikes(0);
            song.setCreatedAt(new Date());
            song.setUpdatedAt(new Date());
            song.setIsShareable(true);
            song.setLikedByUsers(new HashSet<>());
            
            return song;
            
        } catch (Exception e) {
            e.printStackTrace();
            return null;
        }
    }
}
