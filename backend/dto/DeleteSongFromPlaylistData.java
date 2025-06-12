package backend.dto;

import com.google.gson.annotations.SerializedName;

public class DeleteSongFromPlaylistData extends SongActionData {
    @SerializedName("playlist_id")
    private int playListId;

    public DeleteSongFromPlaylistData() {
        super();
    }

    public DeleteSongFromPlaylistData(String songId, int playListId) {
        super(songId);
        this.playListId = playListId;
    }

    public int getPlayListId() {
        return playListId;
    }

    public void setPlayListId(int playListId) {
        this.playListId = playListId;
    }
}
