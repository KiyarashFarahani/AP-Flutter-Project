class Song {
  final int? id;
  String? filename;
  String? title;
  String? artist;
  String? cover;
  String? album;
  String? genre;
  int? duration;
  int? year;
  String? filePath;
  String? coverArtUrl;
  String? lyrics;
  int? playCount;
  int? likes;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool? isShareable;
  final List<String>? likedByUsers;

  Song({
    this.id,
    this.filename,
    this.title,
    this.artist,
    this.cover,
    this.album,
    this.genre,
    this.duration,
    this.year,
    this.filePath,
    this.coverArtUrl,
    this.lyrics,
    this.playCount,
    this.likes,
    this.createdAt,
    this.updatedAt,
    this.isShareable,
    this.likedByUsers,
  });

  factory Song.fromJson(Map<String, dynamic> json) => Song(
    id: json['id'],
    filename: json['filename'],
    title: json['title'],
    artist: json['artist'],
    album: json['album'],
    genre: json['genre'],
    duration: json['duration'],
    year: json['year'],
    filePath: json['filePath'],
    coverArtUrl: json['coverArtUrl'],
    lyrics: json['lyrics'],
    playCount: json['playCount'],
    likes: json['likes'],
    createdAt:
        json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
    updatedAt:
        json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    isShareable: json['isShareable'],
    likedByUsers:
        json['likedByUsers'] != null
            ? List<String>.from(json['likedByUsers'])
            : null,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'filename': filename,
    'title': title,
    'artist': artist,
    'album': album,
    'genre': genre,
    'duration': duration,
    'year': year,
    'filePath': filePath,
    'coverArtUrl': coverArtUrl,
    'lyrics': lyrics,
    'playCount': playCount,
    'likes': likes,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
    'isShareable': isShareable,
    'likedByUsers': likedByUsers,
  };
}
