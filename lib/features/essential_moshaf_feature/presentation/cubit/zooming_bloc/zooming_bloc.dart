import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'zooming_event.dart';
part 'zooming_state.dart';

class ZoomingBloc extends Bloc<ZoomingEvent, ZoomingState> {
  ZoomingBloc()
      : super(const ZoomingStatus(
          isZooming: false,
        )) {
    on<UpdateZoomingStatus>((event, emit) {
      emit(ZoomingInitial());
      emit(ZoomingStatus(
        isZooming: event.isZooming,
      ));
    });
  }
}
