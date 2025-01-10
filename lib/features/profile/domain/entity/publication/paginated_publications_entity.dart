import 'package:list_in/features/profile/domain/entity/publication/publication_entity.dart';

class PaginatedPublicationsEntity {
  final List<PublicationEntity> content;
  final int number;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool first;
  final bool last;

  PaginatedPublicationsEntity({
    required this.content,
    required this.number,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.first,
    required this.last,
  });

  void fold(void Function(dynamic failure) param0, void Function(dynamic data) param1) {}
}