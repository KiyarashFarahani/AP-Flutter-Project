package backend.dto;

import backend.model.Theme;
import com.google.gson.annotations.SerializedName;

public class SetDarkLightModeData {
    @SerializedName("theme")
    private Theme newTheme;

    public SetDarkLightModeData() {}

    public SetDarkLightModeData(Theme newTheme) {
        this.newTheme = newTheme;
    }

    public Theme getNewTheme() {
        return newTheme;
    }

    public void setNewTheme(Theme newTheme) {
        this.newTheme = newTheme;
    }
}
