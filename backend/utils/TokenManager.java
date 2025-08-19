package backend.utils;

import backend.model.User;
import com.google.gson.Gson;
import com.google.gson.GsonBuilder;
import com.google.gson.reflect.TypeToken;

import java.io.FileWriter;
import java.io.IOException;
import java.lang.reflect.Type;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.Map;
import java.util.UUID;

public class TokenManager {

    private static final String TOKENS_FILE = "data/tokens.json";
    private static final Map<String, Integer> tokenStore = new HashMap<>();
    private static final Gson gson = new GsonBuilder().setPrettyPrinting().create();

    static {
        loadTokens();
    }

    private static void loadTokens() {
        try {
            if (Files.exists(Path.of(TOKENS_FILE))) {
                String json = Files.readString(Path.of(TOKENS_FILE));
                Type type = new TypeToken<Map<String, Integer>>(){}.getType();
                Map<String, Integer> loadedTokens = gson.fromJson(json, type);
                if (loadedTokens != null) {
                    tokenStore.putAll(loadedTokens);
                }
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    private static void saveTokens() {
        try (FileWriter writer = new FileWriter(TOKENS_FILE)) {
            gson.toJson(tokenStore, writer);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }

    public static String generateToken(int userId) {
        String token = UUID.randomUUID().toString();
        tokenStore.put(token, userId);
        saveTokens();
        return token;
    }

    public static User getUserByToken(String token) {
        return JsonDatabase.findUserById(tokenStore.get(token));
    }

    public static Integer validateToken(String token) {
        return tokenStore.get(token);
    }

    public static boolean invalidateToken(String token) {
        boolean removed = tokenStore.remove(token) != null;
        if (removed) {
            saveTokens();
        }
        return removed;
    }
    
    public static void clearAllTokens() {
        tokenStore.clear();
        saveTokens();
    }
}