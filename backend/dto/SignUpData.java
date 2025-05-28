package backend.dto;

public class SignUpData {
    private String username;
    private String password;
    private String confirm_password;

    public void setUsername(String username) {
        this.username = username;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public void setConfirm_password(String confirm_password) {
        this.confirm_password = confirm_password;
    }

    public String getUsername() {
        return username;
    }

    public String getPassword() {
        return password;
    }

    public String getConfirm_password() {
        return confirm_password;
    }


}
