import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'share_cubit_helper_service.dart';

part 'share_state.dart';

class ShareCubit extends Cubit<ShareState> {
  ShareCubit() : super(ShareInitial());

  static ShareCubit get(BuildContext context) => BlocProvider.of(context);

  late final List<ShareAyahModel> shareList;

  Future<void> init() async {
    shareList = [];
  }

  void startMultiShare(ShareAyahModel initialShareAyahToAdd) {
    emit(ShareInitial());
    shareList.add(initialShareAyahToAdd);
    emit(ShareLoaded(shareList));
  }

  void endMultiShare() {
    shareList.clear();
    emit(ShareInitial());
  }

  void addShareAyah(ShareAyahModel initialShareAyahToAdd) {
    bool isAlreadyPresentInShareList = false;
    //Check to remove duplicates
    for (var ayah in shareList) {
      if (ayah.surahNumber == initialShareAyahToAdd.surahNumber &&
          ayah.numberInSurah == initialShareAyahToAdd.numberInSurah) {
        isAlreadyPresentInShareList = true;
      }
    }
    if (!isAlreadyPresentInShareList) {
      shareList.add(initialShareAyahToAdd);
    }
    emit(ShareLoaded(shareList));
  }

  Future<void> deleteShareAt(int index) async => shareList.removeAt(index);
}
