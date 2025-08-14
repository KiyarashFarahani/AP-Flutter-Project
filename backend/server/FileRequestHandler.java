package backend.server;

import java.io.*;
import java.net.Socket;

public class FileRequestHandler {

    private final String filename;
    private final OutputStream clientOut;

    public static final String MUSIC_DIR = "data/musics";

    public FileRequestHandler(String filename, OutputStream clientOut) {
        this.filename = filename;
        this.clientOut = clientOut;
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
                    clientOut.write(buffer, 0, bytesRead); // write directly
                }
                clientOut.flush();
                System.out.println("Sent file: " + filename);

            } catch (IOException e) {
                e.printStackTrace();
            }
        }).start(); // run in a separate thread
    }
}

