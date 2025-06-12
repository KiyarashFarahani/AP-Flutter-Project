package backend.dto;

import com.google.gson.annotations.SerializedName;

public class DeleteSongFromPlaylistData extends SongActionData {
    @SerializedName("playlist_id")
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
