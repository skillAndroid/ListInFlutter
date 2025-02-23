import 'package:equatable/equatable.dart';

// Events
abstract class LikedPublicationsEvent extends Equatable {
  const LikedPublicationsEvent();

  @override
  List<Object> get props => [];
}

class RemoveLikedPublication extends LikedPublicationsEvent {
  final String publicationId;
  const RemoveLikedPublication(this.publicationId);
}

class FetchLikedPublications extends LikedPublicationsEvent {}

class LoadMoreLikedPublications extends LikedPublicationsEvent {}

class RefreshLikedPublications extends LikedPublicationsEvent {}

class UpdateLocalLikedPublication extends LikedPublicationsEvent {
  final String publicationId;
  final bool isLiked;

  const UpdateLocalLikedPublication({
    required this.publicationId,
    required this.isLiked,
  });

  @override
  List<Object> get props => [publicationId, isLiked];
}
