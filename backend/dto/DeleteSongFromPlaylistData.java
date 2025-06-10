package backend.dto;

public class DeleteSongFromPlaylistData extends SongActionData {
    private String playListId;

    public DeleteSongFromPlaylistData() {
        super();
    }

    public DeleteSongFromPlaylistData(String songId, String playListId) {
        super(songId);
        this.playListId = playListId;
    }

    public String getPlayListId() {
        return playListId;
    }

    public void setPlayListId(String playListId) {
        this.playListId = playListId;
    }
}
