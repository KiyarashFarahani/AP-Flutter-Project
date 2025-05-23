# API protocol🎀

## Sign Up

Creates a new user account. The client must send a username, password, and confirm the password.

### Client Request

```json
{
  "action": "sign_up",
  "data": {
    "username": "Biboo@gmail.com",
    "password": "cnwiuD52_do",
    "confirm_password": "cnwiuD52_do"
  }
}
```

### Server Response(success)

```json
{
  "status": "success",
  "data": {
    "user_id": "u123",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "message": "Account created successfully"
  }
}
```

### Server Response(Error)

```json
{
  "status": "error",
  "error": "Username already exists"
}
```

## Log in

Authenticates a user by verifying the username and password. Returns an authentication token on success.

### Client Request

```json
{
  "action": "log_in",
  "data": {
    "username": "Biboo@gmail.com",
    "password": "cnwiuD52_do"
  }
}
```

### Server Request(success)

```json
{
  "status": "success",
  "data": {
    "user_id": "u123",
    "message": "Logged in successfuly",
    "token": "abc.def.ghi"
  }
}
```

### Srever Request(error)

```json
{
  "status": "error",
  "error": "Invalid username or password"
}
```

## Change password

Allows an authenticated user to update their password by providing the old password and new password twice for confirmation.

### Clinet Request

```json
{
  "action": "change_password",
  "token": "abc.def.ghi",
  "data": {
    "old_password": "cnwiuD52_do",
    "new_password": "bcawjS315_p",
    "confirm_new_passwprd": "bcawjS315_p"
  }
}
```

### Server Response(success)

```json
{
  "status": "success",
  "message": "Password changed successfully"
}
```

### Server Response(error)

```json
{
  "status": "error",
  "message": "Old password is incorrect"
}
```

## Change Username

Allows an authenticated user to change their username, as long as the new username is not already taken.

### Client Request

```json
{
  "action": "change_username",
  "token": "abc.def.ghi",
  "data": {
    "new_username": "Didoo@gmail.com"
  }
}
```

### Server Response(success)

```json
{
  "status": "success",
  "message": "Username changed successfully"
}
```

### Server Response(error)

```json
{
  "status": "error",
  "message": "Username is already taken"
}
```

## Add songs to account

Allows an authenticated user to add one or more existing songs from the server’s library to their personal account or playlist. The client sends a list of song IDs to be added.

### Client Request

```json
{
  "action": "add_song",
  "token": "abc.def.ghi",
  "data": {
    "song_id": "sing123"
  }
}
```

### Server Response(success)

```json
{
  "status": "success",
  "message": "Songs added successfully to your account"
}
```

### Server Response(error)

```json
{
  "status": "error",
  "message": "One or more songs could not be added"
}
```

## Log Out

Logs the user out by invalidating the current authentication token on the server (if you're tracking tokens), or simply instructs the client to delete the stored token. Since the server is stateless in your design, it may not need to store token state—but this action is still useful for the client to clean up and signal intent to log out

### Client Request

```json
{
  "action": "log_out",
  "token": "abc.def.ghi"
}
```

### Server Response(success)

```json
{
  "status": "success",
  "message": "Logged out successfuly"
}
```

### Server Response(error)

```json
{
  "status": "error",
  "message": "Invalid token"
}
```

## Delete Account

Allows an authenticated user to permanently delete their account. This action requires a valid token, and reconfirming their password for security.

### Client Request

```json
{
  "action": "delete_account",
  "token": "abc.def.ghi",
  "data": {
    "password": "bcawjS315_p"
  }
}
```

### Server Response(success)

```json
{
  "status": "success",
  "message": "Account deleted successfully"
}
```

### Server Response(error)

```json
{
  "status": "error",
  "message": "Password is incorrect"
}
```

## Share Song

Allows one user to share a song from their account with another user, if the recipient allows it via their account settings.

### Client Request

```json
{
  "action": "share_song",
  "token": "abc.def.ghi",
  "data": {
    "recipient_username": "didoo@gmail.com",
    "song_id": "song123"
  }
}
```

### Server Response(success)

```json
{
  "status": "success",
  "message": "Song shared with didoo@gmail.com"
}
```

### Server Response(error: sharing not allowed)

```json
{
  "status": "error",
  "message": "Recipient has not enabled song sharing"
}
```

### Server Response(error: recipient not found)

```json
{
  "status": "success",
  "message": "Recipient user not found"
}
```
## Share Playlist

### Client Request

```json
{
  "action": "share_playlist",
  "token": "abc.def.ghi",
  "data": {
    "recipient_username": "didoo@gmail.com",
    "playlist_id": "pl_456"
  }
}
```

### Server Response(success)

```json
{
  "status": "success",
  "message": "Playlist shared with didoo@gmail.com"
}
```

### Server Response(error: Recipient Not Found)

```json
{
  "status": "error",
  "messgae": "Recipient not found"
}
```

### Server Response(error: Sharing Disabled)

```json
{
  "status": "error",
  "message": "Recipient has disabled sharing"
}
```

### Server Response(error: Playlist Not Found / Unauthorized)

```json
{
  "status": "error",
  "message": "Playlist not found or does not belong to you"
}
```