import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/post/domain/usecases/get_catalogs_usecase.dart';
import 'package:list_in/features/post/domain/usecases/upload_images_usecase.dart';
import 'package:list_in/features/post/domain/usecases/upload_video_usecase.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_event.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_state.dart';
import 'package:list_in/features/profile/presentation/widgets/media_widget.dart';

class PublicationUpdateBloc
    extends Bloc<PublicationUpdateEvent, PublicationUpdateState> {
  final GetGategoriesUsecase updatePublicationUseCase;
  final UploadImagesUseCase uploadImagesUseCase;
  final UploadVideoUseCase uploadVideoUseCase;

  PublicationUpdateBloc({
    required this.updatePublicationUseCase,
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
    // Append new images to existing ones
    final List<XFile> updatedNewImages = [...state.newImages, ...event.images];
    emit(state.copyWith(newImages: updatedNewImages));
  }

  // void _onUpdateImages(
  //   UpdateImages event,
  //   Emitter<PublicationUpdateState> emit,
  // ) {
  //   // Append new images to existing ones
  //   final List<XFile> updatedNewImages = state.newImages;
  //   emit(state.copyWith(newImages: updatedNewImages));
  // }

  void _onReorderImages(
    ReorderImages event,
    Emitter<PublicationUpdateState> emit,
  ) {
    int oldIndex = event.oldIndex;
    int newIndex = event.newIndex;

    // Combine all images
    List<ImageItem> allImages = [
      ...state.imageUrls.map((url) => ImageItem(path: url, isUrl: true)),
      ...state.newImages
          .map((file) => ImageItem(path: file.path, isUrl: false)),
    ];

    // Perform reordering
    final item = allImages.removeAt(oldIndex);
    if (newIndex > oldIndex) newIndex--;
    allImages.insert(newIndex, item);

    // Split back into URLs and files
    final List<String> updatedUrls = [];
    final List<XFile> updatedNewImages = [];

    for (var image in allImages) {
      if (image.isUrl) {
        updatedUrls.add(image.path);
      } else {
        updatedNewImages.add(XFile(image.path));
      }
    }

    emit(state.copyWith(
      imageUrls: updatedUrls,
      newImages: updatedNewImages,
    ));
  }

  void _onRemoveImage(
    RemoveImage event,
    Emitter<PublicationUpdateState> emit,
  ) {
    List<ImageItem> allImages = [
      ...state.imageUrls.map((url) => ImageItem(path: url, isUrl: true)),
      ...state.newImages
          .map((file) => ImageItem(path: file.path, isUrl: false)),
    ];

    allImages.removeAt(event.index);

    final List<String> updatedUrls = [];
    final List<XFile> updatedNewImages = [];

    for (var image in allImages) {
      if (image.isUrl) {
        updatedUrls.add(image.path);
      } else {
        updatedNewImages.add(XFile(image.path));
      }
    }

    emit(state.copyWith(
      imageUrls: updatedUrls,
      newImages: updatedNewImages,
    ));
  }

  void _onClearVideo(
    ClearVideo event,
    Emitter<PublicationUpdateState> emit,
  ) {
    emit(state.copyWith(
      videoUrl: null,
      newVideo: null,
      hasDeletedVideo: true, // Mark that video was explicitly deleted
    ));
  }

  void _onUpdateVideo(
    UpdateVideo event,
    Emitter<PublicationUpdateState> emit,
  ) {
    emit(state.copyWith(
      newVideo: event.video,
      videoUrl: event.video == null ? null : state.videoUrl,
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
    if (state.imageUrls.isEmpty && state.newImages.isEmpty) {
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
    List<String> finalImageUrls = List.from(state.imageUrls);
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
    String? finalVideoUrl = state.hasDeletedVideo ? null : state.videoUrl;
    if (state.newVideo != null) {
      emit(state.copyWith(
          updatingState: PublicationUpdatingState.uploadingVideo));
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
        updatingState: PublicationUpdatingState.updatingPublication));
    final result = await updatePublicationUseCase(
        // UpdatePublicationParams(
        //   id: state.id,
        //   title: state.title,
        //   description: state.description,
        //   price: state.price,
        //   bargain: state.canBargain,
        //   condition: state.condition,
        //   imageUrls: finalImageUrls,
        //   videoUrl: finalVideoUrl,
        // ),
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
