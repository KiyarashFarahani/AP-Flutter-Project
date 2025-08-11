package backend;

public class Validator {
    public static String getUsernameValidationError(String username) {
        if (username == null || username.trim().isEmpty())
            return "Username is required. Please enter your email or phone number.";
        if(!username.matches("^[\\w._%+-]+@[\\w.-]+\\.[a-zA-Z]{2,}$") &&
                !username.matches("^\\+?[0-9]{10,15}$"))
            return "Username must be a valid email address or phone number.";
        return null;
    }

    public static String getPasswordValidationError(String password, String username) {
        if (password == null || password.trim().isEmpty())
            return "Password is required. Please enter your password to continue.";
        if (password.length() < 8)
            return "Your password must be at least 8 characters long.";
        if (!password.matches(".*[a-z].*"))
            return "Your password must contain at least one lowercase letter (a–z).";
        if (!password.matches(".*[A-Z].*"))
            return "Your password must contain at least one uppercase letter (A–Z).";
        if (!password.matches(".*\\d.*"))
            return "Your password must include at least one number (0–9).";
        if (username != null && !username.isEmpty() && password.contains(username))
            return "Your password must not contain your username.";
        return null;
    }
}
