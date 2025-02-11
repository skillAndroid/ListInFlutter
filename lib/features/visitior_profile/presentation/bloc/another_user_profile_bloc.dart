import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/visitior_profile/domain/usecase/get_another_user_profile_usecase.dart';
import 'package:list_in/features/visitior_profile/presentation/bloc/another_user_profile_event.dart';
import 'package:list_in/features/visitior_profile/presentation/bloc/another_user_profile_state.dart';

class AnotherUserProfileBloc
    extends Bloc<AnotherUserProfileEvent, AnotherUserProfileState> {
  final GetAnotherUserDataUseCase getUserDataUseCase;

  AnotherUserProfileBloc({
    required this.getUserDataUseCase,
  }) : super(AnotherUserProfileState()) {
    on<GetAnotherUserData>(_onGetUserData);
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
}
