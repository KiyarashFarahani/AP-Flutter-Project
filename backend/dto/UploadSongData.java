package backend.dto;

public class UploadSongData {
    private String filename;
    private long filesize;
    private String token;

    public UploadSongData() {}

    public UploadSongData(String filename, long filesize, String token) {
        this.filename = filename;
        this.filesize = filesize;
        this.token = token;
    }

    public String getFilename() {
        return filename;
    }

    public void setFilename(String filename) {
        this.filename = filename;
    }

    public long getFilesize() {
        return filesize;
    }

    public void setFilesize(long filesize) {
        this.filesize = filesize;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }
}
