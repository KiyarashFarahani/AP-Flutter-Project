package backend.dto;

import com.google.gson.annotations.SerializedName;

public class SignUpData {
    @SerializedName("username")
    private String username;
    @SerializedName("password")
    private String password;
    @SerializedName("confirm_password")
    private String confirmPassword;;

    public SignUpData() {}

    public SignUpData(String username, String password, String confirmPassword) {
        this.username = username;
        this.password = password;
        this.confirmPassword = confirmPassword;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public void setConfirm_password(String confirm_password) {
        this.confirmPassword = confirm_password;
    }

    public String getUsername() {
        return username;
    }

    public String getPassword() {
        return password;
    }

    public String getConfirm_password() {
        return confirmPassword;
    }


}