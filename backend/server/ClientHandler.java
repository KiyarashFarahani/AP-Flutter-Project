package backend.server;

import backend.controllers.SongController;
import backend.controllers.UserController;
import backend.dto.*;

import backend.model.Song;
import backend.utils.JsonDatabase;
import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.reflect.TypeToken;

import org.jaudiotagger.audio.AudioFile;
import org.jaudiotagger.audio.AudioFileIO;
import org.jaudiotagger.tag.FieldKey;
import org.jaudiotagger.tag.Tag;
import org.jaudiotagger.tag.images.Artwork;


import java.io.*;
import java.net.Socket;
import java.net.SocketTimeoutException;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;
import java.util.Base64;

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

            while (!socket.isClosed()) {
                String inputLine = in.readLine();

                if (inputLine == null) {
                    System.out.println("Client disconnected: " + socket.getInetAddress());
                    break;
                }

                System.out.println("Received request: " + inputLine);
                Request<?> request = gson.fromJson(inputLine, new TypeToken<Request<Object>>(){}.getType());
                String action = request.getAction();
                String token = request.getToken();
                Response<?> response;

                if (socket.isClosed()) {
                    System.out.println("Socket closed during request processing");
                    break;
                }

                switch (action) {
                    case "sign_up" -> {
                        SignUpData data = gson.fromJson(gson.toJson(request.getData()), SignUpData.class);
                        response = userController.signUp(data.getUsername(),data.getPassword(),
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
                    case "validate_token" -> {
                        response = userController.validateToken(token);
                    }
                    case "list_songs" -> {
                        File dir = new File(FileRequestHandler.MUSIC_DIR);
                        File[] files = dir.listFiles((d, name) -> name.endsWith(".mp3"));

                        JsonArray songArray = new JsonArray();

                        if (files != null) {
                            for (File f : files) {
                                String base64Cover = "No cover found";
                                String artist = "Unknown artist";
                                String title = "null";

                                try {
                                    AudioFile audioFile = AudioFileIO.read(f);
                                    Tag tag = audioFile.getTag();

                                    if (tag != null) {
                                        Artwork artwork = tag.getFirstArtwork();
                                        if (artwork != null) {
                                            byte[] imageData = artwork.getBinaryData();
                                            base64Cover = Base64.getEncoder().encodeToString(imageData)
                                                    .replaceAll("\\s+", "");
                                        }
                                        String tagArtist = tag.getFirst(FieldKey.ARTIST);
                                        if (tagArtist != null && !tagArtist.isBlank()) {
                                            artist = tagArtist;
                                        }
                                        String tagTitle = tag.getFirst(FieldKey.TITLE);
                                        if (tagTitle != null && !tagTitle.isBlank()) {
                                            title = tagTitle;
                                        }
                                    }
                                } catch (Exception e) {
                                    System.err.println("Failed to read metadata for file: " + f.getName());
                                    e.printStackTrace();
                                }


                                JsonObject songObject = new JsonObject();
                                songObject.addProperty("filename", f.getName());
                                songObject.addProperty("title", title);
                                songObject.addProperty("artist", artist);
                                //songObject.addProperty("cover", base64Cover);

                                songArray.add(songObject);
                            }
                        }

                        response = new Response<>(200, songArray, "Songs listed successfully");
                    }
                    case "get_song" -> {
                        GetSongData data = gson.fromJson(gson.toJson(request.getData()), GetSongData.class);
                        String filename = data.getFilename();
                        File file = new File(FileRequestHandler.MUSIC_DIR, filename);
                        Map<String, Long> outData = new HashMap<>();
                        outData.put("filesize", file.length());
                        response = new Response<>(200, outData, "File info ready");
                       requestHandler = new FileRequestHandler(filename, socket.getOutputStream(), socket);

                    }
                    case "get_song_id_by_filename" -> {
                        String filename = gson.fromJson(gson.toJson(request.getData()), String.class);
                        Song song = JsonDatabase.findSongByFilename(filename);
                        if (song != null) {
                            Map<String, Object> outData = new HashMap<>();
                            outData.put("song_id", song.getId());
                            outData.put("filename", song.getFilePath());
                            response = new Response<>(200, outData, "Song ID found");
                        } else {
                            response = new Response<>(404, null, "Song not found");
                        }
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
                    case "add_song_to_user" -> {
                        AddSongToUserData data = gson.fromJson(gson.toJson(request.getData()), AddSongToUserData.class);
                        response = userController.addSongToUser(token, data.getSongId());
                    }
                    case "remove_song_from_user" -> {
                        RemoveSongFromUserData data = gson.fromJson(gson.toJson(request.getData()), RemoveSongFromUserData.class);
                        response = userController.removeSongFromUser(token, data.getSongId());
                    }
                    case "get_user_songs" -> {
                        response = userController.getUserSongs(token);
                    }
                    case "clear_user_songs" -> {
                        response = userController.clearUserSongs(token);
                    }
                    case "upload_song" -> {
                        UploadSongData data = gson.fromJson(gson.toJson(request.getData()), UploadSongData.class);
                        
                        response = new Response<>(200, null, "Ready to receive file");
                        out.println(gson.toJson(response));
                        out.flush();
                        
                        try {
                            FileUploadHandler uploadHandler = new FileUploadHandler(
                                data.getFilename(), 
                                socket.getInputStream(), 
                                data.getFilesize()
                            );
                            boolean uploadSuccess = uploadHandler.receiveFile();
                            
                            if (uploadSuccess) {
                                System.out.println("Song uploaded successfully: " + data.getFilename());
                            } else {
                                System.out.println("Song upload failed: " + data.getFilename());
                            }
                        } catch (Exception e) {
                            System.err.println("Error during file upload: " + e.getMessage());
                            e.printStackTrace();
                        }
                        
                        continue;
                    }
                    default -> {
                        response = new Response<>(400, null, "Unknown action: " + action);
                    }
                }

                String responseJson = gson.toJson(response);
                System.out.println("Sending response: " + responseJson);
                if (!socket.isClosed()) {
                    out.println(responseJson);
                    out.flush();
                    if (action.equals("get_song")) {
                        requestHandler.sendFile();
                    }
                } else {
                    System.out.println("Socket closed, cannot send response");
                    break;
                }

            }
        } catch (IOException e) {
            if (socket.isClosed()) {
                System.out.println("Client disconnected: " + socket.getInetAddress());
            } else if (e instanceof SocketTimeoutException) {
                System.out.println("Client timeout: " + socket.getInetAddress());
            } else {
                System.err.println("ClientHandler Error: " + e.getMessage());
                e.printStackTrace();
            }
        } finally {
            try {
                if (!socket.isClosed())
                    socket.close();
            } catch (IOException e) {
                System.err.println("Couldn't closing socket: " + e.getMessage());
            }
        }
    }
}