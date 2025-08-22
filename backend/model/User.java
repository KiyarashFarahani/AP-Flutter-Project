package backend.model;

import backend.Validator;
import backend.exceptions.InvalidPasswordException;
import backend.exceptions.InvalidUsernameException;

import java.util.*;
import java.time.LocalTime;

public class User {
    private int id;
    private String username;
    private String password;
    private Theme theme;
    private boolean sharePermission;
    private String profileImageUrl;
    private Set<Song> likedSongs;
    private Set<Playlist> playlists;
    private Set<Song> allSongs;
    private Map<Song, LocalTime> downloadedSongs;

    public User() {
        this.theme = Theme.DARK;
        this.sharePermission = true;
        this.likedSongs = new HashSet<>();
        this.playlists = new HashSet<>();
        this.allSongs = new HashSet<>();
        this.downloadedSongs = new HashMap<>();
    }

    public User(String userName, String password) throws InvalidPasswordException, InvalidUsernameException {
        validateUsername(userName);
        validatePassword(password, userName);
        this.username = userName;
        this.password = password;
        this.theme = Theme.LIGHT;
        sharePermission = true;
        likedSongs = new HashSet<>();
        playlists = new HashSet<>();
        allSongs = new HashSet<>();
        downloadedSongs= new HashMap<>();
    }

    public void validatePassword(String password, String userName) throws InvalidPasswordException {
        String error = Validator.getPasswordValidationError(password,userName);
        if(error!=null) {
            throw new InvalidPasswordException(error);
        }
    }

    public void validateUsername(String userName) throws InvalidUsernameException {
        String error = Validator.getUsernameValidationError(userName);
        if(error!=null) {
            throw new InvalidUsernameException(error);
        }
    }

    @Override
    public boolean equals(Object o) {
        if (o == null || getClass() != o.getClass()) return false;
        User user = (User) o;
        return Objects.equals(username, user.username);
    }

    @Override
    public int hashCode() {
        return Objects.hash(username);
    }

    public void addSong(Song song) {
        allSongs.add(song);
    }

    public void downloadSong(Song song) {
        downloadedSongs.put(song, LocalTime.now());
    }

    public void setProfilePicture() {}
    
    public void setProfileImageUrl(String profileImageUrl) {
        this.profileImageUrl = profileImageUrl;
    }
    
    public String getProfileImageUrl() {
        return profileImageUrl;
    }

    public void toggleLike(Song song) {
        if(likedSongs.contains(song)) {
            likedSongs.remove(song);
        } else {
            likedSongs.add(song);
        }
    }

    public void setTheme(Theme theme) {
        this.theme= theme;
    }

    public boolean addPlaylist(String name) {
       return playlists.add(new Playlist(name, this));
    }

    public void removePlaylist(String name) {
        for(Playlist p: playlists) {
            if(p.getName().equals(name)) {
                playlists.remove(p);
                break;
            }
        }
    }

    public boolean hasLikedSong(Song song) {
        if(likedSongs.contains(song)) {
            return true;
        }
        return false;
    }

    public void shareSong(Song song) {
    //TODO: ???
    }

    public Playlist getPlaylist(String name) {
        for(Playlist p: playlists) {
            if(p.getName().equals(name)) {
                return p;
            }
        }
        return null;
    }

    public void disableSharePermission() {
        sharePermission = false;
    }

    public void enableSharePermission() {
        sharePermission = true;
    }

    public Set<Playlist> getPlaylists() {
        return playlists;
    }

    public void setPlaylists(Set<Playlist> playlists) {
        this.playlists = playlists;
    }

    public Set<Song> getSongs() {
        return allSongs;
    }

    public void setAllSongs(Set<Song> allSongs) {
        this.allSongs = allSongs;
    }

    public Map<Song, LocalTime> getDownloadedSongs() {
        return downloadedSongs;
    }

    public void setDownloadedSongs(Map<Song, LocalTime> downloadedSongs) {
        this.downloadedSongs = downloadedSongs;
    }

    public Theme getTheme() {return theme;}

    public Set<Song> getLikedSongs() {
        return likedSongs;
    }

    public void setLikedSongs(Set<Song> likedSongs) {
        this.likedSongs = likedSongs;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getUsername() {
        return username;
    }

    public void setUserName(String username) {
        this.username = username;
    }

    public boolean isSharePermission() {
        return sharePermission;
    }

    public void setSharePermission(boolean sharePermission) {
        this.sharePermission = sharePermission;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }
}
