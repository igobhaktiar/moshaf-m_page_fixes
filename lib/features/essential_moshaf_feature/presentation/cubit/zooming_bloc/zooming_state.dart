part of 'zooming_bloc.dart';

sealed class ZoomingState extends Equatable {
  const ZoomingState();

  @override
  List<Object> get props => [];
}

final class ZoomingInitial extends ZoomingState {}

final class ZoomingStatus extends ZoomingState {
  const ZoomingStatus({
    required this.isZooming,
  });
  final bool isZooming;
}
