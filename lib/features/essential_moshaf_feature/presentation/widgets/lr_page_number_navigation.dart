import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/responsiveness/responsive_framework_helper.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_colors.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_strings.dart';
import 'package:qeraat_moshaf_kwait/core/utils/encode_arabic_digits.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart'
    show EssentialMoshafCubit, EssentialMoshafState;

class RightAndLeftPageIndicator extends StatelessWidget {
  const RightAndLeftPageIndicator({
    Key? key,
    required this.rightPage,
  }) : super(key: key);
  final int rightPage;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EssentialMoshafCubit, EssentialMoshafState>(
      builder: (context, state) {
        int currantPage = 0;
        bool isTwoPaged = ResponsiveFrameworkHelper().isTwoPaged();
        if (isTwoPaged) {
          currantPage = (EssentialMoshafCubit.get(context).currentPage * 2);
        } else {
          currantPage = EssentialMoshafCubit.get(context).currentPage;
        }
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 9),
          child: SizedBox(
            width: 60,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 30,
                  width: 58,
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
                            if (isTwoPaged) {
                              int newC = (c / 2).floor();
                              if (c % 2 != 0) {
                                newC = newC + 1;
                              }
                              EssentialMoshafCubit.get(context)
                                  .navigateToPage(newC);
                            } else {
                              EssentialMoshafCubit.get(context)
                                  .navigateToPage(c);
                            }
                          },
                          child: Container(
                            width: 20,
                            height: 30,
                            decoration: BoxDecoration(
                                color: (isTwoPaged &&
                                            (currantPage == c - 1 ||
                                                currantPage + 1 == c - 1)) ||
                                        (!isTwoPaged && currantPage == c - 1)
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
                                      margin: const EdgeInsets.symmetric(
                                          vertical: 2),
                                      height: 1.5,
                                      width: 12,
                                      color: (isTwoPaged &&
                                                  (currantPage == c - 1 ||
                                                      currantPage + 1 ==
                                                          c - 1)) ||
                                              (!isTwoPaged &&
                                                  currantPage == c - 1)
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
                    // for (int page in [rightPage, rightPage + 1])
                    Text(encodeToArabicNumbers(inputInteger: rightPage),
                        // encodeToArabicNumbers(inputInteger: page),
                        style: context.textTheme.bodySmall!.copyWith(
                          color: (isTwoPaged &&
                                      (rightPage == currantPage + 1 ||
                                          rightPage == currantPage + 2)) ||
                                  (!isTwoPaged &&
                                      (rightPage == currantPage + 1))
                              ? (context.isDarkMode
                                  ? Colors.white
                                  : AppColors.inactiveColor)
                              : (context.isDarkMode
                                  ? Colors.grey
                                  : AppColors.hintColor),
                          fontSize: 14,
                          fontFamily: AppStrings.amiriFontFamily,
                        ) //uthmanyFontFamily),
                        ),
                    Container(
                        height: 12,
                        width: 1,
                        color: (isTwoPaged &&
                                (rightPage + 1 == currantPage + 1 ||
                                    rightPage + 1 == currantPage + 2))
                            ? (context.isDarkMode
                                ? Colors.white
                                : AppColors.inactiveColor)
                            : (context.isDarkMode
                                ? Colors.grey
                                : AppColors.hintColor)),
                    Text(encodeToArabicNumbers(inputInteger: rightPage + 1),
                        // encodeToArabicNumbers(inputInteger: page),
                        style: context.textTheme.bodySmall!.copyWith(
                          color: (isTwoPaged &&
                                      (rightPage + 1 == currantPage + 1 ||
                                          rightPage + 1 == currantPage + 2)) ||
                                  (!isTwoPaged &&
                                      (rightPage + 1 == currantPage + 1))
                              ? (context.isDarkMode
                                  ? Colors.white
                                  : AppColors.inactiveColor)
                              : (context.isDarkMode
                                  ? Colors.grey
                                  : AppColors.hintColor),
                          fontSize: 14,
                          fontFamily: AppStrings.amiriFontFamily,
                        ) //uthmanyFontFamily),
                        ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
