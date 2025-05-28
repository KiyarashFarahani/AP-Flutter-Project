package backend.dto;

public class ShareSongData extends SongActionData {
    private String recipientUsername;

    public String getRecipientUsername() {
        return recipientUsername;
    }

    public void setRecipientUsername(String recipientUsername) {
        this.recipientUsername = recipientUsername;
    }
}
