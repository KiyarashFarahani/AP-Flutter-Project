package backend.server;

import backend.controllers.SongController;
import backend.controllers.UserController;
import backend.dto.*;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.reflect.TypeToken;


import java.io.*;
import java.net.Socket;
import java.util.HashMap;
import java.util.Map;

public class ClientHandler implements Runnable {
    private final Socket socket;
    private final Gson gson = new Gson();
    private final UserController userController = new UserController();
    private final SongController songController = new SongController();

    private  FileRequestHandler requestHandler;

    public ClientHandler(Socket socket) {
        this.socket = socket;
    }

    @Override
    public void run() {
        try (
                BufferedReader in = new BufferedReader(new InputStreamReader(socket.getInputStream()));
                PrintWriter out = new PrintWriter(socket.getOutputStream(), true)
        ) {

            while (true) {
                String inputLine = in.readLine();

                System.out.println("Received request: " + inputLine);
                Request<?> request = gson.fromJson(inputLine, new TypeToken<Request<Object>>(){}.getType());
                String action = request.getAction();
                String token = request.getToken();
                Response<?> response;

                switch (action) {
                    case "sign_up" -> {
                        SignUpData data = gson.fromJson(gson.toJson(request.getData()), SignUpData.class);
                        response = userController. signUp(data.getUsername(),data.getPassword(),
                                data.getConfirm_password());
                    }
                    case "log_in" -> {
                        LogInData data = gson.fromJson(gson.toJson(request.getData()), LogInData.class);
                        response = userController.login(data.getUsername(), data.getPassword());
                    }
                    case "change_password" -> {
                        ChangePasswordData data = gson.fromJson(gson.toJson(request.getData()), ChangePasswordData.class);
                        response = userController.changePassword(token, data.getOldPassword(),
                                data.getNewPassword(), data.getConfirmNewPassword());
                    }
                    case "change_username" -> {
                        ChangeUsernameData data = gson.fromJson(gson.toJson(request.getData()), ChangeUsernameData.class);
                        response = userController.changeUsername(token, data.getNewUsername());
                    }
                    case "add_song" -> {
                        int songId = gson.fromJson(gson.toJson(request.getData()), int.class);
                        response = songController.addSong(token, songId);
                    }
                    case "log_out" -> {
                        response = userController.logout(token);
                    }
                    case "list_songs" -> {
                        File dir = new File(FileRequestHandler.MUSIC_DIR);
                        File[] files = dir.listFiles((d, name) -> name.endsWith(".mp3"));

                        JsonArray songArray = new JsonArray();
                        if(files != null) {
                            for (File f: files) {
                                JsonObject songObject = new JsonObject();
                                songObject.addProperty("title", f.getName());
                                songArray.add(songObject);
                            }
                        }
                        response = new Response<>(200, songArray, "Songs listed successfully" );

                    }
                    case "get_song" -> {
                        GetSongData data = gson.fromJson(gson.toJson(request.getData()), GetSongData.class);
                        String filename = data.getFilename();
                        File file = new File(FileRequestHandler.MUSIC_DIR, filename);
                        Map<String, Long> outData = new HashMap<>();
                        outData.put("filesize", file.length());
                        response = new Response<>(200, outData, "File info ready");
                       requestHandler = new FileRequestHandler(filename, socket.getOutputStream());

                    }
                    case "delete_account" -> {
                        DeleteAccountData data = gson.fromJson(gson.toJson(request.getData()), DeleteAccountData.class);
                        response = userController.deleteAccount(token, data.getPassword());
                    }
                    case "share_song" -> {
                        ShareSongData data = gson.fromJson(gson.toJson(request.getData()), ShareSongData.class);
                        response = songController.shareSong(token, data.getRecipientUsername(),
                                data.getSongId());
                    }
                    case "share_playlist" -> {
                        SharePlaylistData data = gson.fromJson(gson.toJson(request.getData()), SharePlaylistData.class);
                        response = songController.sharePlaylist(token, data.getRecipientUsername(),
                                data.getPlayListId());
                    }
                    case "set_sharing_permission" -> {
                        SetSharingPermissionData data = gson.fromJson(gson.toJson(request.getData()),
                                SetSharingPermissionData.class);
                        response = userController.setSharingPermission(token, data.getSharePermission());
                    }
                    case "toggle_like_song" -> {
                        int songId = gson.fromJson(gson.toJson(request.getData()), int.class);
                        response = songController.toggleLikeSong(token, songId);
                    }
                    case "set_mode" -> {
                        SetDarkLightModeData data = gson.fromJson(gson.toJson(request.getData()),
                                SetDarkLightModeData.class);
                        response = userController.setDarkLightMode(token, data.getNewTheme());
                    }
                    case "add_song_to_playlist" -> {
                        AddSongsToPlaylistData data = gson.fromJson(gson.toJson(request.getData()),
                                AddSongsToPlaylistData.class);
                        response = songController.addSongsToPlaylist(token, data.getPlaylistId(), data.getSongIds());
                    }
                    case "delete_song_from_playlist" -> {
                        DeleteSongFromPlaylistData data = gson.fromJson(gson.toJson(request.getData()),
                                DeleteSongFromPlaylistData.class);
                        response = songController.deleteSongFromPlaylist(token, data.getPlayListId(), data.getSongId());
                    }
                    case "create_playlist" -> {
                        CreateNewPlaylistData data = gson.fromJson(gson.toJson(request.getData()),
                                CreateNewPlaylistData.class);
                        response = songController.createPlaylist(token, data.getPlayListName());
                    }
                    default -> {
                        response = new Response<>(400, null, "Unknown action: " + action);
                    }
                }

                String responseJson = gson.toJson(response);
                System.out.println("Sending response: " + responseJson);
                out.println(responseJson);
                if (action.equals("get_song")) {
                    requestHandler.sendFile();
                }

            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}