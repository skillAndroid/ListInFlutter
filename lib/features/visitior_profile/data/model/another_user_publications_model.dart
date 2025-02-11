
import 'package:list_in/features/explore/data/models/publication_model.dart';
import 'package:list_in/features/visitior_profile/domain/entity/another_user_publications_entity.dart';

class AnotherUserPublicationsModel {
  final bool isLast;
  final int number;
  final bool first;
  final List<GetPublicationModel> content;
  final int size;
  final int totalElements;
  final int totalPages;

  AnotherUserPublicationsModel({
    required this.isLast,
    required this.content,
    required this.first,
    required this.number,
    required this.size,
    required this.totalElements,
    required this.totalPages,
  });

  factory AnotherUserPublicationsModel.fromJson(Map<String, dynamic> json) {
    return AnotherUserPublicationsModel(
      isLast: json['last'] ?? false,
      first: json['first'] ?? false,
      number: json['number'] ?? 0,
      size: json['size'] ?? 0,
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      content: (json['content'] as List?)
              ?.map((item) => GetPublicationModel.fromJson(item))
              .toList() ??
          [],
    );
  }
  AnotherUserPublicationsEntity toEntity() {
    return AnotherUserPublicationsEntity(
      isLast: isLast,
      first: first,
      size : size,
      totalElements : totalElements,
      number: number,
      content: content.map((model) => model.toEntity()).toList(),
    );
  }
}
