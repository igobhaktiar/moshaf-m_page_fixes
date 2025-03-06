import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/language_service.dart';
import '../../../../core/widgets/book_generic_icon.dart';
import '../../../main/presentation/cubit/ayah_render_bloc/ayah_render_bloc_helper.dart';
import '../../data/datasources/quran_translation_service.dart';
import '../../data/models/translation_language_display_model.dart';
import '../cubit/translation_page/translation_page_cubit_service.dart';

class BottomModelDropdownTranslationWidget extends StatelessWidget {
  BottomModelDropdownTranslationWidget({
    super.key,
    required this.currentLanguageCode,
  });

  final String currentLanguageCode;

  final List<TranslationLanguageDisplayModel> languageDisplayList =
      QuranTranslationService().getLanguageList();

  Color getCurrentTranslationIconColor(
    BuildContext context,
  ) {
    return (context.isDarkMode) ? Colors.white : Colors.black;
  }

  Widget singleLanguageItem(
    BuildContext context, {
    required String languageName,
  }) {
    return Row(
      children: [
        BookGenericIcon(
          widthHeight: 25,
          color: getCurrentTranslationIconColor(
            context,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          languageName,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isRtl = LanguageService.isLanguageRtl(context);
    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        margin: const EdgeInsets.only(
          top: 10,
          left: 15,
          right: 15,
        ),
        padding: EdgeInsets.only(
          left: isRtl ? 0 : 15,
          right: isRtl ? 15 : 0,
        ), // Adjust padding as needed
        decoration: BoxDecoration(
          color: context.isDarkMode
              ? AppColors.tabBackgroundDark
              : AppColors.tabBackground,
          borderRadius: BorderRadius.circular(8), // Border radius
        ),
        child: DropdownButton<String>(
          value: TranslationPageCubitService().getCurrentLanguage(context),
          onChanged: (String? newValue) {
            if (newValue != null) {
              TranslationPageCubitService().initAndLoadPageFromBottomBar(
                context,
                fetchPageNumber: AyahRenderBlocHelper.getPageIndex(context) + 1,
                fetchLanguageCode: newValue,
              );
            }
          },
          elevation: 0,
          isExpanded: true,
          icon: Icon(
            Icons.arrow_drop_down_sharp,
            size: 50,
            color: context.isDarkMode ? Colors.white : Colors.black,
          ),
          underline: const SizedBox.shrink(),
          items: languageDisplayList.map((item) {
            String bookCode = item.languageCode;
            return DropdownMenuItem<String>(
              value: bookCode,
              child: singleLanguageItem(
                context,
                languageName:
                    context.translate.localeName == AppStrings.arabicCode
                        ? item.languageNameArabic
                        : item.languageNameEnglish,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
