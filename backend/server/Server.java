package backend.server;// Server.java
import java.net.ServerSocket;
import java.net.Socket;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import backend.utils.MetadataExtractor;
import backend.utils.JsonDatabase;
import java.util.List;
import backend.model.Song;

public class Server {
    public static void main(String[] args) {
        final int PORT = 1234;
        ExecutorService executor = Executors.newCachedThreadPool();

        initializeDatabase();

        updateMetadata();

        try (ServerSocket serverSocket = new ServerSocket(PORT)) {
            System.out.println("Server started on port " + PORT);

            while (!serverSocket.isClosed()) {
                Socket socket = serverSocket.accept();
                System.out.println("New client connected: " + socket.getInetAddress());

                socket.setSoTimeout(30000);
                socket.setKeepAlive(true);

                executor.submit(new ClientHandler(socket));

            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        finally {
            executor.shutdown();
        }
    }

    private static void updateMetadata() {
        System.out.println("Starting metadata extraction...");
        try {
            List<Song> extractedSongs = MetadataExtractor.extractMetadataFromDirectory(FileRequestHandler.MUSIC_DIR);

            if (!extractedSongs.isEmpty()) {
                JsonDatabase.resetSongsDatabase();

                for (Song song : extractedSongs)
                    JsonDatabase.addSong(song);

                JsonDatabase.reloadSongs();

                System.out.println("Metadata extraction and saving completed. Found " + extractedSongs.size() + " songs.");
            } else {
                System.out.println("No songs found to extract metadata from.");
            }
        } catch (Exception e) {
            System.err.println("Error during metadata extraction: " + e.getMessage());
            e.printStackTrace();
        }
    }

    private static void initializeDatabase() {
        System.out.println("Initializing database...");
        try {
            JsonDatabase.loadSongs();
            JsonDatabase.loadUsers();
            JsonDatabase.loadPlaylists();
            JsonDatabase.loadAdmins();
            System.out.println("Database initialization completed.");
        } catch (Exception e) {
            System.err.println("Database initialization had issues: " + e.getMessage());
        }
    }
}