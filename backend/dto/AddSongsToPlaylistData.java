package backend.dto;

import com.google.gson.annotations.SerializedName;

import java.util.HashSet;
import java.util.Set;

public class AddSongsToPlaylistData {
    @SerializedName("playlist_id")
    private int playlistId;
    @SerializedName("song_id")
    private int songId;

    public AddSongsToPlaylistData() {}

    public AddSongsToPlaylistData(int playlistId, int songId) {
        this.playlistId = playlistId;
        this.songId = songId;
    }

    public int getPlaylistId() {
        return playlistId;
    }

    public void setPlaylistId(int playlistId) {
        this.playlistId = playlistId;
    }

    public int getSongId() {
        return songId;
    }

    public void setSongId(int songId) {
        this.songId = songId;
    }
}
