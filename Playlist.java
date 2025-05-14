import java.util.*;

public class Playlist {
    private String id;
    private String name;
    private Set<Song> songs;
    private User owner;
    private Date createdAt;
    private Date updatedAt;

    public Playlist(String name, User owner) {
        this.id = UUID.randomUUID().toString();
        this.name = name;
        this.songs = new HashSet<>();
        this.createdAt = new Date();
        this.updatedAt = new Date();
        this.owner = owner;
    }

    public boolean addSong(Song song) {
        if (song != null) {
            boolean isAdded = songs.add(song);
            if (isAdded)
                updatedAt = new Date();
            return isAdded;
        }
        return false;
    }

    public boolean removeSong(Song song) {
        if (song != null) {
            boolean isRemoved = songs.remove(song);
            if (isRemoved)
                updatedAt = new Date();
            return isRemoved;
        }
        return false;
    }

    public void updateName(String name) {
        this.name = name;
        this.updatedAt = new Date();
    }

    public String getName() {
        return name;
    }

    public Set<Song> getSongs() {
        return songs;
    }

}