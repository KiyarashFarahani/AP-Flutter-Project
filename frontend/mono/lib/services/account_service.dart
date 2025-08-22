import 'package:mono/models/user.dart';
import 'package:mono/services/socket_manager.dart';
import 'package:mono/services/token_storage.dart';

class AccountService {
  final SocketManager socketManager = SocketManager();

  Future<User?> getCurrentUser() async {
    try {
      final token = await TokenStorage.getToken();
      if (token == null) return null;

      return User(
        id: token['userId'],
        username: 'music_lover_${token['userId']}',
        email: 'user@mono.app',
        firstName: 'Music',
        lastName: 'Lover',
        bio: 'Passionate about discovering new music and creating amazing playlists.',
        joinedDate: DateTime.now().subtract(const Duration(days: 365)),
        lastActiveDate: DateTime.now(),
        totalSongs: 1247,
        totalPlaylists: 23,
        totalListeningHours: 156,
        isVerified: true,
        favoriteGenre: 'Electronic',
        preferences: {
          'darkMode': false,
          'notifications': true,
          'autoPlay': true,
          'highQuality': true,
        },
      );
    } catch (e) {
      print('Error fetching user: $e');
      return null;
    }
  }

  Future<bool> updateUser(User user) async {
    try {
      print('Updating user: ${user.toJson()}');
      return true;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }

  Future<bool> updateProfilePicture(String imagePath) async {
    try {
      print('Updating profile picture: $imagePath');
      return true;
    } catch (e) {
      print('Error updating profile picture: $e');
      return false;
    }
  }

  Future<Map<String, int>> getUserStats() async {
    try {
      return {
        'songsPlayed': 1247,
        'playlistsCreated': 23,
        'hoursListened': 156,
        'favoriteArtists': 45,
        'totalLikes': 89,
      };
    } catch (e) {
      print('Error fetching user stats: $e');
      return {};
    }
  }

  Future<bool> logout() async {
    try {
      await TokenStorage.deleteToken();
      socketManager.dispose();
      return true;
    } catch (e) {
      print('Error during logout: $e');
      return false;
    }
  }
}