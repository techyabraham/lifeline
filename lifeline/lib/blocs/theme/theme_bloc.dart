import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class ThemeEvent {}
class ToggleTheme extends ThemeEvent {}

// State
class ThemeState {
  final bool isDarkMode;
  ThemeState({required this.isDarkMode});
}

// Bloc
class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState(isDarkMode: false)) {
    on<ToggleTheme>((event, emit) {
      emit(ThemeState(isDarkMode: !state.isDarkMode));
    });
  }
}
