import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/post/domain/usecases/upload_images_usecase.dart';
import 'package:list_in/features/post/domain/usecases/upload_video_usecase.dart';
import 'package:list_in/features/profile/domain/entity/publication/update_post_entity.dart';
import 'package:list_in/features/profile/domain/usecases/publication/update_publication_usecase.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_event.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_state.dart';

class PublicationUpdateBloc
    extends Bloc<PublicationUpdateEvent, PublicationUpdateState> {
  final UpdatePostUseCase updatePostUseCase;
  final UploadImagesUseCase uploadImagesUseCase;
  final UploadVideoUseCase uploadVideoUseCase;

  PublicationUpdateBloc({
    required this.updatePostUseCase,
    required this.uploadImagesUseCase,
    required this.uploadVideoUseCase,
  }) : super(PublicationUpdateState.initial()) {
    on<InitializePublication>(_onInitializePublication);
    on<UpdateTitle>(_onUpdateTitle);
    on<UpdateDescription>(_onUpdateDescription);
    on<UpdatePrice>(_onUpdatePrice);
    on<UpdateCondition>(_onUpdateCondition);
    on<UpdateBargain>(_onUpdateBargain);
    on<UpdateImages>(_onUpdateImages);
    on<ReorderImages>(_onReorderImages);
    on<RemoveImage>(_onRemoveImage);
    on<UpdateVideo>(_onUpdateVideo);
    on<ToggleVideoPlayback>(_onToggleVideoPlayback);
    on<SubmitPublicationUpdate>(_onSubmitUpdate);
    on<ClearPublicationState>(_onClearState);
    on<ClearVideo>(_onClearVideo);
  }

  void _onClearState(
    ClearPublicationState event,
    Emitter<PublicationUpdateState> emit,
  ) {
    emit(PublicationUpdateState.initial());
  }

  void _onInitializePublication(
    InitializePublication event,
    Emitter<PublicationUpdateState> emit,
  ) {
    emit(state.copyWith(
      id: event.publication.id,
      title: event.publication.title,
      description: event.publication.description,
      price: event.publication.price,
      canBargain: event.publication.bargain,
      condition: event.publication.productCondition,
      imageUrls: event.publication.productImages.map((img) => img.url).toList(),
      videoUrl: event.publication.videoUrl,
    ));
  }

  void _onUpdateImages(
    UpdateImages event,
    Emitter<PublicationUpdateState> emit,
  ) {
    // Replace existing images with new ones
    emit(state.copyWith(newImages: event.images));
  }

  void _onReorderImages(
    ReorderImages event,
    Emitter<PublicationUpdateState> emit,
  ) {
    int oldIndex = event.oldIndex;
    int newIndex = event.newIndex;

    // Only reorder new images
    List<XFile> updatedImages = List.from(state.newImages);
    final item = updatedImages.removeAt(oldIndex);
    if (newIndex > oldIndex) newIndex--;
    updatedImages.insert(newIndex, item);

    emit(state.copyWith(newImages: updatedImages));
  }

  void _onRemoveImage(
    RemoveImage event,
    Emitter<PublicationUpdateState> emit,
  ) {
    List<XFile> updatedImages = List.from(state.newImages);
    updatedImages.removeAt(event.index);
    emit(state.copyWith(newImages: updatedImages));
  }

  void _onClearVideo(
    ClearVideo event,
    Emitter<PublicationUpdateState> emit,
  ) {
    emit(state.copyWith(
      videoUrl: null,
      newVideo: null,
      hasDeletedVideo: true,
    ));
  }

  void _onUpdateVideo(
    UpdateVideo event,
    Emitter<PublicationUpdateState> emit,
  ) {
    emit(state.copyWith(
      newVideo: event.video,
      videoUrl: null, // Clear previous video URL
    ));
  }

  void _onToggleVideoPlayback(
    ToggleVideoPlayback event,
    Emitter<PublicationUpdateState> emit,
  ) {
    emit(state.copyWith(isVideoPlaying: event.isPlaying));
  }

  void _onUpdateTitle(
    UpdateTitle event,
    Emitter<PublicationUpdateState> emit,
  ) {
    emit(state.copyWith(title: event.title));
  }

  void _onUpdateDescription(
    UpdateDescription event,
    Emitter<PublicationUpdateState> emit,
  ) {
    emit(state.copyWith(description: event.description));
  }

  void _onUpdatePrice(
    UpdatePrice event,
    Emitter<PublicationUpdateState> emit,
  ) {
    emit(state.copyWith(price: event.price));
  }

  void _onUpdateCondition(
    UpdateCondition event,
    Emitter<PublicationUpdateState> emit,
  ) {
    emit(state.copyWith(condition: event.condition));
  }

  void _onUpdateBargain(
    UpdateBargain event,
    Emitter<PublicationUpdateState> emit,
  ) {
    emit(state.copyWith(canBargain: event.canBargain));
  }

  Future<void> _onSubmitUpdate(
    SubmitPublicationUpdate event,
    Emitter<PublicationUpdateState> emit,
  ) async {
    if (state.imageUrls!.isEmpty && state.newImages.isEmpty) {
      emit(state.copyWith(
        error: 'At least one image is required',
        updatingState: PublicationUpdatingState.error,
      ));
      return;
    }

    emit(state.copyWith(
      isSubmitting: true,
      error: null,
      updatingState: PublicationUpdatingState.uploadingImages,
    ));

    // Upload new images if any
    List<String> finalImageUrls = List.from(state.imageUrls!);
    if (state.newImages.isNotEmpty) {
      final imagesResult = await uploadImagesUseCase(params: state.newImages);
      final hasImageUploadFailed = imagesResult.fold(
        (failure) => true,
        (urls) {
          finalImageUrls.addAll(urls);
          return false;
        },
      );

      if (hasImageUploadFailed) {
        emit(state.copyWith(
          isSubmitting: false,
          error: 'Failed to upload images',
          updatingState: PublicationUpdatingState.error,
        ));
        return;
      }
    }

    // Upload new video if any
    String? finalVideoUrl;
    if (state.newVideo != null) {
      emit(state.copyWith(
        updatingState: PublicationUpdatingState.uploadingVideo,
      ));
      final videoResult = await uploadVideoUseCase(params: state.newVideo!);
      final hasVideoUploadFailed = videoResult.fold(
        (failure) => true,
        (url) {
          finalVideoUrl = url;
          return false;
        },
      );

      if (hasVideoUploadFailed) {
        emit(state.copyWith(
          isSubmitting: false,
          error: 'Failed to upload video',
          updatingState: PublicationUpdatingState.error,
        ));
        return;
      }
    }

    // Update publication
    emit(state.copyWith(
      updatingState: PublicationUpdatingState.updatingPublication,
    ));

    final result = await updatePostUseCase(
      params: UpdatePostParams(
        id: state.id,
        post: UpdatePostEntity(
          isNegatable: state.canBargain,
          title: state.title,
          description: state.description,
          price: state.price,
          imageUrls: finalImageUrls,
          videoUrl: finalVideoUrl,
          productCondition: state.condition,
        ),
      ),
    );
   result.fold(
      (failure) => emit(state.copyWith(
        isSubmitting: false,
        error: _mapFailureToMessage(failure),
        updatingState: PublicationUpdatingState.error,
      )),
      (success) => emit(state.copyWith(
        isSubmitting: false,
        isSuccess: true,
        updatingState: PublicationUpdatingState.success,
      )),
    );
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure _:
        return 'Server failure occurred';
      case NetworkFailure _:
        return 'No internet connection';
      default:
        return 'Unexpected error occurred';
    }
  }
}
