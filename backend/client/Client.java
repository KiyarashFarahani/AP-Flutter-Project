package backend.client;

import java.io.*;
import java.net.Socket;

public class Client {
    public static void main(String[] args) {
        String serverHost = "localhost";
        int serverPort = 1234;

        try (Socket socket = new Socket(serverHost, serverPort);
             BufferedReader fileReader = new BufferedReader(new FileReader("client/data.json"));
             PrintWriter out = new PrintWriter(socket.getOutputStream(), true);
             BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()))
        ) {

            StringBuilder jsonBuilder = new StringBuilder();
            String line;
            while ((line = fileReader.readLine()) != null) {
                jsonBuilder.append(line);
            }

            String jsonToSend = jsonBuilder.toString();
            System.out.println("Sending JSON to server:\n" + jsonToSend);

            out.println(jsonToSend);

            String response = in.readLine();
            System.out.println("Server response: " + response);


        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
