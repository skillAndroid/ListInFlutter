import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:list_in/core/error/failure.dart';
import 'package:list_in/features/post/domain/usecases/get_catalogs_usecase.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_event.dart';
import 'package:list_in/features/profile/presentation/bloc/publication/user_publications_state.dart';

class PublicationUpdateBloc
    extends Bloc<PublicationUpdateEvent, PublicationUpdateState> {
  final GetGategoriesUsecase updatePublicationUseCase;

  PublicationUpdateBloc({
    required this.updatePublicationUseCase,
  }) : super(PublicationUpdateState.initial()) {
    on<InitializePublication>(_onInitializePublication);
    on<UpdateTitle>(_onUpdateTitle);
    on<UpdateDescription>(_onUpdateDescription);
    on<UpdatePrice>(_onUpdatePrice);
    on<UpdateCondition>(_onUpdateCondition);
    on<UpdateBargain>(_onUpdateBargain);
    on<SubmitPublicationUpdate>(_onSubmitUpdate);
    on<ClearPublicationState>(_onClearState);
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
    ));
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
    emit(state.copyWith(isSubmitting: true, error: null));

    final result = await updatePublicationUseCase(
        // UpdatePublicationParams(
        //   id: state.id,
        //   title: state.title,
        //   description: state.description,
        //   price: state.price,
        //   bargain: state.canBargain,
        //   condition: state.condition,
        // ),
        );

    result.fold(
      (failure) => emit(state.copyWith(
        isSubmitting: false,
        error: _mapFailureToMessage(failure),
      )),
      (success) => emit(state.copyWith(
        isSubmitting: false,
        isSuccess: true,
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
