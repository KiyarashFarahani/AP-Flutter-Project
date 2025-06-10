package backend.dto;

public class ShareSongData extends SongActionData {
    private String recipientUsername;

    public ShareSongData() {
        super();
    }

    public ShareSongData(String songId, String recipientUsername) {
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
