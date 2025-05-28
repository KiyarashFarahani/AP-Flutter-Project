package backend.dto;

public class Request<T> {
    private String action;
    private String token;
    private T data;

    public Request() {}

    public Request(String action, String token, T data) {
        this.action = action;
        this.token = token;
        this.data = data;
    }

    public String getAction() {
        return action;
    }

    public void setAction(String action) {
        this.action = action;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public T getData() {
        return data;
    }

    public void setData(T data) {
        this.data = data;
    }
}