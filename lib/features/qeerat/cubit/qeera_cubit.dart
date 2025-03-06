import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/features/qeerat/data/qeerat_naration_data.dart';

import '../../../core/utils/app_context.dart';
import '../../main/presentation/cubit/ayah_render_bloc/ayah_render_bloc.dart';
import '../../main/presentation/cubit/ayah_render_bloc/ayah_render_bloc_helper.dart';

class QeraatCubit extends Cubit<List<QaraaStruct>> {
  QeraatCubit() : super(List<QaraaStruct>.from([])); // Start with an empty list

  void initializeQeraaList() {
    initqaraaList();
    emit(List<QaraaStruct>.from(qaraaList)); // Initialize with global qaraaList
  }

  void toggleAll(bool isEnabled) {
    final updatedList = state.map((qaraa) {
      qaraa.isEnabled = isEnabled;
      qaraa.imam1.isEnabled = isEnabled;
      qaraa.imam2.isEnabled = isEnabled;
      return qaraa;
    }).toList();
    emit(updatedList);
    updatePage();
  }

  void toggleQaraa(int index, bool isEnabled) {
    final updatedList = List<QaraaStruct>.from(state);
    final qaraa = updatedList[index];
    qaraa.isEnabled = isEnabled;
    qaraa.imam1.isEnabled = isEnabled;
    qaraa.imam2.isEnabled = isEnabled;
    emit(updatedList);
    updatePage();
  }

  void toggleImam1(int index, bool isEnabled) {
    final updatedList = List<QaraaStruct>.from(state);
    final qaraa = updatedList[index];
    qaraa.imam1.isEnabled = isEnabled;
    if (!qaraa.imam1.isEnabled && !qaraa.imam2.isEnabled) {
      qaraa.isEnabled = false;
    } else {
      qaraa.isEnabled = true;
    }
    emit(updatedList);
    updatePage();
  }

  void toggleImam2(int index, bool isEnabled) {
    final updatedList = List<QaraaStruct>.from(state);
    final qaraa = updatedList[index];
    qaraa.imam2.isEnabled = isEnabled;
    if (!qaraa.imam1.isEnabled && !qaraa.imam2.isEnabled) {
      qaraa.isEnabled = false;
    } else {
      qaraa.isEnabled = true;
    }
    emit(updatedList);
    updatePage();
  }

  Future<void> updatePage() async {
    BuildContext? currentContext = AppContext.getAppContext();
    if (currentContext != null) {
      final AyahRenderState ayahRenderState =
          BlocProvider.of<AyahRenderBloc>(currentContext).state;
      if (ayahRenderState is AyahRendered) {
        AyahRenderBlocHelper.pageChangeInitialize(
          currentContext,
          ayahRenderState.pageIndex!,
        );
      }
    }
  }
}
