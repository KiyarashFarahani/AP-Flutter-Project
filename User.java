import java.time.LocalDateTime;
import java.util.*;
import java.time.LocalTime;

public class User {
    private String id;
    private String userName;
    private String password;
    private String email;
    private boolean sharePermission;
    private boolean validUsername;
    private boolean validPassword;
    private boolean doesExist;
    private String profileImageUrl;
    private Set<Song> likedSongs;
    private Set<Playlist> playlists;
    private Set<Song> allSongs;
    private Map<Song, LocalTime> downloadedSongs;
    public User(String userName, String password, String email) throws InvalidPasswordException, InvalidUsernameException {
        validUsername(userName);
        validPassword(password, userName);
        this.id = UUID.randomUUID().toString();
        this.userName= userName;
        this.password= password;
        this.email= email;
        sharePermission= true;
        doesExist= true;
        likedSongs= new HashSet<>();
        playlists= new HashSet<>();
        allSongs= new HashSet<>();
        downloadedSongs= new HashMap<>();
    }
    public  void validPassword(String password, String userName) throws InvalidPasswordException {
        if(password== null || password.trim().isEmpty())
            throw new InvalidPasswordException("Password is required. Please enter your password to continue.");
        if(password.length()<8)
            throw new InvalidPasswordException("Your password must be at least 8 characters long.");
        if(!password.matches(".*[a-z].*"))
            throw new InvalidPasswordException("Your password must contain at least one lowercase letter (a–z).");
        if(!password.matches(".*[A-Z].*"))
            throw new InvalidPasswordException("Your password must contain at least one uppercase letter (A–Z).");
        if(!password.matches(".*\\d.*"))
            throw new InvalidPasswordException("Your password must include at least one number (0–9).");
        if(password.contains(userName))
            throw new InvalidPasswordException("Your password must not contain your username.");
        else
            validPassword= true;
    }
    public void validUsername(String userName) throws InvalidUsernameException {
        if(userName== null || userName.trim().isEmpty())
            throw new InvalidUsernameException("Username is required. Please enter your email or phone number.");
        if(!userName.matches("^[\\w._%+-]+@[\\w.-]+\\.[a-zA-Z]{2,}$") &&
                !userName.matches("^\\+?[0-9]{10,15}$"))
            throw new InvalidUsernameException("Username must be a valid email address or phone number.");
        else
            validUsername= true;
    }
    public void addSong(Song song){
        allSongs.add(song);
    }
    public void downloadSong(Song song){
        downloadedSongs.put(song, LocalTime.now());
    }
    public void setProfilePicture()
    public void toggleLike(Song song){
        if(likedSongs.contains(song))
            likedSongs.remove(song);
        else
            likedSongs.add(song);
    }
    public boolean addPlaylist(String name){
       return playlists.add(new Playlist(name));
    }
    public void removePlaylist(String name){
        for(Playlist p: playlists){
            if(p.getName().equals(name)){
                playlists.remove(p);
                break;}
        }
    }
    public boolean hasLikedSong(Song song){
        if(likedSongs.contains(song))
            return  true;
        return false;
    }
    public void shareSong(Song song){
    //TODO: ???
    }
    public Playlist getPlaylist(String name){
        for(Playlist p: playlists){
            if(p.getName().equals(name)){
                return p;
            }
        }
        return null;
    }
    public void disableSharePermission(){
        sharePermission = false;
    }
    public void enableSharePermission(){
        sharePermission = true;
    }
    public void deleteAccount(String userName, String password){
        if(userName.equals(this.userName)&& password.equals(this.password))
            doesExist= false;
    }
    public Set<Playlist> getPlaylists() {
        return playlists;
    }

    public Set<Song> getLikedSongs() {
        return likedSongs;
    }

    public String getEmail() {
        return email;
    }

    public String getPassword() {
        return password;
    }

    public String getUserName() {
        return userName;
    }

    public String getId() {
        return id;
    }


}
