import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/injection_container.dart';

import '../../navigation_service.dart';

class AppContext {
  AppContext._();

  static BuildContext? getAppContext() {
    return getItInstance<NavigationService>().getContext();
  }
}
