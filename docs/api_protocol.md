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
  "data":{
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
    "message": "Lgged in successfuly",
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

## 