import 'package:list_in/features/explore/data/models/publication_model.dart';
import 'package:list_in/features/profile/domain/entity/publication/paginated_publications_entity.dart';

class PaginatedPublicationsModel {
  final List<GetPublicationModel> content;
  final int number;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool first;
  final bool last;

  PaginatedPublicationsModel.fromJson(Map<String, dynamic> json)
      : content = (json['content'] as List<dynamic>)
            .map((item) => GetPublicationModel.fromJson(item as Map<String, dynamic>))
            .toList(),
        number = json['number'] as int,
        size = json['size'] as int,
        totalElements = json['totalElements'] as int,
        totalPages = json['totalPages'] as int,
        first = json['first'] as bool,
        last = json['last'] as bool;

  PaginatedPublicationsEntity toEntity() => PaginatedPublicationsEntity(
        content: content.map((pub) => pub.toEntity()).toList(),
        number: number,
        size: size,
        totalElements: totalElements,
        totalPages: totalPages,
        first: first,
        last: last,
      );
}
