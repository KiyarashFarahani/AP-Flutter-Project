package backend.utils;

import backend.model.User;

import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class TokenManager {

    private static final Map<String, Integer> tokenStore = new HashMap<>();

    public static String generateToken(int userId) {
        String token = UUID.randomUUID().toString();
        tokenStore.put(token, userId);
        return token;
    }

    public static User getUserByToken(String token) {
        return JsonDatabase.findUserById(tokenStore.get(token));
    }

    public static Integer validateToken(String token) {
        return tokenStore.get(token);
    }

    public static boolean invalidateToken(String token) {
        return tokenStore.remove(token) != null;
    }
    
    public static void clearAllTokens() {
        tokenStore.clear();
    }
}