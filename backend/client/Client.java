package backend.client;

import backend.exceptions.InvalidPasswordException;
import backend.exceptions.InvalidUsernameException;
import backend.model.User;
import com.google.gson.Gson;
import java.io.*;
import java.net.Socket;

public class Client {
    public static void main(String[] args) {
        String host = "localhost";
        int port = 1234;

        try (Socket socket = new Socket(host, port)) {
            // Streams
            BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            PrintWriter out = new PrintWriter(socket.getOutputStream(), true);

            // Create a User object
            User user = new User("bbbb@gmail.com", "Alice");

            // Convert to JSON
            Gson gson = new Gson();
            String json = gson.toJson(user);

            // Send to server
            out.println(json);

            // Read response
            String response = in.readLine();
            System.out.println("Server response: " + response);

        } catch (IOException e) {
            e.printStackTrace();
        } catch (InvalidPasswordException e) {
            throw new RuntimeException(e);
        } catch (InvalidUsernameException e) {
            throw new RuntimeException(e);
        }
    }
}
