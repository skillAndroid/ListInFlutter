import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:list_in/config/theme/app_theme.dart';
import 'package:list_in/core/local_data/shared_preferences.dart';

// Events
abstract class ThemeEvent {}

class ToggleThemeEvent extends ThemeEvent {}

class InitThemeEvent extends ThemeEvent {}

// States
abstract class ThemeState {}

class ThemeInitial extends ThemeState {}

class ThemeLoaded extends ThemeState {
  final bool isDarkMode;
  ThemeLoaded(this.isDarkMode);
}

// Theme Bloc
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPrefsService _prefsService;
  static const String _themeKey = 'isDarkMode';

  ThemeBloc(this._prefsService) : super(ThemeInitial()) {
    on<InitThemeEvent>(_onInitTheme);
    on<ToggleThemeEvent>(_onToggleTheme);
  }

  Future<void> _onInitTheme(
      InitThemeEvent event, Emitter<ThemeState> emit) async {
    final isDarkMode = _prefsService.getBool(_themeKey) ?? false;
    emit(ThemeLoaded(isDarkMode));
    _updateSystemUI(isDarkMode);
  }

  Future<void> _onToggleTheme(
      ToggleThemeEvent event, Emitter<ThemeState> emit) async {
    if (state is ThemeLoaded) {
      final currentState = state as ThemeLoaded;
      final newIsDarkMode = !currentState.isDarkMode;

      await _prefsService.saveBool(_themeKey, newIsDarkMode);
      emit(ThemeLoaded(newIsDarkMode));
      _updateSystemUI(newIsDarkMode);
    }
  }

  void _updateSystemUI(bool isDarkMode) {
    AppTheme.setStatusBarAndNavBarColor(
        isDarkMode ? AppTheme.darkTheme : AppTheme.lightTheme);
  }
}
