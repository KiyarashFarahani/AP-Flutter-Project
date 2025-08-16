package backend.server;

import java.io.*;
import java.net.Socket;

public class FileRequestHandler {

    private final String filename;
    private final OutputStream clientOut;
    private final Socket socket;

    public static final String MUSIC_DIR = "data/musics";

    public FileRequestHandler(String filename, OutputStream clientOut, Socket socket) {
        this.filename = filename;
        this.clientOut = clientOut;
        this.socket = socket;
    }

    public void sendFile() {
        new Thread(() -> {
            File file = new File(MUSIC_DIR, filename);
            if (!file.exists() || !file.isFile()) {
                System.out.println("File not found: " + filename);
                return;
            }

            try (FileInputStream fis = new FileInputStream(file)) {
                byte[] buffer = new byte[4096];
                int bytesRead;
                while ((bytesRead = fis.read(buffer)) != -1) {
                    if (socket.isClosed()) {
                        System.out.println("Socket closed while sending file: " + filename);
                        return;
                    }
                    clientOut.write(buffer, 0, bytesRead);
                }
                clientOut.flush();
                System.out.println("Sent file: " + filename);

            } catch (IOException e) {
                if (socket.isClosed()) {
                    System.out.println("Client disconnected while sending file: " + filename);
                } else {
                    System.err.println("Error sending file " + filename + ": " + e.getMessage());
                    e.printStackTrace();
                }
            }
        }).start();
    }
}

