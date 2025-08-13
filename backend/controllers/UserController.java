package backend.controllers;

import backend.dto.Response;
import backend.model.Theme;
import backend.model.User;
import backend.utils.JsonDatabase;
import backend.utils.TokenManager;
import com.google.gson.Gson;

import java.util.*;
import java.util.HashMap;

public class UserController {

    public Response<?> signUp(String username, String password, String confirmPassword) {
        if (!password.trim().equals(confirmPassword.trim())) {
            return new Response<>(400, null, "Passwords do not match");
        }
        if (JsonDatabase.findUserByUsername(username) != null) {
            return new Response<>(409, null, "Username already exists");
        }
        User user = new User();
        user.setUserName(username);
        user.setPassword(password);
        user.enableSharePermission();
        JsonDatabase.addUser(user);
        String token = TokenManager.generateToken(user.getId());
        Map<String,Object> data = new HashMap<>();
        data.put("user_id", user.getId());
        data.put("token", token);
        data.put("message", "Account created successfully");
        return new Response<>(200, data, "Account created successfully");
    }

    public Response<?> login(String username, String password) {
        User user = JsonDatabase.findUserByUsername(username);
        if (user == null || !Objects.equals(user.getPassword(), password)) {
            return new Response<>(401, null, "Invalid username or password");
        }
        String token = TokenManager.generateToken(user.getId());
        Map<String,Object> data = new HashMap<>();
        data.put("user_id", user.getId());
        data.put("token", token);
        data.put("message", "Logged in successfully");
        return new Response<>(200, data, "Logged in successfully");
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
        if (JsonDatabase.findUserByUsername(newUsername) != null) {
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

    public Response<?> setDarkLightMode(String token, Theme newTheme) {
        Integer userId = TokenManager.validateToken(token);
        if (userId == null) {
            return new Response<>(401, null, "Invalid token");
        }
        User user = JsonDatabase.findUserById(userId);
        user.setTheme(newTheme);
        JsonDatabase.saveUsers();
        return new Response<>(200, null, "Dark/Light Mode updated successfully");
    }

    public Response<?> updateProfilePicture(String token, String profileImageUrl) {
        Integer userId = TokenManager.validateToken(token);
        if (userId == null) {
            return new Response<>(401, null, "Invalid token");
        }
        User user = JsonDatabase.findUserById(userId);
        user.setProfileImageUrl(profileImageUrl);
        JsonDatabase.saveUsers();
        return new Response<>(200, null, "Profile picture updated successfully");
    }

    public Response<?> removeProfilePicture(String token) {
        Integer userId = TokenManager.validateToken(token);
        if (userId == null) {
            return new Response<>(401, null, "Invalid token");
        }
        User user = JsonDatabase.findUserById(userId);
        user.setProfileImageUrl(null);
        JsonDatabase.saveUsers();
        return new Response<>(200, null, "Profile picture removed successfully");
    }

    public Response<?> getUserInfo(String token) {
        Integer userId = TokenManager.validateToken(token);
        if (userId == null) {
            return new Response<>(401, null, "Invalid token");
        }
        User user = JsonDatabase.findUserById(userId);
        if (user == null) {
            return new Response<>(404, null, "User not found");
        }
        Map<String, Object> userInfo = new HashMap<>();
        userInfo.put("username", user.getUsername());
        userInfo.put("email", user.getEmail());
        userInfo.put("theme", user.getTheme());
        userInfo.put("share_permission", user.isSharePermission());
        userInfo.put("profile_image_url", user.getProfileImageUrl());
        return new Response<>(200, userInfo, "User information retrieved successfully");
    }
}