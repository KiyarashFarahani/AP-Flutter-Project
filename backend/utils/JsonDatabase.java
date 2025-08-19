package backend.utils;

import backend.exceptions.*;
import backend.model.*;
import com.google.gson.*;
import com.google.gson.reflect.TypeToken;

import java.io.FileWriter;
import java.io.IOException;
import java.lang.reflect.Type;
import java.nio.file.Files;
import java.nio.file.Path;
import java.time.LocalTime;
import java.util.ArrayList;
import java.util.List;
import java.util.HashSet;
import java.util.HashMap;

public class JsonDatabase {
    private static final String USERS_FILE = "data/users.json";
    private static final String SONGS_FILE = "data/songs.json";
    private static final String PLAYLISTS_FILE = "data/playlists.json";
    private static final String ADMINS_FILE = "data/admins.json";

    static Gson gson = new GsonBuilder()
            .registerTypeAdapter(LocalTime.class, new JsonDeserializer<LocalTime>() {
                @Override
                public LocalTime deserialize(JsonElement json, Type typeOfT, JsonDeserializationContext context)
                        throws JsonParseException {
                    return LocalTime.parse(json.getAsString());
                }
            })
            .setPrettyPrinting()
            .create();

    private static List<User> users = loadUsers();
    private static List<Song> songs = loadSongs();
    private static List<Playlist> playlists = loadPlaylists();
    private static List<Admin> admins = loadAdmins();

    public static List<User> loadUsers() {
        try {
            String json = Files.readString(Path.of(USERS_FILE));
            Type type = new TypeToken<List<User>>(){}.getType();
            List<User> loadedUsers = gson.fromJson(json, type);

            if (loadedUsers != null)
                for (User user : loadedUsers)
                    ensureUserCollectionsInitialized(user);

            
            return loadedUsers;
        } catch (IOException e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    private static void ensureUserCollectionsInitialized(User user) {
        if (user.getLikedSongs() == null)
            user.setLikedSongs(new HashSet<>());

        if (user.getPlaylists() == null)
            user.setPlaylists(new HashSet<>());

        if (user.getSongs() == null)
            user.setAllSongs(new HashSet<>());

        if (user.getDownloadedSongs() == null)
            user.setDownloadedSongs(new HashMap<>());
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

    public static User findUserByUsername(String username) {
        for (User u : users) {
            if (u.getUsername().equals(username)) return u;
        }
        return null;
    }

    public static User findUserById(int Id) {
        for(User user : users) {
            if(user.getId()==Id) {
                return user;
            }
        }
        return null;
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
        try(FileWriter writer = new FileWriter(SONGS_FILE)){
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

    public static Song findSongById(int songId) {
        for(Song song : songs) {
            if(song.getId()==songId) return song;
        }
        return null;
    }

    public static Song findSongByFilename(String filename) {
        for(Song song : songs) {
            if(song.getFilePath() != null) {
                if(song.getFilePath().startsWith("data/musics/")) {
                    String cleanPath = song.getFilePath().substring("data/musics/".length());
                    if(cleanPath.equals(filename)) return song;
                }
            }
        }
        return null;
    }

    public static Playlist findPlaylistById(int playlistId) {
        for(Playlist playlist : playlists) {
            if(playlist.getId()==playlistId) return playlist;
        }
        return null;
    }

    public static List<Playlist> loadPlaylists() {
        try {
            String json= Files.readString(Path.of(PLAYLISTS_FILE));
            Type type = new TypeToken<List<Playlist>>(){}.getType();
            return gson.fromJson(json, type);
        } catch (IOException e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    public static void savePlaylists() {
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

    public static List<Admin> loadAdmins() {
        try {
            String json = Files.readString(Path.of(ADMINS_FILE));
            Type type = new TypeToken<List<Admin>>(){}.getType();
            return gson.fromJson(json, type);
        } catch (IOException e) {
            e.printStackTrace();
            return new ArrayList<>();
        }
    }

    public static void addAdmin(Admin admin) {
        admin.setId(users.size()+1);
        users.add(admin);
        admins.add(admin);
        saveAdmins();
    }

    public static void saveAdmins() {
        try(FileWriter writer = new FileWriter(ADMINS_FILE)) {
            gson.toJson(admins, writer);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static Admin findAdminByUsername(String username) {
        for (Admin admin : admins) {
            if (admin.getUsername().equals(username)) return admin;
        }
        return null;
    }

    public static Admin findAdminById(int id) {
        for(Admin admin : admins) {
            if(admin.getId()==id) return admin;
        }
        return null;
    }

    public static synchronized void deleteAllUsers() {
        users.clear();
        saveUsers();
    }

    public static synchronized boolean deleteUser(User user) {
        boolean result = users.removeIf(u -> u.getId() == user.getId());
        saveUsers();
        return result;
    }

    public static synchronized void deleteAllSongs() {
        songs.clear();
        saveSongs();
    }

    public static synchronized void resetSongsDatabase() {
        songs.clear();
        saveSongs();
    }

    public static synchronized void reloadSongs() {
        songs = loadSongs();
    }

    public static synchronized boolean deleteSong(Song song) {
        boolean result = songs.removeIf(s -> s.equals(song));
        saveSongs();
        return result;
    }

    public static synchronized void deleteAllPlaylists() {
        playlists.clear();
        savePlaylists();
    }

    public static synchronized boolean deletePlaylist(Playlist playlist) {
        boolean result = playlists.removeIf(p -> p.equals(playlist));
        savePlaylists();
        return result;
    }

    public static synchronized boolean deleteAdmin(Admin admin) {
        boolean result = admins.removeIf(a -> a.getId() == admin.getId());
        saveAdmins();
        return result;
    }

    public static synchronized void deleteAllAdmins() {
        admins.clear();
        saveAdmins();
    }

    public static synchronized void addSongToUser(int userId, int songId) {
        User user = findUserById(userId);
        Song song = findSongById(songId);

        if (user != null && song != null) {
            user.addSong(song);
            saveUsers();
        }
    }

    public static synchronized void removeSongFromUser(int userId, int songId) {
        User user = findUserById(userId);
        Song song = findSongById(songId);
        
        if (user != null && song != null) {
            if (user.getSongs() != null) {
                user.getSongs().remove(song);
                saveUsers();
            }
        }
    }

    public static synchronized List<Song> getUserSongs(int userId) {
        User user = findUserById(userId);
        if (user != null && user.getSongs() != null) {
            return new ArrayList<>(user.getSongs());
        }
        return new ArrayList<>();
    }

    public static synchronized boolean userHasSong(int userId, int songId) {
        User user = findUserById(userId);
        Song song = findSongById(songId);
        
        if (user != null && song != null && user.getSongs() != null) {
            return user.getSongs().contains(song);
        }
        return false;
    }

    public static synchronized void clearUserSongs(int userId) {
        User user = findUserById(userId);
        if (user != null && user.getSongs() != null) {
            user.getSongs().clear();
            saveUsers();
        }
    }
}
