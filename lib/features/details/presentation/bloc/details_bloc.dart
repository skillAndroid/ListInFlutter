// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/details/domain/usecase/get_single_publication_usecase.dart';
import 'package:list_in/features/details/presentation/bloc/details_event.dart';
import 'package:list_in/features/details/presentation/bloc/details_state.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/visitior_profile/domain/usecase/follow_usecase.dart';
import 'package:list_in/features/visitior_profile/domain/usecase/get_another_user_profile_usecase.dart';
import 'package:list_in/features/visitior_profile/domain/usecase/get_another_user_publications_usecase.dart';
import 'package:list_in/global/global_bloc.dart';
import 'package:list_in/global/global_event.dart';

class DetailsBloc extends Bloc<DetailsEvent, DetailsState> {
  final GetAnotherUserDataUseCase getUserDataUseCase;
  final GetPublicationsByIdUsecase getPublications;
  final FollowUserUseCase followUserUseCase;
  final GetPublicationUseCase getPublicationUseCase; // New usecase
  final GlobalBloc globalBloc;
  static const int pageSize = 20;

  DetailsBloc({
    required this.getUserDataUseCase,
    required this.getPublications,
    required this.followUserUseCase,
    required this.getPublicationUseCase, // New dependency
    required this.globalBloc,
  }) : super(DetailsState()) {
    on<GetAnotherUserData>(_onGetUserData);
    on<FetchPublications>(_onFetchPublications);
    on<FollowUser>(_onFollowUser);
    on<FetchSinglePublication>(_onFetchSinglePublication); // New event handler
  }

  // Helper method to sync single publication like status
  void _syncLikeStatusForSinglePublication(GetPublicationEntity publication) {
    final Map<String, bool> publicationLikeStatuses = {
      publication.id: publication.isLiked,
    };

    globalBloc.add(SyncLikeStatusesEvent(
      publicationLikeStatuses: publicationLikeStatuses,
    ));
  }

  // New method to handle single publication fetching
  Future<void> _onFetchSinglePublication(
    FetchSinglePublication event,
    Emitter<DetailsState> emit,
  ) async {
    emit(state.copyWith(isLoadingSinglePublication: true));
    print('Bloc Part here is the publication id ${event.publicationId}');
    final result = await getPublicationUseCase(params: event.publicationId);

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: DetailsStatus.failure,
          errorMessage: _mapFailureToMessage(failure),
          isLoadingSinglePublication: false,
        ));
      },
      (publication) {
        // Sync the like status for this single publication
        _syncLikeStatusForSinglePublication(publication);

        emit(state.copyWith(
          status: DetailsStatus.success,
          singlePublication: publication,
          isLoadingSinglePublication: false,
        ));
      },
    );
  }

  // Updated _syncLikeStatusesForPublications to work with list
  void _syncLikeStatusesForPublications(
      List<GetPublicationEntity> publications) {
    final Map<String, bool> publicationLikeStatuses = {};

    for (var publication in publications) {
      publicationLikeStatuses[publication.id] = publication.isLiked;
    }

    globalBloc.add(SyncLikeStatusesEvent(
      publicationLikeStatuses: publicationLikeStatuses,
    ));
  }

  // Rest of the methods remain the same...
  Future<void> _onFollowUser(
    FollowUser event,
    Emitter<DetailsState> emit,
  ) async {
    emit(state.copyWith(isFollowingInProgress: true));

    final params = FollowParams(
      userId: event.userId,
      isFollowing: event.isFollowing,
    );

    final result = await followUserUseCase(params: params);

    result.fold(
      (failure) {
        emit(state.copyWith(
          isFollowingInProgress: false,
          status: DetailsStatus.failure,
          errorMessage: _mapFailureToMessage(failure),
        ));

        // Show error message
        ScaffoldMessenger.of(event.context).showSnackBar(
          SnackBar(content: Text(_mapFailureToMessage(failure))),
        );
      },
      (updatedProfile) {
        emit(state.copyWith(
          isFollowingInProgress: false,
          status: DetailsStatus.success,
          profile:
              updatedProfile, // This now contains updated followers, following, and isFollowing
        ));
      },
    );
  }

  Future<void> _onGetUserData(
    GetAnotherUserData event,
    Emitter<DetailsState> emit,
  ) async {
    debugPrint('🚀 GetUserData event triggered');
    emit(state.copyWith(status: DetailsStatus.loading));

    final result = await getUserDataUseCase(params: event.userId);

    debugPrint('📥 GetUserData result: $result');
    result.fold(
      (failure) {
        debugPrint('❌ GetUserData failure: ${failure.runtimeType}');
        emit(state.copyWith(
          status: DetailsStatus.failure,
          errorMessage: _mapFailureToMessage(failure),
        ));
      },
      (userData) {
        debugPrint('✅ GetUserData success: $userData ');
        emit(state.copyWith(
          status: DetailsStatus.success,
          profile: userData,
        ));
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return 'Server error occurred';
      case NetworkFailure _:
        return 'Network error occurred';
      case ValidationFailure _:
        return 'Validation error occurred';
      default:
        return 'Unexpected error occurred';
    }
  }

  Future<void> _onFetchPublications(
    FetchPublications event,
    Emitter<DetailsState> emit,
  ) async {
    // Don't load more if we're already at the end
    if (state.hasReachedEnd && !event.isInitialFetch) return;

    if (event.isInitialFetch) {
      emit(state.copyWith(
        status: DetailsStatus.loading,
        currentPage: 0,
        hasReachedEnd: false,
        publications: [],
      ));
    } else {
      emit(state.copyWith(isLoadingMore: true));
    }

    final params = GetPublicationsByIdParams(
      userId: event.userId,
      page: event.isInitialFetch ? 0 : state.currentPage + 1,
      size: pageSize,
    );

    final result = await getPublications(params: params);

    result.fold(
      (failure) {
        emit(state.copyWith(
          status: DetailsStatus.failure,
          errorMessage: _mapFailureToMessage(failure),
          isLoadingMore: false,
        ));
      },
      (publicationsPage) {
        final updatedPublications = event.isInitialFetch
            ? publicationsPage.content
            : [...state.publications, ...publicationsPage.content];
        _syncLikeStatusesForPublications(updatedPublications);
        emit(state.copyWith(
          status: DetailsStatus.success,
          publications: updatedPublications,
          isLoadingMore: false,
          hasReachedEnd: publicationsPage.isLast,
          currentPage: publicationsPage.number,
          totalElements: publicationsPage.totalElements,
        ));
      },
    );
  }
}
