package backend.test;

import backend.exceptions.InvalidPasswordException;
import backend.exceptions.InvalidUsernameException;
import backend.model.Playlist;
import backend.model.Song;
import backend.model.User;
import backend.utils.JsonDatabase;
import org.junit.jupiter.api.*;
import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.assertTrue;

public class JsonDatabaseTest {
    static List<Playlist> playlists = new ArrayList<>();
    static List<Song> songs = new ArrayList<>();
    static List<User> users = new ArrayList<>();

    @BeforeAll
    static void loadData() throws InvalidPasswordException, InvalidUsernameException {
        for(int i=1, duration=60; i<=30 && duration<=350; i++, duration+=10) {
            songs.add(new Song("Song"+i, "artist", "album", "genre", duration, 2020,
                    "filePath", "url", "lyrics"));
        }
        for(int i=1; i<=60; i++) {
            User user = new User("username"+i+"@gmail.com","Passw0rd"+i);
            users.add(user);
            playlists.add(new Playlist("playlist"+i,user));
        }
        for(User user : users) {
            JsonDatabase.addUser(user);
        }
        for(Song song : songs) {
            JsonDatabase.addSong(song);
        }
        for(Playlist playlist : playlists) {
            JsonDatabase.addPlaylist(playlist);
        }
    }

    @Test
    void testContainsSong() {
        List<Song> songs = JsonDatabase.loadSongs();
        for(int i=1, duration=60; i<=30 && duration<=350; i++, duration+=10) {
            Song song = new Song("Song"+i, "artist", "album", "genre", duration, 2020,
                    "filePath", "url", "lyrics");
            assertTrue(songs.contains(song));
        }
    }

    @Test
    void testContainsUser() throws InvalidPasswordException, InvalidUsernameException {
        List<User> users = JsonDatabase.loadUsers();
        for(int i=1; i<=60; i++) {
            User user = new User("username"+i+"@gmail.com","Passw0rd"+i);
            assertTrue(users.contains(user));
        }
    }

    @Test
    void testContainsPlaylist() {
        List<Playlist> playlists = JsonDatabase.loadPlaylists();
        for(int i=1; i<=60; i++) {
            Playlist playlist = new Playlist("playlist"+i,users.get(i-1));
            assertTrue(playlists.contains(playlist));
        }
    }

    @AfterAll
    static void cleanUp() {
        for(Playlist playlist : playlists) {
            JsonDatabase.deletePlaylist(playlist);
        }
        for(Song song : songs) {
            JsonDatabase.deleteSong(song);
        }
        for(User user : users) {
            JsonDatabase.deleteUser(user);
        }
        System.out.println("Test is finished.");
    }
}