import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_strings.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

class LanguageService {
  LanguageService._();

  static List<String> rtlLanguages = [
    "ar",
    "he",
    "pr",
    "ur",
    "ps",
    "prs",
    "syr",
    "yi",
    "dv",
    "azb",
    "ckb",
    "sd",
    "ug"
  ];

  static bool isLanguageRtl(
    BuildContext context,
  ) {
    bool isLanguageRtl = false;
    if (context.translate.localeName == AppStrings.arabicCode) {
      isLanguageRtl = true;
    }
    return isLanguageRtl;
  }

  static bool isCodeLanguageRtl(
    String code,
  ) {
    bool isLanguageRtl = false;
    if (rtlLanguages.contains(code)) {
      isLanguageRtl = true;
    }
    return isLanguageRtl;
  }

  static bool isUrduOrPersian(String code) {
    return code == "ur" || code == "pr";
  }

  static bool isLanguageArabic(
    BuildContext context,
  ) {
    bool isLanguageArabic = false;
    if (context.translate.localeName == AppStrings.arabicCode) {
      isLanguageArabic = true;
    }
    return isLanguageArabic;
  }
}
