package backend.dto;

import com.google.gson.annotations.SerializedName;

public class SharePlaylistData {
    @SerializedName("recipient_username")
    private String recipientUsername;
    @SerializedName("playlist_id")
    private int playListId;

    public SharePlaylistData() {}

    public SharePlaylistData(String recipientUsername, int playListId) {
        this.recipientUsername = recipientUsername;
        this.playListId = playListId;
    }

    public String getRecipientUsername() {
        return recipientUsername;
    }

    public void setRecipientUsername(String recipientUsername) {
        this.recipientUsername = recipientUsername;
    }

    public int getPlayListId() {
        return playListId;
    }

    public void setPlayListId(int playListId) {
        this.playListId = playListId;
    }
}