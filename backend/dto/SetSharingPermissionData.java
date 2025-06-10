package backend.dto;

public class SetSharingPermissionData {
    private boolean sharePermission;

    public SetSharingPermissionData() {}

    public SetSharingPermissionData(boolean sharePermission) {
        this.sharePermission = sharePermission;
    }

    public boolean getSharePermission() {
        return sharePermission;
    }

    public void setSharePermission(boolean sharePermission) {
        this.sharePermission = sharePermission;
    }
}
