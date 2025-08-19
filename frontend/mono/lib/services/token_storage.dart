import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class TokenStorage {
  static const String _tokenFileName = 'auth_token.json';
  
  static Future<void> saveToken(String token, int userId) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_tokenFileName');
      
      final tokenData = {
        'token': token,
        'userId': userId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };
      
      await file.writeAsString(jsonEncode(tokenData));
      print('Token saved successfully');
    } catch (e) {
      print('Error saving token: $e');
    }
  }
  
  static Future<Map<String, dynamic>?> getToken() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_tokenFileName');
      
      if (!await file.exists()) {
        return null;
      }
      
      final jsonString = await file.readAsString();
      final tokenData = jsonDecode(jsonString) as Map<String, dynamic>;

      final timestamp = tokenData['timestamp'] as int;
      final tokenAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      final maxAge = 30 * 24 * 60 * 60 * 1000; // 30 days
      
      if (tokenAge > maxAge) {
        await deleteToken();
        return null;
      }
      
      return tokenData;
    } catch (e) {
      print('Error reading token: $e');
      return null;
    }
  }
  
  static Future<void> deleteToken() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_tokenFileName');
      
      if (await file.exists()) {
        await file.delete();
        print('Token deleted successfully');
      }
    } catch (e) {
      print('Error deleting token: $e');
    }
  }
  
  static Future<bool> hasValidToken() async {
    final token = await getToken();
    return token != null && token['token'] != null;
  }
}
