import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocProvider, Cubit;
import 'package:qeraat_moshaf_kwait/core/utils/app_strings.dart'
    show AppStrings;
import 'package:shared_preferences/shared_preferences.dart'
    show SharedPreferences;
import 'package:wakelock_plus/wakelock_plus.dart';

part 'lock_screen_state.dart';

class LockScreenCubit extends Cubit<LockScreenState> {
  LockScreenCubit({required this.sharedPreferences})
      : super(LockScreenInitial());
  static LockScreenCubit get(context) => BlocProvider.of(context);

  final SharedPreferences sharedPreferences;

  bool get lockScreenEnabled =>
      sharedPreferences.getBool(AppStrings.lockScreenEnabledKey) ?? false;

  Future<void> init() async {
    emit(LockScreenUpdated(lockScreenEnabled: lockScreenEnabled));
    _applyLockScreenSetting();
  }

  Future<void> setLockScreenEnabled(bool newValue) async {
    await sharedPreferences.setBool(AppStrings.lockScreenEnabledKey, newValue);
    emit(LockScreenUpdated(lockScreenEnabled: newValue));
    _applyLockScreenSetting();
  }

  void _applyLockScreenSetting() {
    if (lockScreenEnabled) {
      print('Wakelock value:  $lockScreenEnabled');
      WakelockPlus.enable();

      print('   Wakelock.enable();');
    } else {
      print('Wakelock value:  $lockScreenEnabled');

      WakelockPlus.disable();

      print('  Wakelock.disable();');
    }
  }
}
