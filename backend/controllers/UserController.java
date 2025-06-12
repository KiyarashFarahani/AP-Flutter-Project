package backend.controllers;

import backend.dto.Response;
import backend.model.User;
import backend.utils.JsonDatabase;
import backend.utils.TokenManager;

import java.util.Objects;

public class UserController {

    public Response<?> signUp(String username, String password, String confirmPassword) {
        if (!Objects.equals(password, confirmPassword)) {
            return new Response<>(400, null, "Passwords do not match");
        }

        if (JsonDatabase.findByUsername(username) != null) {
            return new Response<>(409, null, "Username already exists");
        }

        User user = new User();
        user.setUserName(username);
        user.setPassword(password);
        user.enableSharePermission();
        JsonDatabase.addUser(user);

        String token = TokenManager.generateToken(user.getId());

        return new Response<>(200, new ResponseData(user.getId(), token), "Account created successfully");
    }

    public Response<?> login(String username, String password) {
        User user = JsonDatabase.findByUsername(username);
        if (user == null || !Objects.equals(user.getPassword(), password)) {
            return new Response<>(401, null, "Invalid username or password");
        }
        String token = TokenManager.generateToken(user.getId());
        return new Response<>(200, new ResponseData(user.getId(), token), "Logged in successfully");
    }

    public Response<?> changePassword(String token, String oldPassword, String newPassword, String confirmNewPassword) {
        Integer userId = TokenManager.validateToken(token);
        if (userId == null) {
            return new Response<>(401, null, "Invalid token");
        }
        User user = JsonDatabase.findUserById(userId);
        if (!Objects.equals(user.getPassword(), oldPassword)) {
            return new Response<>(400, null, "Old password is incorrect");
        }
        if (!Objects.equals(newPassword, confirmNewPassword)) {
            return new Response<>(400, null, "New passwords do not match");
        }
        user.setPassword(newPassword);
        JsonDatabase.saveUsers();
        return new Response<>(200, null, "Password changed successfully");
    }

    public Response<?> changeUsername(String token, String newUsername) {
        Integer userId = TokenManager.validateToken(token);
        if (userId == null) {
            return new Response<>(401, null, "Invalid token");
        }
        if (JsonDatabase.findByUsername(newUsername) != null) {
            return new Response<>(409, null, "Username is already taken");
        }
        User user = JsonDatabase.findUserById(userId);
        user.setUserName(newUsername);
        JsonDatabase.saveUsers();
        return new Response<>(200, null, "Username changed successfully");
    }

    public Response<?> logout(String token) {
        boolean success = TokenManager.invalidateToken(token);
        if (!success) {
            return new Response<>(401, null, "Invalid token");
        }
        return new Response<>(200, null, "Logged out successfully");
    }

    public Response<?> deleteAccount(String token, String password) {
        Integer userId = TokenManager.validateToken(token);
        if (userId == null) {
            return new Response<>(401, null, "Invalid token");
        }
        User user = JsonDatabase.findUserById(userId);
        if (!Objects.equals(user.getPassword(), password)) {
            return new Response<>(400, null, "Password is incorrect");
        }
        JsonDatabase.deleteUser(user);
        TokenManager.invalidateToken(token);
        return new Response<>(200, null, "Account deleted successfully");
    }

    public Response<?> setSharingPermission(String token, boolean sharePermission) {
        Integer userId = TokenManager.validateToken(token);
        if (userId == null) {
            return new Response<>(401, null, "Invalid token");
        }
        User user = JsonDatabase.findUserById(userId);
        user.setSharePermission(sharePermission);
        JsonDatabase.saveUsers();
        return new Response<>(200, null, "Sharing permission updated successfully");
    }
}