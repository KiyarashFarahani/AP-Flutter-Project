package backend.dto;

public class SharePlaylistData {
    private String recipientUsername;
    private String playListId;

    public SharePlaylistData() {}

    public SharePlaylistData(String recipientUsername, String playListId) {
        this.recipientUsername = recipientUsername;
        this.playListId = playListId;
    }

    public String getRecipientUsername() {
        return recipientUsername;
    }

    public void setRecipientUsername(String recipientUsername) {
        this.recipientUsername = recipientUsername;
    }

    public String getPlayListId() {
        return playListId;
    }

    public void setPlayListId(String playListId) {
        this.playListId = playListId;
    }
}