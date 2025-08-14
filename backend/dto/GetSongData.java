package backend.dto;

public class GetSongData {
    private String filename;
    public GetSongData() {}
    public GetSongData(String filename) {
        this.filename = filename;
    }
    public void setFilename(String filename) {
        this.filename = filename;
    }

    public String getFilename() {
        return filename;
    }
}
