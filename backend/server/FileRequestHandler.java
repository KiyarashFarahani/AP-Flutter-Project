package backend.server;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;

import java.io.*;

import java.net.Socket;

public class FileRequestHandler implements Runnable {
    private Socket socket;
    private Gson gson = new Gson();
    public FileRequestHandler(Socket socket) {
        this.socket = socket;
    }
    @Override
    public void run() {
        try (
                BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
                OutputStream out = socket.getOutputStream();
                BufferedWriter writer = new BufferedWriter(new OutputStreamWriter(out))
        ) {
            String requestLine = in.readLine();
            System.out.println("Received request: " + requestLine);
            JsonObject request = gson.fromJson(requestLine, JsonObject.class);
            String action = request.get("action").getAsString();

            if("get_song".equals(action)) {
                String filename = request.get("filename").getAsString();
                File file = new File(FileServer.MUSIC_DIR, filename);

                JsonObject header = new JsonObject();
                header.addProperty("status", 200);
                header.addProperty("filesize",file.length());
                writer.write(gson.toJson(header));
                writer.newLine();
                writer.flush();

                try(FileInputStream fis = new FileInputStream(file)) {
                    byte[] buffer = new byte[4100];
                    int bytesRead;
                    while((bytesRead = fis.read(buffer)) != -1) {
                        out.write(buffer, 0, bytesRead);
                    }
                    out.flush();

                }
                System.out.println("Sent file: " + filename);
            }

            if("list_songs".equals(action)) {
                File dir = new File(FileServer.MUSIC_DIR);
                File[] files = dir.listFiles((d, name) -> name.endsWith(".mp3"));

                JsonArray songArray = new JsonArray();
                if(files != null) {
                    for (File f: files) {
                        JsonObject songObject = new JsonObject();
                        songObject.addProperty("title", f.getName());
                        songArray.add(songObject);
                    }
                }
                JsonObject response = new JsonObject();
                response.addProperty("status", 200);
                response.add("songs", songArray);
                System.out.println("Sending response: " + response);
                writer.write(gson.toJson(response));
                writer.newLine();
                writer.flush();
            }


        } catch(IOException e) {
            e.printStackTrace();
        }
    }
}
