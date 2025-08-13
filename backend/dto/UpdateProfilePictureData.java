package backend.dto;

import com.google.gson.annotations.SerializedName;

public class UpdateProfilePictureData {
    @SerializedName("profile_image_url")
    private String profileImageUrl;

    public UpdateProfilePictureData() {}

    public UpdateProfilePictureData(String profileImageUrl) {
        this.profileImageUrl = profileImageUrl;
    }

    public String getProfileImageUrl() {
        return profileImageUrl;
    }

    public void setProfileImageUrl(String profileImageUrl) {
        this.profileImageUrl = profileImageUrl;
    }
}
