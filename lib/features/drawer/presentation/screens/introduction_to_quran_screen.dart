import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/mediaquery_values.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/assets_manager.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/encode_arabic_digits.dart';

class IntroductionToQuranScreen extends StatefulWidget {
  const IntroductionToQuranScreen({super.key});

  @override
  State<IntroductionToQuranScreen> createState() =>
      _IntroductionToQuranScreenState();
}

class _IntroductionToQuranScreenState extends State<IntroductionToQuranScreen> {
  final GlobalKey pageViewKey = GlobalKey();

  PageController introductionPageController = PageController();

  ScrollController scrollController = ScrollController();
  int currentPageIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: AppConstants.customBackButton(context),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              image: context.isDarkMode
                  ? null
                  : const DecorationImage(
                      image: AssetImage(AppAssets.pattern), fit: BoxFit.cover)),
        ),
        title: Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ThemeData().colorScheme.copyWith(
                  primary: Colors.black,
                ),
          ),
          child: Text(context.translate.introduction_to_holy_quran),
        ),
        toolbarHeight: 80,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                key: pageViewKey,
                controller: introductionPageController,
                itemCount: 12,
                onPageChanged: (index) async {
                  setState(() {
                    currentPageIndex = index;
                  });
                },
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Image.asset(
                      AppAssets.getMoshafInformationPage(index + 1),
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ),
            AnimatedContainer(
              duration: AppConstants.enteringAnimationDuration,
              curve: Curves.easeOut,
              height: 100.0,
              width: context.width,
              padding: const EdgeInsets.symmetric(
                vertical: 15,
              ),
              color: context.isDarkMode
                  ? AppColors.cardBgDark
                  : AppColors.lightGrey,
              child: ListView.builder(
                itemCount: 12,
                scrollDirection: Axis.horizontal,
                controller: scrollController,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      right: index == 0 ? 30.0 : 6.0,
                      left: index == 11 ? 30.0 : 6.0,
                      top: 5.0,
                      bottom: 5.0,
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          introductionPageController.animateToPage(
                            index - 1,
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                          );
                        });
                      },
                      child: Image.asset(
                        AppAssets.getMoshafInformationPage(index + 1),
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                  // final rightPage = index * 2 + 1;
                  // return _StaticRightAndLeftPageIndicator(
                  //     currentPage: currentPageIndex,
                  //     rightPage: rightPage,
                  //     pageNavigation: (int index) {
                  //       setState(() {
                  //         introductionPageController.animateToPage(
                  //           index - 1,
                  //           duration: const Duration(milliseconds: 250),
                  //           curve: Curves.easeInOut,
                  //         );
                  //       });
                  //     });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StaticRightAndLeftPageIndicator extends StatelessWidget {
  const _StaticRightAndLeftPageIndicator({
    Key? key,
    required this.currentPage,
    required this.rightPage,
    required this.pageNavigation,
  }) : super(key: key);
  final int rightPage, currentPage;
  final Function(int) pageNavigation;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 37,
              width: 64,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: context.isDarkMode
                    ? AppColors.scaffoldBgDark
                    : AppColors.lightBrown,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  //* page widget
                  for (int c in [rightPage, rightPage + 1])
                    InkWell(
                      onTap: () {
                        pageNavigation(c);
                      },
                      child: Container(
                        width: 20,
                        height: 30,
                        decoration: BoxDecoration(
                            color: currentPage == c - 1
                                ? context.isDarkMode
                                    ? AppColors.white
                                    : AppColors.inactiveColor
                                : context.isDarkMode
                                    ? const Color(0xff423E3E)
                                    : Colors.white,
                            borderRadius: BorderRadius.circular(3),
                            border: Border.all(
                                color: context.isDarkMode
                                    ? AppColors.white
                                    : AppColors.border,
                                width: 1)),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (int i = 1; i <= 3; i++)
                                Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 2),
                                  height: 1.5,
                                  width: 12,
                                  color: currentPage == c - 1
                                      ? context.isDarkMode
                                          ? AppColors.activeButtonColor
                                          : AppColors.border
                                      : context.isDarkMode
                                          ? AppColors.white
                                          : AppColors.border,
                                )
                            ],
                          ),
                        ),
                      ),
                    )
                ],
              ),
            ),

            //*the two numbers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                for (int page in [rightPage, rightPage + 1])
                  Text(
                    encodeToArabicNumbers(inputInteger: page),
                    // encodeToArabicNumbers(inputInteger: page),
                    style: context.textTheme.bodySmall!.copyWith(
                      color: (page == currentPage + 1)
                          ? (context.isDarkMode
                              ? Colors.white
                              : AppColors.inactiveColor)
                          : (context.isDarkMode
                              ? Colors.grey
                              : AppColors.hintColor),
                      fontSize: 16,
                      fontFamily: AppStrings.amiriFontFamily,
                    ), //uthmanyFontFamily),
                  ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
