part of 'bottom_widget_cubit.dart';

sealed class BottomWidgetState extends Equatable {
  const BottomWidgetState();

  @override
  List<Object> get props => [];
}

final class BottomWidgetInitial extends BottomWidgetState {}

final class BottomWidgetLoading extends BottomWidgetState {}

class BottomWidgetOpenState extends BottomWidgetState {
  const BottomWidgetOpenState({
    required this.isOpened,
  });
  final bool isOpened;
}
