package backend.controllers;

import backend.dto.Response;
import backend.model.Playlist;
import backend.model.Song;
import backend.model.User;
import backend.utils.JsonDatabase;
import backend.utils.TokenManager;

import java.util.*;

public class SongController {

    public Response<Void> addSong(String token, int songId) {
        User user = TokenManager.getUserByToken(token);
        if (user == null)
            return new Response<>(401, null, "Invalid token");

        Song song = JsonDatabase.getSongById(songId);
        if (song == null)
            return new Response<>(404, null, "Song not found");

        if (user.getSongs().contains(song))
            return new Response<>(400, null, "Song already in account");

        user.getSongs().add(song);
        JsonDatabase.saveUsers();
        return new Response<>(200, null, "Songs added successfully to your account");
    }

    public Response<Map> toggleLikeSong(String token, int songId) {
        User user = TokenManager.getUserByToken(token);
        if (user == null)
            return new Response<>(401, null, "Invalid token");

        Song song = JsonDatabase.getSongById(songId);
        if (song == null)
            return new Response<>(404, null, "Song not found");

        boolean liked = user.getLikedSongs().contains(song);
        if (liked) {
            user.getLikedSongs().remove(song);
            song.setLikes(song.getLikes() - 1);
        } else {
            user.getLikedSongs().add(song);
            song.setLikes(song.getLikes() + 1);
        }

        JsonDatabase.saveUsers();
        JsonDatabase.saveSongs();

        var responseData = new java.util.HashMap<String, Object>();
        responseData.put("song_id", songId);
        responseData.put("liked", liked);
        responseData.put("likes", song.getLikes());

        return new Response<>(200, responseData, liked ? "Song unliked" : "Song liked");
    }

    public Response<Map> addSongsToPlaylist(String token, int playlistId, List<String> songIds) {
        User user = TokenManager.getUserByToken(token);
        if (user == null)
            return new Response<>(401, null, "Invalid token");

        Playlist playlist = JsonDatabase.getPlaylistById(playlistId);
        if (playlist == null || !Integer.valueOf(playlist.getOwnerId()).equals(user.getId()))
            return new Response<>(404, null, "Playlist not found");

        List<Integer> addedSongs = new ArrayList<>();
        for (String id : songIds) {
            int intId = Integer.parseInt(id);
            Song song = JsonDatabase.getSongById(intId);
            if (song != null && !playlist.getSongIds().contains(intId)) {
                playlist.getSongs().add(song);
                addedSongs.add(intId);
            }
        }

        JsonDatabase.savePlaylists();

        var data = new java.util.HashMap<String, Object>();
        data.put("playlist_id", playlistId);
        data.put("added_songs", addedSongs);

        return new Response<>(200, data, "Songs added to playlist");
    }

    public Response<Void> deleteSongFromPlaylist(String token, int playlistId, int songId) {
        User user = TokenManager.getUserByToken(token);
        if (user == null)
            return new Response<>(401, null, "Invalid token");

        Playlist playlist = JsonDatabase.getPlaylistById(playlistId);
        if (playlist == null || !Integer.valueOf(playlist.getOwnerId()).equals(user.getId()))
            return new Response<>(404, null, "Playlist not found");

        if (!playlist.getSongIds().contains(songId)) {
            return new Response<>(400, null, "Song not found in playlist");
        }

        playlist.getSongIds().remove(songId);
        JsonDatabase.savePlaylists();
        return new Response<>(200, null, "Song removed from playlist successfully");
    }

    public Response<Object> createPlaylist(String token, String name) {
        User user = TokenManager.getUserByToken(token);
        if (user == null)
            return new Response<>(401, null, "Invalid token");

        for (Playlist playlist : JsonDatabase.loadPlaylists()) {
            if (Integer.valueOf(playlist.getOwnerId()).equals(user.getId()) && playlist.getName().equalsIgnoreCase(name)) {
                return new Response<>(409, null, "You already have a playlist with this name");
            }
        }

        Playlist playlist = new Playlist();
        playlist.setName(name);
        playlist.setOwnerId(user.getId());
        playlist.setSongs(new HashSet<>());

        JsonDatabase.addPlaylist(playlist);

        var data = new java.util.HashMap<String, Object>();
        data.put("playlist_id", playlist.getId());

        return new Response<>(200, data, "Playlist created successfully");
    }

    public Response<Void> shareSong(String token, String recipientUsername, int songId) {
        User sender = TokenManager.getUserByToken(token);
        if (sender == null)
            return new Response<>(401, null, "Invalid token");

        User recipient = JsonDatabase.findByUsername(recipientUsername);
        if (recipient == null)
            return new Response<>(404, null, "Recipient user not found");

        if (!recipient.isSharePermission())
            return new Response<>(403, null, "Recipient has not enabled song sharing");

        if (!recipient.getSongs().contains(JsonDatabase.getSongById(songId))) {
            recipient.getSongs().add(JsonDatabase.getSongById(songId));
            JsonDatabase.saveUsers();
        }

        return new Response<>(200, null, "Song shared with " + recipientUsername);
    }

    public Response<Void> sharePlaylist(String token, String recipientUsername, int playlistId) {
        User sender = TokenManager.getUserByToken(token);
        if (sender == null)
            return new Response<>(401, null, "Invalid token");

        Playlist playlist = JsonDatabase.getPlaylistById(playlistId);
        if (playlist == null || !Integer.valueOf(playlist.getOwnerId()).equals(sender.getId()))
            return new Response<>(403, null, "Playlist not found or does not belong to you");

        User recipient = JsonDatabase.findByUsername(recipientUsername);
        if (recipient == null)
            return new Response<>(404, null, "Recipient not found");

        if (!recipient.isSharePermission())
            return new Response<>(403, null, "Recipient has disabled sharing");

        Playlist copy = new Playlist(playlist.getName() + " (shared)",JsonDatabase.findUserById(recipient.getId()));
        copy.setSongs(playlist.getSongs());

        JsonDatabase.addPlaylist(copy);

        return new Response<>(200, null, "Playlist shared with " + recipientUsername);
    }
}