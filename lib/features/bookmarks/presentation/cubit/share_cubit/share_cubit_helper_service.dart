import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/data/models/ayat_swar_models.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../../../core/utils/app_strings.dart';
import '../../../../../core/widgets/moshaf_snackbar.dart';
import 'share_cubit.dart';

class ShareAyahModel {
  const ShareAyahModel({
    required this.surahNumber,
    required this.numberInSurah,
    required this.ayahShareableString,
  });

  final int surahNumber;
  final int numberInSurah;
  final String ayahShareableString;
}

class ShareCubitHelperService {
  //Bloc Actions
  void printShareCubitState(
    BuildContext context,
  ) {
    print(context.read<ShareCubit>().state);
  }

  void startSelectionForMultiSharing(
    BuildContext context, {
    required AyahModel ayah,
    required List<dynamic> allAyatWithTashkeel,
  }) {
    context.read<ShareCubit>().startMultiShare(
          ShareAyahModel(
            surahNumber: ayah.surahNumber!,
            numberInSurah: ayah.numberInSurah!,
            ayahShareableString: ShareCubitHelperService()
                .getAyahShareableString(
                    ayah: ayah, allAyatWithTashkeel: allAyatWithTashkeel),
          ),
        );
    MoshafSnackbar.triggerSnackbar(
      context,
      text:
          "${context.translate.tap_ayahs_your_want_to_add}\n${context.translate.press_share_when_finished}",
    );
  }

  void addAyahToShareList(
    BuildContext context, {
    required AyahModel ayah,
    required List<dynamic> allAyatWithTashkeel,
  }) {
    context.read<ShareCubit>().addShareAyah(
          ShareAyahModel(
            surahNumber: ayah.surahNumber!,
            numberInSurah: ayah.numberInSurah!,
            ayahShareableString:
                ShareCubitHelperService().getAyahShareableString(
              ayah: ayah,
              allAyatWithTashkeel: allAyatWithTashkeel,
            ),
          ),
        );
    MoshafSnackbar.triggerSnackbar(
      context,
      text:
          "${context.translate.ayah_added}\n${ayah.surah!} ${ayah.numberInSurah!}",
    );
  }

  void cancelSelectionForMultiSharing(BuildContext context) {
    context.read<ShareCubit>().endMultiShare();
    MoshafSnackbar.triggerSnackbar(
      context,
      text: context.translate.sharing_cancelled,
    );
  }

  String getMultiSharedAyahs(
    BuildContext context,
  ) {
    MoshafSnackbar.triggerSnackbar(
      context,
      text: "${context.translate.loading} ${context.translate.please_wait}",
    );
    String multiSelectedAyahs = "";
    final ShareState shareState = context.read<ShareCubit>().state;
    if (shareState is ShareLoaded) {
      List<ShareAyahModel> sharingAyahs = shareState.selectedAyahs;
      sharingAyahs.sort((a, b) => a.surahNumber.compareTo(b.surahNumber));
      for (var ayah in sharingAyahs) {
        multiSelectedAyahs =
            '$multiSelectedAyahs\n\n${ayah.ayahShareableString}';
      }
    }
    return multiSelectedAyahs;
  }

  //Helper Functions
  String getAyahShareableString({
    required AyahModel ayah,
    required List<dynamic> allAyatWithTashkeel,
  }) {
    final shareAyahString =
        '${allAyatWithTashkeel[ayah.number! - 1]['text']} \n آية رقم ${ayah.numberInSurah} \n ${ayah.surah} \n  مصحف دولة الكويت للقراءات العشر \n ${AppStrings.appUrl}';
    return shareAyahString;
  }

  bool isMultishareTurnedOn(BuildContext context) {
    bool isMultiShareOn = false;
    if (context.read<ShareCubit>().state is ShareLoaded) {
      isMultiShareOn = true;
    }
    return isMultiShareOn;
  }
}
