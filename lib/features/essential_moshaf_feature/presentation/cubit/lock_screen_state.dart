part of 'lock_screen_cubit.dart';

abstract class LockScreenState extends Equatable {
  const LockScreenState();

  @override
  List<Object> get props => [];
}

class LockScreenInitial extends LockScreenState {}

class LockScreenUpdated extends LockScreenState {
  final bool lockScreenEnabled;

  const LockScreenUpdated({required this.lockScreenEnabled});

  @override
  List<Object> get props => [lockScreenEnabled];
}
