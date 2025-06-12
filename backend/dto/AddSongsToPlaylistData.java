package backend.dto;

import com.google.gson.annotations.SerializedName;

import java.util.HashSet;
import java.util.Set;

public class AddSongsToPlaylistData {
    @SerializedName("playlist_id")
    private String playlistId;
    @SerializedName("song_ids")
    private Set<String> songIds;

    public AddSongsToPlaylistData() {}

    public AddSongsToPlaylistData(String playlistId, Set<String> songIds) {
        this.playlistId = playlistId;
        this.songIds = songIds;
    }

    public String getPlaylistId() {
        return playlistId;
    }

    public void setPlaylistId(String playlistId) {
        this.playlistId = playlistId;
    }

    public Set<String> getSongIds() {
        return songIds;
    }

    public void setSongIds(Set<String> songIds) {
        this.songIds = songIds;
    }
}
