part of 'zoom_cubit.dart';

abstract class ZoomState extends Equatable {
  final int zoomPercentage;
  const ZoomState({
    required this.zoomPercentage,
  });

  @override
  List<Object> get props => [
        zoomPercentage,
      ];
}

class AyahZoomState extends ZoomState {
  @override
  // ignore: overridden_fields
  final int zoomPercentage;
  @override
  // ignore: overridden_fields
  const AyahZoomState({required this.zoomPercentage})
      : super(
          zoomPercentage: zoomPercentage,
        );
}
