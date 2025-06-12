package backend.exceptions;

public class SongIdNotFoundException extends RuntimeException {
    public SongIdNotFoundException(String message) {
        super(message);
    }
}
