package backend.dto;

public class SongActionData {
    private String songId;

    public SongActionData() {}

    public SongActionData(String songId) {
        this.songId = songId;
    }

    public String getSongId() {
        return songId;
    }

    public void setSongId(String songId) {
        this.songId = songId;
    }
}