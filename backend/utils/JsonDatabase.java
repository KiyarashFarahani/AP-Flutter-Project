package backend.utils;

import backend.exceptions.*;
import backend.model.*;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.io.FileWriter;
import java.io.IOException;
import java.lang.reflect.Type;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.List;

public class JsonDatabase {
    private static final String USERS_FILE = "data/users.json";
    private static final String SONGS_FILE = "data/songs.json";
    private static final String PLAYLISTS_FILE = "data/playlists.json";
    private static final Gson gson = new Gson();
    private static List<User> users = loadUsers();
    private static List<Song> songs = loadSongs();
    private static List<Playlist> playlists = loadPlaylists();

    public static List<User> loadUsers() {
        try {
            String json= Files.readString(Path.of(USERS_FILE));
            Type type = new TypeToken<List<User>>(){}.getType();
            return gson.fromJson(json, type);
        } catch (IOException e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    public static void saveUsers() {
        try(FileWriter writer = new FileWriter(USERS_FILE)){
            gson.toJson(users, writer);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static synchronized void addUser(User user) {
        user.setId(users.size()+1);
        users.add(user);
        saveUsers();
    }

    public static User findByUsername(String username) {
        for (User u : loadUsers()) {
            if (u.getUserName().equals(username)) return u;
        }
        return null;
    }

    public static User findUserById(int Id) throws UserIdNotFoundException {
        for(User user : users) {
            if(user.getId()==Id) {
                return user;
            }
        }
        throw new UserIdNotFoundException("User ID not found!");
    }

    public static List<Song> loadSongs() {
        try {
            String json = Files.readString(Path.of(SONGS_FILE));
            Type type = new TypeToken<List<Song>>(){}.getType();
            return gson.fromJson(json, type);
        } catch (IOException e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    public static void saveSongs() {
        try(FileWriter writer= new FileWriter(SONGS_FILE)){
            gson.toJson(songs, writer);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void addSong(Song song) {
        song.setId(songs.size()+1);
        songs.add(song);
        saveSongs();
    }

    public static Song getSongById(int songId) throws SongIdNotFoundException {
        for(Song song : songs) {
            if(song.getId()==songId) {
                return song;
            }
        }
        throw new SongIdNotFoundException("Song ID not found!");
    }

    public static Playlist getPlaylistById(int playlistId) throws PlaylistIdNotFoundException {
        for(Playlist playlist : playlists) {
            if(playlist.getId()==playlistId) {
                return playlist;
            }
        }
        throw new PlaylistIdNotFoundException("Playlist ID not found!");
    }

    public static List<Playlist> loadPlaylists(){
        try {
            String json= Files.readString(Path.of(PLAYLISTS_FILE));
            Type type = new TypeToken<List<Playlist>>(){}.getType();
            return gson.fromJson(json, type);
        } catch (IOException e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    public static void savePlaylists(){
        try(FileWriter writer= new FileWriter(PLAYLISTS_FILE)) {
            gson.toJson(playlists, writer);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static void addPlaylist(Playlist playlist) {
        playlist.setId(playlists.size()+1);
        playlists.add(playlist);
        savePlaylists();
    }

    public static synchronized void deleteUser(User user) {
        users.removeIf(u -> u.getId() == user.getId());
        saveUsers();
    }
}
