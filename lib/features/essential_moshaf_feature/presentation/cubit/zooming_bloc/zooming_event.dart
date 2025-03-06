part of 'zooming_bloc.dart';

sealed class ZoomingEvent extends Equatable {
  const ZoomingEvent();

  @override
  List<Object> get props => [];
}

class UpdateZoomingStatus extends ZoomingEvent {
  const UpdateZoomingStatus({
    required this.isZooming,
  });

  final bool isZooming;
}
