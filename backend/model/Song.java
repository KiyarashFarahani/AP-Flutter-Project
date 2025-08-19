package backend.model;

import backend.exceptions.UserNullException;

import java.util.*;

public class Song {
    private int id;
    private String title;
    private String artist;
    private String album;
    private String genre;

    private int duration;
    private int year;

    private String filePath;
    private String coverArtUrl;
    private String lyrics;

    private long playCount;
    private int likes;

    private Date createdAt;
    private Date updatedAt;

    private boolean isShareable;

    private Set<User> likedByUsers;

    public Song() {
    }

    public Song(String id, String title, String artist, String album, String genre, int duration, int year, String filePath, String coverArtUrl, String lyrics, long playCount, int likes, Date createdAt, Date updatedAt, boolean isShareable, Set<User> likedByUsers) {
        this.title = title;
        this.artist = artist;
        this.album = album;
        this.genre = genre;
        this.duration = duration;
        this.year = year;
        this.filePath = filePath;
        this.coverArtUrl = coverArtUrl;
        this.lyrics = lyrics;
        this.playCount = playCount;
        this.likes = likes;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
        this.isShareable = isShareable;
        this.likedByUsers = likedByUsers;
    }

    public Song(String title, String artist, String album, String genre, int duration, int year, String filePath, String coverArtUrl, String lyrics) {
        this.title = title;
        this.artist = artist;
        this.album = album;
        this.genre = genre;
        this.duration = duration;
        this.year = year;
        this.filePath = filePath;
        this.coverArtUrl = coverArtUrl;
        this.lyrics = lyrics;
    }

    @Override
    public boolean equals(Object o) {
        if (o == null || getClass() != o.getClass()) return false;
        Song song = (Song) o;
        return id == song.id;
    }

    @Override
    public int hashCode() {
        return Objects.hash(id);
    }

    public String getTitle() {
        return title;
    }

    public String getArtist() {
        return artist;
    }

    public String getAlbum() {
        return album;
    }

    public String getGenre() {
        return genre;
    }

    public int getDuration() {
        return duration;
    }

    public int getYear() {
        return year;
    }

    public String getFilePath() {
        return filePath;
    }

    public String getCoverArtUrl() {
        return coverArtUrl;
    }

    public String getLyrics() {
        return lyrics;
    }

    public long getPlayCount() {
        return playCount;
    }

    public int getLikes() {
        return likes;
    }

    public Date getCreatedAt() {
        return createdAt;
    }

    public Date getUpdatedAt() {
        return updatedAt;
    }

    public boolean getIsShareable() {
        return isShareable;
    }

    public int getId() {
        return id;
    }

    public Set<User> getLikedByUsers() {
        return likedByUsers;
    }

    public void setId(int id) {
        this.id = id;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public void setArtist(String artist) {
        this.artist = artist;
    }

    public void setAlbum(String album) {
        this.album = album;
    }

    public void setGenre(String genre) {
        this.genre = genre;
    }

    public void setDuration(int duration) {
        this.duration = duration;
    }

    public void setYear(int year) {
        this.year = year;
    }

    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }

    public void setCoverArtUrl(String coverArtUrl) {
        this.coverArtUrl = coverArtUrl;
    }

    public void setLyrics(String lyrics) {
        this.lyrics = lyrics;
    }

    public void setPlayCount(long playCount) {
        this.playCount = playCount;
    }

    public void setLikes(int likes) {
        this.likes = likes;
    }

    public void setCreatedAt(Date createdAt) {
        this.createdAt = createdAt;
    }

    public void setUpdatedAt(Date updatedAt) {
        this.updatedAt = updatedAt;
    }

    public void setIsShareable(boolean isShareable) {
        this.isShareable = isShareable;
    }

    public void setLikedByUsers(Set<User> likedByUsers) {
        this.likedByUsers = likedByUsers;
    }

    public void addLike(User user) {
        validateUser(user);
        user.getLikedSongs().add(this);
        likedByUsers.add(user);
    }

    public void removeLike(User user) {
        validateUser(user);
        user.getLikedSongs().remove(this);
        likedByUsers.remove(user);
    }

    private void validateUser(User user) {
        if (user == null) {
            throw new UserNullException("User is null!");
        }
    }
}