class ProductEntity {
  final String name;
  final List<String> images;
  final String location;
  final int price;
  final bool isNew;
  final String id;

  ProductEntity({
    required this.name,
    required this.images,
    required this.location,
    required this.price,
    required this.isNew,
    required this.id,
  });
}