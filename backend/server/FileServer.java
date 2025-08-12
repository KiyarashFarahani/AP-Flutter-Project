package backend.server;

import java.io.File;
import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class FileServer {

    public  static final String MUSIC_DIR = "data/musics";
    private static int PORT = 4321;


    public static void main(String[] args) {
        ExecutorService executor = Executors.newCachedThreadPool();
        try(ServerSocket fileSocket = new ServerSocket(PORT)) {
            System.out.println("File Server started on port " + PORT);

            while(!fileSocket.isClosed()) {
                Socket clientSocket = fileSocket.accept();
                System.out.println("Client connected: " + clientSocket.getInetAddress());
                executor.submit(new FileRequestHandler(clientSocket));
            }
        } catch(IOException e) {
            e.printStackTrace();
        }
    }
}
