import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:list_in/core/language/language_rep.dart';

// Events
abstract class LanguageEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadLanguageEvent extends LanguageEvent {}

class ChangeLanguageEvent extends LanguageEvent {
  final String languageCode;
  
  ChangeLanguageEvent({required this.languageCode});
  
  @override
  List<Object?> get props => [languageCode];
}

abstract class LanguageState extends Equatable {
  @override
  List<Object?> get props => [];
}

class LanguageInitial extends LanguageState {}

class LanguageLoaded extends LanguageState {
  final String languageCode;
  
  LanguageLoaded({required this.languageCode});
  
  @override
  List<Object?> get props => [languageCode];
}

// BLoC
class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  final LanguageRepository repository;
  
  LanguageBloc({required this.repository}) : super(LanguageInitial()) {
    on<LoadLanguageEvent>(_onLoadLanguage);
    on<ChangeLanguageEvent>(_onChangeLanguage);
  }
  
  void _onLoadLanguage(LoadLanguageEvent event, Emitter<LanguageState> emit) {
    final String languageCode = repository.getLanguage();
    emit(LanguageLoaded(languageCode: languageCode));
  }
  
  void _onChangeLanguage(ChangeLanguageEvent event, Emitter<LanguageState> emit) async {
    await repository.setLanguage(event.languageCode);
    emit(LanguageLoaded(languageCode: event.languageCode));
  }
}