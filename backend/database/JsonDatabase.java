package backend.database;

import backend.model.*;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.io.FileWriter;
import java.io.IOException;
import java.lang.reflect.Type;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class JsonDatabase {
    private static final String USERS_FILE= "backend/database/users.json";
    private static final String SONGS_FILE= "backend/database/songs.json";
    private static final String PLAYLISTS_FILE= "backend/database/playlists.json";
    private static final Gson gson= new Gson();

    public static List<User> loadUsers(){
        try{
            String json= Files.readString(Path.of(USERS_FILE));
            Type type = new TypeToken<List<User>>(){}.getType();
            return gson.fromJson(json, type);
        } catch (IOException e){
            e.printStackTrace();
            return new ArrayList<>();
        }
    }
    public static void saveUsers(List<User> users){
        try(FileWriter writer= new FileWriter(USERS_FILE)){
            gson.toJson(users, writer);
        } catch (IOException e){
            e.printStackTrace();
        }
    }
    public static void addUser(User user) {
        List<User> users = loadUsers();
        user.setId(users.size()+1);
        users.add(user);
        saveUsers(users);
    }

    public static User findByUsername(String username) {
        for (User u : loadUsers()) {
            if (u.getUserName().equals(username)) return u;
        }
        return null;
    }

    public static List<Song> loadSongs(){
        try{
            String json= Files.readString(Path.of(SONGS_FILE));
            Type type = new TypeToken<List<Song>>(){}.getType();
            return gson.fromJson(json, type);
        } catch (IOException e){
            e.printStackTrace();
            return new ArrayList<>();
        }
    }
    public static void saveSongs(List<Song> songs){
        try(FileWriter writer= new FileWriter(SONGS_FILE)){
            gson.toJson(songs, writer);
        } catch (IOException e){
            e.printStackTrace();
        }
    }
    public static void addSong(Song song) {
        List<Song> songs = loadSongs();
        song.setId(songs.size()+1);
        songs.add(song);
        saveSongs(songs);
    }

    public static List<Playlist> loadPlaylist(){
        try{
            String json= Files.readString(Path.of(PLAYLISTS_FILE));
            Type type = new TypeToken<List<Playlist>>(){}.getType();
            return gson.fromJson(json, type);
        } catch (IOException e){
            e.printStackTrace();
            return new ArrayList<>();
        }
    }
    public static void savePlaylists(List<Playlist> playlists){
        try(FileWriter writer= new FileWriter(PLAYLISTS_FILE)){
            gson.toJson(playlists, writer);
        } catch (IOException e){
            e.printStackTrace();
        }
    }
    public static void addPlaylist(Playlist playlist) {
        List<Playlist> playlists = loadPlaylist();
        playlist.setId(playlists.size()+1);
        playlists.add(playlist);
        savePlaylists(playlists);
    }
}
