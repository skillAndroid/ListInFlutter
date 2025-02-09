
import 'package:list_in/features/profile/domain/entity/publication/publication_image_entity.dart';

class PublicationImageModel {
  final bool? isPrimary;
  final String url;

  PublicationImageModel.fromJson(Map<String, dynamic> json)
      : isPrimary = json['isPrimary'] as bool?,
        url = json['url'] as String;

  PublicationImageEntity toEntity() => PublicationImageEntity(
        isPrimary: isPrimary,
        url: url,
      );
}