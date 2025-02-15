import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/visitior_profile/domain/usecase/follow_usecase.dart';
import 'package:list_in/features/visitior_profile/domain/usecase/get_another_user_profile_usecase.dart';
import 'package:list_in/features/visitior_profile/domain/usecase/get_another_user_publications_usecase.dart';
import 'package:list_in/features/visitior_profile/presentation/bloc/another_user_profile_event.dart';
import 'package:list_in/features/visitior_profile/presentation/bloc/another_user_profile_state.dart';

class AnotherUserProfileBloc
    extends Bloc<AnotherUserProfileEvent, AnotherUserProfileState> {
  final GetAnotherUserDataUseCase getUserDataUseCase;
  final GetPublicationsByIdUsecase getPublications;
  final FollowUserUseCase followUserUseCase;
  static const int pageSize = 20;

  AnotherUserProfileBloc({
    required this.getUserDataUseCase,
    required this.getPublications,
    required this.followUserUseCase,
  }) : super(AnotherUserProfileState()) {
    on<GetAnotherUserData>(_onGetUserData);
    on<FetchPublications>(_onFetchPublications);
    on<FollowUser>(_onFollowUser);
    on<ClearUserData>(_onClearUserData); // Добавляем обработчик
  }

  void _onClearUserData(
    ClearUserData event,
    Emitter<AnotherUserProfileState> emit,
  ) {
    emit(AnotherUserProfileState()); 
  }

  Future<void> _onFollowUser(
    FollowUser event,
    Emitter<AnotherUserProfileState> emit,
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
          status: AnotherUserProfileStatus.failure,
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
          status: AnotherUserProfileStatus.success,
          profile:
              updatedProfile, // This now contains updated followers, following, and isFollowing
        ));
      },
    );
  }

  Future<void> _onGetUserData(
    GetAnotherUserData event,
    Emitter<AnotherUserProfileState> emit,
  ) async {
    debugPrint('🚀 GetUserData event triggered');
    emit(state.copyWith(status: AnotherUserProfileStatus.loading));

    final result = await getUserDataUseCase(params: event.userId);

    debugPrint('📥 GetUserData result: $result');
    result.fold(
      (failure) {
        debugPrint('❌ GetUserData failure: ${failure.runtimeType}');
        emit(state.copyWith(
          status: AnotherUserProfileStatus.failure,
          errorMessage: _mapFailureToMessage(failure),
        ));
      },
      (userData) {
        debugPrint('✅ GetUserData success: $userData ');
        emit(state.copyWith(
          status: AnotherUserProfileStatus.success,
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
    Emitter<AnotherUserProfileState> emit,
  ) async {
    // Don't load more if we're already at the end
    if (state.hasReachedEnd && !event.isInitialFetch) return;

    if (event.isInitialFetch) {
      emit(state.copyWith(
        status: AnotherUserProfileStatus.loading,
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
          status: AnotherUserProfileStatus.failure,
          errorMessage: _mapFailureToMessage(failure),
          isLoadingMore: false,
        ));
      },
      (publicationsPage) {
        final updatedPublications = event.isInitialFetch
            ? publicationsPage.content
            : [...state.publications, ...publicationsPage.content];

        emit(state.copyWith(
          status: AnotherUserProfileStatus.success,
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
