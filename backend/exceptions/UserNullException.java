package backend.exceptions;

public class UserNullException extends RuntimeException {
    public UserNullException(String message) {
        super(message);
    }
}
