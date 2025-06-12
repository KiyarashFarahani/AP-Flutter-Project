package backend.dto;

import com.google.gson.annotations.SerializedName;

public class SongActionData {
    @SerializedName("song_id")
    private String songId;

    public SongActionData() {}

    public SongActionData(String songId) {
        this.songId = songId;
    }

    public String getSongId() {
        return songId;
    }

    public void setSongId(String songId) {
        this.songId = songId;
    }
}