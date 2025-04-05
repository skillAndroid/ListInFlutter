import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:image_picker/image_picker.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';

abstract class UserPublicationsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class DeleteUserPublication extends UserPublicationsEvent {
  final String publicationId;

  DeleteUserPublication({required this.publicationId});
}

class FetchUserPublications extends UserPublicationsEvent {}

class LoadMoreUserPublications extends UserPublicationsEvent {}

class RefreshUserPublications extends UserPublicationsEvent {}

abstract class PublicationUpdateEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InitializePublication extends PublicationUpdateEvent {
  final GetPublicationEntity publication;

  InitializePublication(this.publication);

  @override
  List<Object?> get props => [publication];
}

class UpdateTitle extends PublicationUpdateEvent {
  final String title;

  UpdateTitle(this.title);

  @override
  List<Object?> get props => [title];
}

class UpdateDescription extends PublicationUpdateEvent {
  final String description;

  UpdateDescription(this.description);

  @override
  List<Object?> get props => [description];
}

class UpdatePrice extends PublicationUpdateEvent {
  final double price;

  UpdatePrice(this.price);

  @override
  List<Object?> get props => [price];
}

class UpdateCondition extends PublicationUpdateEvent {
  final String condition;

  UpdateCondition(this.condition);

  @override
  List<Object?> get props => [condition];
}

class UpdateBargain extends PublicationUpdateEvent {
  final bool canBargain;

  UpdateBargain(this.canBargain);

  @override
  List<Object?> get props => [canBargain];
}

class SubmitPublicationUpdate extends PublicationUpdateEvent {
  @override
  List<Object?> get props => [];
}

class ClearPublicationState extends PublicationUpdateEvent {
  @override
  List<Object?> get props => [];
}

class UpdateImages extends PublicationUpdateEvent {
  final List<XFile> images;
  final bool keepExisting;

  UpdateImages(this.images, {this.keepExisting = false});

  @override
  List<Object?> get props => [images, keepExisting];
}

class ReorderImages extends PublicationUpdateEvent {
  final int oldIndex;
  final int newIndex;
  ReorderImages(this.oldIndex, this.newIndex);
  @override
  List<Object?> get props => [oldIndex, newIndex];
}

class RemoveImage extends PublicationUpdateEvent {
  final int index;
  RemoveImage(this.index);
  @override
  List<Object?> get props => [index];
}

class ClearVideo extends PublicationUpdateEvent {
  @override
  List<Object?> get props => [];
}

class UpdateVideo extends PublicationUpdateEvent {
  final XFile? video;
  UpdateVideo(this.video);
  @override
  List<Object?> get props => [video];
}

class ToggleVideoPlayback extends PublicationUpdateEvent {
  final bool isPlaying;
  ToggleVideoPlayback(this.isPlaying);
  @override
  List<Object?> get props => [isPlaying];
}

class EditImage extends PublicationUpdateEvent {
  final int index;
  final Uint8List imageBytes;
  final bool
      isUrl; // true if editing a URL image, false if editing a local image

  EditImage(this.index, this.imageBytes, {this.isUrl = false});

  @override
  List<Object?> get props => [index, imageBytes, isUrl];
}
