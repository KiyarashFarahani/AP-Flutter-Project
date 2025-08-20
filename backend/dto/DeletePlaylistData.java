package backend.dto;

import backend.model.Playlist;

public class DeletePlaylistData {
    private Playlist playlist;
     public DeletePlaylistData(Playlist playlist) {
         this.playlist = playlist;
     }
     public Playlist getPlaylist() {
         return playlist;
     }
     public void setPlaylist(Playlist playlist) {
         this.playlist = playlist;
     }
}
