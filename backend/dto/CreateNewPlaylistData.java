package backend.dto;

import com.google.gson.annotations.SerializedName;

public class CreateNewPlaylistData {
    @SerializedName("name")
    private String playListName;

    public CreateNewPlaylistData() {}

    public CreateNewPlaylistData(String playListName) {
        this.playListName = playListName;
    }

    public String getPlayListName() {
        return playListName;
    }

    public void setPlayListName(String playListName) {
        this.playListName = playListName;
    }
}