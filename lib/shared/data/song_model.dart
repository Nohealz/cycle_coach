class SongModel {
  final String id;
  final String title;
  final String artist;
  final int durationSeconds;
  final String? previewUrl;

  const SongModel({
    required this.id,
    required this.title,
    required this.artist,
    required this.durationSeconds,
    this.previewUrl,
  });
}

