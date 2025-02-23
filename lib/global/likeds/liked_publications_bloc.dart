import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/explore/domain/enties/publication_entity.dart';
import 'package:list_in/features/profile/domain/usecases/publication/get_user_liked_publications_usecase.dart';
import 'package:list_in/global/global_bloc.dart';
import 'package:list_in/global/global_event.dart';
import 'package:list_in/global/likeds/liked_publications_event.dart';
import 'package:list_in/global/likeds/liked_publications_state.dart';

class LikedPublicationsBloc
    extends Bloc<LikedPublicationsEvent, LikedPublicationsState> {
  final GetUserLikedPublicationsUseCase getLikedPublicationsUseCase;
  final GlobalBloc globalBloc;
  static const int _pageSize = 30;

  LikedPublicationsBloc({
    required this.getLikedPublicationsUseCase,
    required this.globalBloc,
  }) : super(const LikedPublicationsState()) {
    on<FetchLikedPublications>(_onFetchLikedPublications);
    on<LoadMoreLikedPublications>(_onLoadMoreLikedPublications);
    on<RefreshLikedPublications>(_onRefreshLikedPublications);
    on<UpdateLocalLikedPublication>(_onUpdateLocalLikedPublication);
  }

  

  Future<void> _onFetchLikedPublications(
    FetchLikedPublications event,
    Emitter<LikedPublicationsState> emit,
  ) async {
    try {
      debugPrint('DEBUG: Starting initial fetch of liked publications');

      emit(state.copyWith(
        isLoading: true,
        error: null,
        isInitialLoading: state.publications.isEmpty,
      ));

      final result = await getLikedPublicationsUseCase(
        params: GetUserLikedPublicationsParams(
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

          // Sync like statuses with global bloc
          _syncLikeStatusesWithGlobal(data.content);

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

  Future<void> _onLoadMoreLikedPublications(
    LoadMoreLikedPublications event,
    Emitter<LikedPublicationsState> emit,
  ) async {
    if (state.isLoading || state.hasReachedEnd) {
      return;
    }

    try {
      emit(state.copyWith(isLoading: true, error: null));

      final result = await getLikedPublicationsUseCase(
        params: GetUserLikedPublicationsParams(
          page: state.currentPage + 1,
          size: _pageSize,
        ),
      );

      result.fold(
        (failure) {
          emit(state.copyWith(
            isLoading: false,
            error: _mapFailureToMessage(failure),
          ));
        },
        (data) {
          if (data.content.isEmpty) {
            emit(state.copyWith(
              isLoading: false,
              hasReachedEnd: true,
              error: null,
            ));
            return;
          }

          // Sync new publications' like statuses with global bloc
          _syncLikeStatusesWithGlobal(data.content);

          emit(state.copyWith(
            publications: [...state.publications, ...data.content],
            isLoading: false,
            hasReachedEnd: data.last,
            currentPage: state.currentPage + 1,
            error: null,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onRefreshLikedPublications(
    RefreshLikedPublications event,
    Emitter<LikedPublicationsState> emit,
  ) async {
    try {
      emit(state.copyWith(isRefreshing: true, error: null));

      final result = await getLikedPublicationsUseCase(
        params: GetUserLikedPublicationsParams(
          page: 0,
          size: _pageSize,
        ),
      );

      result.fold(
        (failure) {
          emit(state.copyWith(
            isRefreshing: false,
            error: _mapFailureToMessage(failure),
          ));
        },
        (data) {
          // Sync refreshed publications' like statuses with global bloc
          _syncLikeStatusesWithGlobal(data.content);

          emit(state.copyWith(
            publications: data.content,
            isRefreshing: false,
            hasReachedEnd: data.last,
            currentPage: 0,
            error: null,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        isRefreshing: false,
        error: e.toString(),
      ));
    }
  }

  void _onUpdateLocalLikedPublication(
    UpdateLocalLikedPublication event,
    Emitter<LikedPublicationsState> emit,
  ) {
    if (!event.isLiked) {
      // Remove unliked publication from the list
      final updatedPublications = state.publications
          .where((pub) => pub.id != event.publicationId)
          .toList();

      emit(state.copyWith(publications: updatedPublications));

      // If we removed an item and have more to load, trigger loading more
      if (updatedPublications.length < _pageSize && !state.hasReachedEnd) {
        add(LoadMoreLikedPublications());
      }
    }
  }

  void _syncLikeStatusesWithGlobal(List<GetPublicationEntity> publications) {
    final Map<String, bool> likeStatuses = {};
    for (var publication in publications) {
      likeStatuses[publication.id] = true; // All publications here are liked
    }
    globalBloc.add(SyncLikeStatusesEvent(
      publicationLikeStatuses: likeStatuses,
    ));
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return 'Server error occurred';
      case NetworkFailure _:
        return 'Network error occurred';
      default:
        return 'Unexpected error occurred';
    }
  }
}
