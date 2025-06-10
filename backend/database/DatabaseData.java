package backend.database;

import backend.model.*;

import java.util.HashMap;
import java.util.Map;

public class DatabaseData {
    private Map<String, User> users= new HashMap<>();
    private Map<String, Song> songs= new HashMap<>();
    private Map<String, Playlist> playlists= new HashMap<>();

    public Map<String, User> getUsers() {
        return users;
    }

    public void setUsers(Map<String, User> users) {
        this.users = users;
    }

    public Map<String, Playlist> getPlaylists() {
        return playlists;
    }

    public void setPlaylists(Map<String, Playlist> playlists) {
        this.playlists = playlists;
    }

    public Map<String, Song> getSongs() {
        return songs;
    }

    public void setSongs(Map<String, Song> songs) {
        this.songs = songs;
    }
}
