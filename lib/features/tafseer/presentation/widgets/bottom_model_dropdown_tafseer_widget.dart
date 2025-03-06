import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/language_service.dart';
import '../../../../core/widgets/book_generic_icon.dart';
import '../../../main/presentation/cubit/ayah_render_bloc/ayah_render_bloc_helper.dart';
import '../../data/models/tafseer_reading_model.dart';
import '../cubit/tafseer_page/tafseer_page_cubit_service.dart';

class BottomModelDropdownTafseerWidget extends StatelessWidget {
  BottomModelDropdownTafseerWidget({
    super.key,
    required this.currentTafseerCode,
  });

  final String currentTafseerCode;

  final List<TafseerReadingModel> tafseerBookList =
      TafseerReadingService().getTafseerList();

  Color getCurrentTafseerDetailsFromBookList(
    BuildContext context,
    String tafseerCode,
    List<TafseerReadingModel> tafseerBookList,
  ) {
    TafseerReadingModel currentTafseer = tafseerBookList.first;

    for (final TafseerReadingModel currentTafseerItem in tafseerBookList) {
      if (currentTafseerItem.tafseerCode == tafseerCode) {
        currentTafseer = currentTafseerItem;
      }
    }

    return (context.isDarkMode && currentTafseer.color == Colors.black)
        ? Colors.white
        : currentTafseer.color;
  }

  Widget singleTafseerItem(
    BuildContext context, {
    required String bookName,
    required String tafseerCode,
  }) {
    return Row(
      children: [
        BookGenericIcon(
          widthHeight: 25,
          color: getCurrentTafseerDetailsFromBookList(
            context,
            tafseerCode,
            tafseerBookList,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          bookName,
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
          left: 2,
          right: 2,
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
          value: TafseerPageCubitService().getCurrentTafseerBook(context),
          onChanged: (String? newValue) {
            if (newValue != null) {
              TafseerPageCubitService().initAndLoadPageFromBottomBar(
                context,
                fetchPageNumber: AyahRenderBlocHelper.getPageIndex(context) + 1,
                fetchTafseerCode: newValue,
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
          items: tafseerBookList.map((item) {
            String bookCode = item.tafseerCode;
            return DropdownMenuItem<String>(
              value: bookCode,
              child: singleTafseerItem(
                context,
                bookName: context.translate.localeName == AppStrings.arabicCode
                    ? item.tafseerNameArabic
                    : item.tafseerNameEnglish,
                tafseerCode: item.tafseerCode,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
