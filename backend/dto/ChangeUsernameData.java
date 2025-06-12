package backend.dto;

import com.google.gson.annotations.SerializedName;

public class ChangeUsernameData {
    @SerializedName("new_username")
    private String newUsername;

    public ChangeUsernameData() {}

    public ChangeUsernameData(String newUsername) {
        this.newUsername = newUsername;
    }

    public String getNewUsername() {
        return newUsername;
    }

    public void setNewUsername(String newUsername) {
        this.newUsername = newUsername;
    }
}
