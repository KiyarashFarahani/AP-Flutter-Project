import java.util.UUID;
import java.util.Date;

public class Song {
    private String id;
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

    public String getId() {
        return id;
    }

    public void setId(String id) {
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
}