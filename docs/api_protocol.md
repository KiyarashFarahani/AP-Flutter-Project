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
