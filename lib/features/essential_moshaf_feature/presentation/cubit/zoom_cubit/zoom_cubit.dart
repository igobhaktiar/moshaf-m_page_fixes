import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_strings.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'zoom_enum.dart';

part 'zoom_state.dart';

class ZoomCubit extends Cubit<ZoomState> {
  ZoomCubit({required this.sharedPreferences})
      : super(AyahZoomState(
          zoomPercentage: ZoomService().zoomPercentage[ZoomEnum.extralarge]!,
        ));
  static ZoomCubit get(context) => BlocProvider.of(context);

  final SharedPreferences sharedPreferences;

  init() {
    int savedZoom = sharedPreferences.getInt(AppStrings.savedZoom) ?? 30;
    ZoomEnum zoom = ZoomService().getZoomEnumFromPercentage(savedZoom);
    setCurrentZoom(
      zoom,
      logAnalyticsEvent: false,
    );
  }

  setCurrentZoom(ZoomEnum zoom, {bool logAnalyticsEvent = true}) {
    int zoomPercentage = ZoomService().zoomPercentage[zoom]!;
    emit(
      AyahZoomState(zoomPercentage: zoomPercentage),
    );
    sharedPreferences.setInt(AppStrings.savedZoom, zoomPercentage);
  }
}
