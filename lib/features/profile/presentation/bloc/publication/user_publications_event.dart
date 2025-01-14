import 'package:equatable/equatable.dart';

abstract class UserPublicationsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchUserPublications extends UserPublicationsEvent {}

class LoadMoreUserPublications extends UserPublicationsEvent {}
class RefreshUserPublications extends UserPublicationsEvent {}