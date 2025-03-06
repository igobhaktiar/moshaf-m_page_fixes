// juz_popup_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// juz_popup_state.dart
abstract class JuzPopupState {}

class JuzPopupInitial extends JuzPopupState {}

class JuzPopupEnabled extends JuzPopupState {
  final bool showPopup;
  JuzPopupEnabled(this.showPopup);
}

class JuzPopupCubit extends Cubit<JuzPopupState> {
  JuzPopupCubit({required this.sharedPreferences}) : super(JuzPopupInitial());

  // Static instance for global access
  static JuzPopupCubit? _instance;
  static JuzPopupCubit get instance {
    if (_instance == null) {
      throw Exception(
          'JuzPopupCubit not initialized. Call initializeJuzPopupCubit() first.');
    }
    return _instance!;
  }

  // Initialize the global instance
  static Future<void> initializeJuzPopupCubit(
      SharedPreferences sharedPreferences) async {
    _instance = JuzPopupCubit(sharedPreferences: sharedPreferences);
    await _instance!.init();
  }

  final SharedPreferences sharedPreferences;
  static const String _juzPopupKey = 'juz_popup_enabled';

  bool get isJuzPopupEnabled =>
      sharedPreferences.getBool(_juzPopupKey) ?? false;

  Future<void> init() async {
    emit(JuzPopupEnabled(isJuzPopupEnabled));
  }

  Future<void> toggleJuzPopup(bool newValue) async {
    await sharedPreferences.setBool(_juzPopupKey, newValue);
    emit(JuzPopupEnabled(newValue));
  }

  // Helper method to check if popup should be shown
  bool shouldShowPopup() {
    final currentState = state;
    return currentState is JuzPopupEnabled && currentState.showPopup;
  }
}
