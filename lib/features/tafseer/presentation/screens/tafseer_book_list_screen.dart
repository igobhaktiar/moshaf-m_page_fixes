import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_strings.dart';
import 'package:qeraat_moshaf_kwait/core/utils/assets_manager.dart';
import 'package:qeraat_moshaf_kwait/core/utils/constants.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../../core/utils/slide_pagee_transition.dart';
import '../../data/models/tafseer_reading_model.dart';
import '../cubit/tafseer_page/tafseer_page_cubit_service.dart';
import 'tafseer_page_screen.dart';

class TafseerBookListScreen extends StatelessWidget {
  const TafseerBookListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<TafseerReadingModel> tafseerReadingList =
        TafseerReadingService().getTafseerList();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.translate.tafseer,
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
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView.separated(
                  itemBuilder: (context, index) {
                    TafseerReadingModel currentTafseer =
                        tafseerReadingList[index];
                    return InkWell(
                      onTap: () async {
                        TafseerPageCubitService().initAndLoadPage(
                          context,
                          tafseerCode: currentTafseer.tafseerCode,
                        );
                        pushSlide(
                          context,
                          screen: TafseerPageScreen(
                            tafseerCode: currentTafseer.tafseerCode,
                            tafseerBookName: context.translate.localeName ==
                                    AppStrings.arabicCode
                                ? currentTafseer.tafseerNameArabic
                                : currentTafseer.tafseerNameEnglish,
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
                          horizontal: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              width: 200,
                              height: 200,
                              currentTafseer.tafseerImage,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Text(
                              context.translate.localeName ==
                                      AppStrings.arabicCode
                                  ? currentTafseer.tafseerNameArabic
                                  : currentTafseer.tafseerNameEnglish,
                              style: TextStyle(
                                  fontSize: 20,
                                  color: currentTafseer.color,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(currentTafseer.tafseerDescription),
                            const SizedBox(
                              height: 20,
                            ),
                            Divider(
                              height: 1,
                              thickness: 4,
                              color: (context.isDarkMode &&
                                      currentTafseer.color == Colors.black)
                                  ? Colors.white
                                  : currentTafseer.color,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(
                      height: 0,
                    );
                  },
                  itemCount: tafseerReadingList.length,
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
