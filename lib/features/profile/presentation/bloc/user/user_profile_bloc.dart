import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/core/usecases/usecases.dart';
import 'package:list_in/features/profile/domain/entity/user/user_profile_entity.dart';
import 'package:list_in/features/profile/domain/usecases/user/get_user_data_usecase.dart';
import 'package:list_in/features/profile/domain/usecases/user/update_user_image_usecase.dart';
import 'package:list_in/features/profile/domain/usecases/user/update_user_profile_usecase.dart';
import 'package:list_in/features/profile/presentation/bloc/user/user_profile_event.dart';
import 'package:list_in/features/profile/presentation/bloc/user/user_profile_state.dart';

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final UpdateUserProfileUseCase updateUserProfileUseCase;
  final UploadUserImagesUseCase uploadUserImagesUseCase;
  final GetUserDataUseCase getUserDataUseCase;

  UserProfileBloc({
    required this.updateUserProfileUseCase,
    required this.uploadUserImagesUseCase,
    required this.getUserDataUseCase,
  }) : super(UserProfileState()) {
    on<UpdateUserProfileWithImage>(_onUpdateUserProfileWithImage);
    on<GetUserData>(_onGetUserData);
  }

  Future<void> _onUpdateUserProfileWithImage(
    UpdateUserProfileWithImage event,
    Emitter<UserProfileState> emit,
  ) async {
    try {
      emit(state.copyWith(
        status: UserProfileStatus.loading,
        isUploading: event.imageFile != null,
      ));

      UserProfileEntity profileToUpdate = event.profile;

      if (event.imageFile != null) {
        final uploadResult = await uploadUserImagesUseCase(
          params: [event.imageFile!],
        );

        await uploadResult.fold(
          (failure) async {
            emit(state.copyWith(
              status: UserProfileStatus.failure,
              errorMessage: _mapFailureToMessage(failure),
              isUploading: false,
            ));
            return;
          },
          (imageUrls) async {
            if (imageUrls.isNotEmpty) {
              profileToUpdate = profileToUpdate.copyWith(
                profileImagePath: imageUrls.first,
              );
            }
          },
        );
      }

      final result = await updateUserProfileUseCase(
        params: profileToUpdate,
      );

      result.fold(
        (failure) => emit(state.copyWith(
          status: UserProfileStatus.failure,
          errorMessage: _mapFailureToMessage(failure),
          isUploading: false,
        )),
        (userDataAndToken) {
          final (userData, _) = userDataAndToken;
          emit(state.copyWith(
            status: UserProfileStatus.success,
            userData: userData,
            isUploading: false,
          ));
        },
      );
    } catch (e) {
      emit(state.copyWith(
        status: UserProfileStatus.failure,
        errorMessage: 'Unexpected error occurred',
        isUploading: false,
      ));
    }
  }

  Future<void> _onGetUserData(
    GetUserData event,
    Emitter<UserProfileState> emit,
  ) async {
    debugPrint('🚀 GetUserData event triggered');
    emit(state.copyWith(status: UserProfileStatus.loading));

    final result = await getUserDataUseCase(params: NoParams());
    debugPrint('📥 GetUserData result: $result');

    result.fold(
      (failure) {
        debugPrint('❌ GetUserData failure: ${failure.runtimeType}');
        emit(state.copyWith(
          status: UserProfileStatus.failure,
          errorMessage: _mapFailureToMessage(failure),
        ));
      },
      (userData) {
        debugPrint('✅ GetUserData success: $userData ');

        emit(state.copyWith(
          status: UserProfileStatus.success,
          userData: userData,
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
