import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_colors.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_strings.dart';
import 'package:qeraat_moshaf_kwait/core/utils/assets_manager.dart';
import 'package:qeraat_moshaf_kwait/core/utils/constants.dart';
import 'package:qeraat_moshaf_kwait/features/quran_translation/presentation/screens/translation_page_screen.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../../core/utils/slide_pagee_transition.dart';
import '../../../../core/widgets/book_generic_icon.dart';
import '../../data/datasources/quran_translation_service.dart';
import '../../data/models/translation_language_display_model.dart';
import '../cubit/translation_page/translation_page_cubit_service.dart';

class TranslationListScreen extends StatelessWidget {
  const TranslationListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<TranslationLanguageDisplayModel> languageDisplayList =
        QuranTranslationService().getLanguageList();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.translate.translation,
        ),
        leading: AppConstants.customBackButton(
          context,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          AppConstants.customHomeButton(
            context,
          ),
        ],
        flexibleSpace: Container(
          decoration: BoxDecoration(
              image: context.isDarkMode
                  ? null
                  : const DecorationImage(
                      image: AssetImage(AppAssets.pattern), fit: BoxFit.cover)),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppColors.lightGrey,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.translate.translation,
                    style: context.textTheme.bodySmall!.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView.builder(
                  itemBuilder: (context, index) {
                    TranslationLanguageDisplayModel currentLanguage =
                        languageDisplayList[index];
                    return InkWell(
                      onTap: () async {
                        TranslationPageCubitService().initAndLoadPage(
                          context,
                          languageCode: currentLanguage.languageCode,
                        );
                        pushSlide(
                          context,
                          screen: TranslationPageScreen(
                            languageCode: currentLanguage.languageCode,
                            languageName: context.translate.localeName ==
                                    AppStrings.arabicCode
                                ? currentLanguage.languageNameArabic
                                : currentLanguage.languageNameEnglish,
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 24,
                              horizontal: 20,
                            ),
                            child: Row(
                              children: [
                                BookGenericIcon(
                                  widthHeight: 30,
                                  color: (context.isDarkMode)
                                      ? Colors.white
                                      : Colors.black,
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                Text(context.translate.localeName ==
                                        AppStrings.arabicCode
                                    ? currentLanguage.languageNameArabic
                                    : currentLanguage.languageNameEnglish),
                              ],
                            ),
                          ),
                          Divider(
                            height: 1,
                            thickness: 2,
                            color: (context.isDarkMode)
                                ? Colors.white
                                : Colors.black,
                          ),
                        ],
                      ),
                    );
                  },
                  itemCount: languageDisplayList.length,
                  shrinkWrap: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
