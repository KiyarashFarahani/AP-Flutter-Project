package backend.dto;

public class AddSongToUserData {
    private int songId;

    public AddSongToUserData() {}

    public AddSongToUserData(int songId) {
        this.songId = songId;
    }

    public int getSongId() {
        return songId;
    }

    public void setSongId(int songId) {
        this.songId = songId;
    }
}
