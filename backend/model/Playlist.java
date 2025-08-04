package backend.model;
import java.util.*;

public class Playlist {
    private int id;
    private String name;
    private Set<Song> songs;
    private User owner;
    private Date createdAt;
    private Date updatedAt;

    public Playlist() {}

    public Playlist(String name, User owner) {
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

    public void setName(String name) {
        this.name = name;
    }

    public Set<Song> getSongs() {
        return songs;
    }

    public void setSongs(Set<Song> songs) {
        this.songs = songs;
    }

    public Set<Integer> getSongIds() {
        Set<Song> songs = getSongs();
        Set<Integer> songIds = HashSet.newHashSet(songs.size());
        for(Song song : songs) {
            songIds.add(song.getId());
        }
        return songIds;
    }

    public User getOwner() {
        return owner;
    }

    public int getOwnerId() {
        return owner.getId();
    }

    public void setOwnerId(int id) {
        owner.setId(id);
    }

    public int getId(){  return id;}

    public void setId(int id) {
        this.id = id;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Playlist playlist = (Playlist) o;
        return Objects.equals(name,playlist.name) && Objects.equals(owner,playlist.owner);
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }
}