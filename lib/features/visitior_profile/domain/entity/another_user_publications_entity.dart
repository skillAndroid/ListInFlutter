import 'package:list_in/features/explore/domain/enties/publication_entity.dart';

class AnotherUserPublicationsEntity {
  final bool first;
  final bool isLast;
  final int number;
  final int totalElements;
  final int size;
  final List<GetPublicationEntity> content;

  AnotherUserPublicationsEntity({
    required this.first,
    required this.number,
    required this.isLast,
    required this.content,
    required this.size,
    required this.totalElements,
  });
}
