package backend.dto;

import backend.model.Theme;

public class SetDarkLightModeData {
    private Theme newTheme;

    public Theme getNewTheme() {
        return newTheme;
    }

    public void setNewTheme(Theme newTheme) {
        this.newTheme = newTheme;
    }
}
