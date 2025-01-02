class VideoModel {
  final String url;
  final String thumbnail;
  bool isPreloaded;
  bool isPlaying;
  final String title;       // Added title
  final String description; // Added description

  VideoModel({
    required this.url,
    required this.thumbnail,
    required this.title,
    required this.description,
    this.isPreloaded = false,
    this.isPlaying = false,
  });
}