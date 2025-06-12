package backend.dto;

import com.google.gson.annotations.SerializedName;

public class SongActionData {
    @SerializedName("song_id")
    private int songId;

    public SongActionData() {}

    public SongActionData(int songId) {
        this.songId = songId;
    }

    public int getSongId() {
        return songId;
    }

    public void setSongId(int songId) {
        this.songId = songId;
    }
}