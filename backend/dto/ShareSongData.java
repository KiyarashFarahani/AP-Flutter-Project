package backend.dto;

import com.google.gson.annotations.SerializedName;

public class ShareSongData extends SongActionData {
    @SerializedName("recipient_username")
    private String recipientUsername;

    public ShareSongData() {
        super();
    }

    public ShareSongData(int songId, String recipientUsername) {
        super(songId);
        this.recipientUsername = recipientUsername;
    }

    public String getRecipientUsername() {
        return recipientUsername;
    }

    public void setRecipientUsername(String recipientUsername) {
        this.recipientUsername = recipientUsername;
    }
}
