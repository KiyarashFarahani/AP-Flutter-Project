package backend.dto;

public class RemoveSongFromUserData {
    private int songId;

    public RemoveSongFromUserData() {}

    public RemoveSongFromUserData(int songId) {
        this.songId = songId;
    }

    public int getSongId() {
        return songId;
    }

    public void setSongId(int songId) {
        this.songId = songId;
    }
}
