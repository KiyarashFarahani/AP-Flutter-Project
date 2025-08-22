class User {
  final int? id;
  final String? username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final String? profilePictureUrl;
  final String? bio;
  final DateTime? joinedDate;
  final DateTime? lastActiveDate;
  final int? totalSongs;
  final int? totalPlaylists;
  final int? totalListeningHours;
  final bool? isVerified;
  final String? favoriteGenre;
  final Map<String, dynamic>? preferences;

  User({
    this.id,
    this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.profilePictureUrl,
    this.bio,
    this.joinedDate,
    this.lastActiveDate,
    this.totalSongs,
    this.totalPlaylists,
    this.totalListeningHours,
    this.isVerified,
    this.favoriteGenre,
    this.preferences,
  });

  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    if (firstName != null) return firstName!;
    if (username != null) return username!;
    return 'User';
  }

  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName![0]}${lastName![0]}'.toUpperCase();
    }
    if (username != null && username!.isNotEmpty) {
      return username![0].toUpperCase();
    }
    return 'U';
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      profilePictureUrl: json['profilePictureUrl'],
      bio: json['bio'],
      joinedDate: json['joinedDate'] != null
          ? DateTime.parse(json['joinedDate'])
          : null,
      lastActiveDate: json['lastActiveDate'] != null
          ? DateTime.parse(json['lastActiveDate'])
          : null,
      totalSongs: json['totalSongs'],
      totalPlaylists: json['totalPlaylists'],
      totalListeningHours: json['totalListeningHours'],
      isVerified: json['isVerified'],
      favoriteGenre: json['favoriteGenre'],
      preferences: json['preferences'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'profilePictureUrl': profilePictureUrl,
      'bio': bio,
      'joinedDate': joinedDate?.toIso8601String(),
      'lastActiveDate': lastActiveDate?.toIso8601String(),
      'totalSongs': totalSongs,
      'totalPlaylists': totalPlaylists,
      'totalListeningHours': totalListeningHours,
      'isVerified': isVerified,
      'favoriteGenre': favoriteGenre,
      'preferences': preferences,
    };
  }

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? profilePictureUrl,
    String? bio,
    DateTime? joinedDate,
    DateTime? lastActiveDate,
    int? totalSongs,
    int? totalPlaylists,
    int? totalListeningHours,
    bool? isVerified,
    String? favoriteGenre,
    Map<String, dynamic>? preferences,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      profilePictureUrl: profilePictureUrl ?? this.profilePictureUrl,
      bio: bio ?? this.bio,
      joinedDate: joinedDate ?? this.joinedDate,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      totalSongs: totalSongs ?? this.totalSongs,
      totalPlaylists: totalPlaylists ?? this.totalPlaylists,
      totalListeningHours: totalListeningHours ?? this.totalListeningHours,
      isVerified: isVerified ?? this.isVerified,
      favoriteGenre: favoriteGenre ?? this.favoriteGenre,
      preferences: preferences ?? this.preferences,
    );
  }
}