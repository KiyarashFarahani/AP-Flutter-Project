package backend.database;

import backend.model.*;
import com.google.gson.Gson;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Paths;

public class DatabaseManager {
    private DatabaseData data= new DatabaseData();
    public void addUser(User user){
        data.getUsers().put(user.getId(), user);

    }
    public User getUser(String userId){
        return data.getUsers().get(userId);
    }
    public void addSong(Song song){
        data.getSongs().put(song.getId(), song);

    }
    public Song getSong(String songId){
        return data.getSongs().get(songId);
    }
    public void addPlaylist(Playlist playlist){
        data.getPlaylists().put(playlist.getId(), playlist);

    }
    public Playlist getPlaylist(String playlistId){
        return data.getPlaylists().get(playlistId);
    }

    private void saveToFile(){
        try{
            Gson gson= new Gson();
            String json= gson.toJson(data);
            Files.write(Paths.get("database.json"), json.getBytes());
        } catch (IOException e){
            e.printStackTrace();
        }
    }

    private void loadFromFile(){
        try{
            String json= new String(Files.readAllBytes(Paths.get("database.json")));
            Gson gson= new Gson();
            this.data= gson.fromJson(json, DatabaseData.class);
        } catch (IOException e){
            this.data= new DatabaseData();
        }
    }
}
