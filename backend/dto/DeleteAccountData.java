package backend.dto;

public class DeleteAccountData {
    private String password;

    public DeleteAccountData() {}

    public DeleteAccountData(String password) {
        this.password = password;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }
}
