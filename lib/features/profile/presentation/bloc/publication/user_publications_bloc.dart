import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/profile/domain/usecases/publication/get_user_publications_usecase.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_event.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_state.dart';

class UserPublicationsBloc
    extends Bloc<UserPublicationsEvent, UserPublicationsState> {
  final GetUserPublicationsUseCase getUserPublicationsUseCase;
  static const int _pageSize = 20;

  UserPublicationsBloc({
    required this.getUserPublicationsUseCase,
  }) : super(const UserPublicationsState()) {
    on<FetchUserPublications>(_onFetchUserPublications);
    on<LoadMoreUserPublications>(_onLoadMoreUserPublications);
    on<RefreshUserPublications>(_onRefreshUserPublications);
  }

  Future<void> _onFetchUserPublications(
    FetchUserPublications event,
    Emitter<UserPublicationsState> emit,
  ) async {
    try {
      debugPrint('DEBUG: Starting initial fetch of publications');
      if (state.publications.isEmpty) {
        emit(state.copyWith(isLoading: true, error: null));
      } else {
        emit(state.copyWith(
            isLoading: true, error: null, isInitialLoading: true));
      }

      final result = await getUserPublicationsUseCase(
        params: GetUserPublicationsParams(
          page: 0,
          size: _pageSize,
        ),
      );

      result.fold(
        (failure) {
          debugPrint(
              'DEBUG: Initial fetch failed: ${_mapFailureToMessage(failure)}');
          emit(state.copyWith(
            isLoading: false,
            error: _mapFailureToMessage(failure),
            isInitialLoading: false,
          ));
        },
        (data) {
          debugPrint(
              'DEBUG: Initial fetch successful. Items count: ${data.content.length}');
          emit(state.copyWith(
            publications: data.content,
            isLoading: false,
            hasReachedEnd: data.last,
            currentPage: 0,
            isInitialLoading: false,
            error: null,
          ));
        },
      );
    } catch (e, stackTrace) {
      debugPrint('DEBUG: Exception during initial fetch: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
        isInitialLoading: false,
      ));
    }
  }

  Future<void> _onLoadMoreUserPublications(
    LoadMoreUserPublications event,
    Emitter<UserPublicationsState> emit,
  ) async {
    // Don't proceed if already loading or if we've reached the end
    if (state.isLoading || state.hasReachedEnd) {
      debugPrint(
          'DEBUG: Skip loading more - hasReachedEnd: ${state.hasReachedEnd}, isLoading: ${state.isLoading}');
      return;
    }

    if (state.publications.isEmpty) {
      debugPrint(
          'DEBUG: No initial data, triggering fetch instead of load more');
      await _onFetchUserPublications(FetchUserPublications(), emit);
      return;
    }

    // If no initial data, trigger initial fetch instead
    if (state.publications.isEmpty) {
      debugPrint(
          'DEBUG: No initial data, triggering fetch instead of load more');
      await _onFetchUserPublications(FetchUserPublications(), emit);
      return;
    }

    try {
      debugPrint(
          'DEBUG: Starting to load more publications. Current page: ${state.currentPage}');
      emit(state.copyWith(isLoading: true, error: null));

      final result = await getUserPublicationsUseCase(
        params: GetUserPublicationsParams(
          page: state.currentPage + 1,
          size: _pageSize,
        ),
      );

      result.fold(
        (failure) {
          debugPrint(
              'DEBUG: Load more failed: ${_mapFailureToMessage(failure)}');
          emit(state.copyWith(
            isLoading: false,
            error: _mapFailureToMessage(failure),
            // Preserve current page and data on error
          ));
        },
        (data) {
          debugPrint(
              'DEBUG: Load more successful. New items: ${data.content.length}');

          // Handle empty response
          if (data.content.isEmpty) {
            emit(state.copyWith(
              isLoading: false,
              hasReachedEnd: true,
              error: null,
            ));
            return;
          }

          emit(state.copyWith(
            publications: [...state.publications, ...data.content],
            isLoading: false,
            hasReachedEnd: data.last,
            currentPage: state.currentPage + 1,
            error: null,
          ));
        },
      );
    } catch (e, stackTrace) {
      debugPrint('DEBUG: Exception during load more: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
        // Preserve current page and data on error
      ));
    }
  }

  // Add this method
  Future<void> _onRefreshUserPublications(
    RefreshUserPublications event,
    Emitter<UserPublicationsState> emit,
  ) async {
    try {
      debugPrint('DEBUG: Starting refresh of publications');

      // Keep old data while loading
      emit(state.copyWith(isRefreshing: true, error: null));

      final result = await getUserPublicationsUseCase(
        params: GetUserPublicationsParams(
          page: 0,
          size: _pageSize,
        ),
      );

      result.fold(
        (failure) {
          debugPrint('DEBUG: Refresh failed: ${_mapFailureToMessage(failure)}');
          emit(state.copyWith(
            isRefreshing: false,
            error: _mapFailureToMessage(failure),
          ));
        },
        (data) {
          debugPrint(
              'DEBUG: Refresh successful. Items count: ${data.content.length}');
          emit(state.copyWith(
            publications: data.content,
            isRefreshing: false,
            hasReachedEnd: data.last,
            currentPage: 0,
            error: null,
          ));
        },
      );
    } catch (e, stackTrace) {
      debugPrint('DEBUG: Exception during refresh: $e');
      debugPrint('Stack trace: $stackTrace');
      emit(state.copyWith(
        isRefreshing: false,
        error: e.toString(),
      ));
    }
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return 'Server failure occurred';
      case NetworkFailure _:
        return 'No internet connection';
      default:
        return 'Connection error occurred';
    }
  }
}
