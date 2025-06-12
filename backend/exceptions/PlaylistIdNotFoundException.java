package backend.exceptions;

public class PlaylistIdNotFoundException extends RuntimeException {
    public PlaylistIdNotFoundException(String message) {
        super(message);
    }
}
