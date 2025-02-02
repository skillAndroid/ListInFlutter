import 'package:equatable/equatable.dart';
import 'package:list_in/features/profile/domain/entity/publication/publication_entity.dart';

abstract class UserPublicationsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchUserPublications extends UserPublicationsEvent {}

class LoadMoreUserPublications extends UserPublicationsEvent {}

class RefreshUserPublications extends UserPublicationsEvent {}

abstract class PublicationUpdateEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class InitializePublication extends PublicationUpdateEvent {
  final PublicationEntity publication;

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
