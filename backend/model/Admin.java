package backend.model;

import backend.exceptions.InvalidPasswordException;
import backend.exceptions.InvalidUsernameException;

public class Admin extends User {

	public Admin(String userName, String password, String email)
			throws InvalidPasswordException, InvalidUsernameException {
		super(userName, password, email);
	}

	public void banUser(User user) {
		if (user != null && !(user instanceof Admin))
			user.disableSharePermission();
	}

	public void unbanUser(User user) {
		if (user != null)
			user.enableSharePermission();
	}

	public void deleteUserAccount(User user) {
		if (user != null && !(user instanceof Admin))
			user.deleteAccount(user.getUserName(), user.getPassword());
	}

	public void removePlaylist(Playlist playlist) {
		if (playlist != null) {
			User owner = playlist.getOwner();
			if (owner != null)
				owner.removePlaylist(playlist.getName());
		}
	}
}