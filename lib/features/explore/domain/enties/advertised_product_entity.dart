
class AdvertisedProductEntity {
  final String videoUrl;
  final List<String> images;
  final String thumbnailUrl;
  final String title;
  int duration;
  final String id;
  final String userName;
  final double userRating;
  final int reviewsCount;
  final String location;
  final String price;

  AdvertisedProductEntity({
    required this.videoUrl,
    required this.images,
    required this.thumbnailUrl,
    required this.title,
    this.duration = 0,
    required this.id,
    required this.userName,
    required this.userRating,
    required this.reviewsCount,
    required this.location,
    required this.price,
  });
}