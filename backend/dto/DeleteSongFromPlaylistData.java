package backend.dto;

public class DeleteSongFromPlaylistData extends SongActionData {
    private String playListId;

    public String getPlayListId() {
        return playListId;
    }

    public void setPlayListId(String playListId) {
        this.playListId = playListId;
    }
}
