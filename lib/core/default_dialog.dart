import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_colors.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_strings.dart';
import 'package:qeraat_moshaf_kwait/core/utils/mediaquery_values.dart';

showDefaultDialog(BuildContext context,
    {String? title,
    String? leadingTitleIcon,
    VoidCallback? leadingTitleFunction,
    double leadingTitleIconSize = 25,
    String btntext = "save",
    double? titleFontSize,
    FontWeight? titleFontWeight,
    bool withSaveButton = true,
    bool barrierDismissible = true,
    VoidCallback? onSaved,
    Future<bool> Function()? onDialogDismissed,
    ShapeBorder? shapeBorder,
    bool dialogPaddingNull = false,
    Widget? content}) {
  showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      barrierDismissible: barrierDismissible,
      builder: (ctx) {
        return WillPopScope(
          onWillPop: onDialogDismissed ?? () async => true,
          child: Center(
            child: Dialog(
              shape: shapeBorder,
              insetAnimationCurve: Curves.easeOut,
              insetPadding: context.isLandscape
                  ? const EdgeInsets.symmetric(horizontal: 50, vertical: 20)
                  : const EdgeInsets.all(18),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: dialogPaddingNull ? null : const EdgeInsets.all(16),
                  // margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(shapeBorder != null ? 20 : 9),
                    color: context.theme.brightness == Brightness.dark
                        ? AppColors.scaffoldBgDark
                        : AppColors.tabBackground,
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (title != null)
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                child: const Padding(
                                  padding: EdgeInsets.only(bottom: 20.0),
                                  child: Icon(
                                    Icons.close,
                                    size: 30,
                                  ),
                                ),
                              ),
                              if (leadingTitleIcon != null)
                                const SizedBox(
                                  width: 20,
                                ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: 20,
                                  ),
                                  child: Text(
                                    title,
                                    textAlign: TextAlign.center,
                                    style: context.textTheme.bodyMedium!
                                        .copyWith(
                                            fontSize: titleFontSize ?? 16,
                                            fontWeight: titleFontWeight ??
                                                FontWeight.bold),
                                  ),
                                ),
                              ),
                              if (leadingTitleIcon != null)
                                InkWell(
                                  onTap: leadingTitleFunction,
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      bottom: 20,
                                    ),
                                    child: SvgPicture.asset(
                                      leadingTitleIcon,
                                      height: leadingTitleIconSize,
                                      color: context.theme.brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : AppColors.inactiveColor,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        if (content != null) content,
                        if (withSaveButton)
                          SizedBox(
                            width: context.width,
                            child: ElevatedButton(
                              onPressed: onSaved,
                              style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: context
                                      .theme
                                      .elevatedButtonTheme
                                      .style!
                                      .backgroundColor!
                                      .resolve({})!,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12))),
                              child: Text(
                                btntext,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: context.theme.elevatedButtonTheme
                                      .style!.textStyle!
                                      .resolve({})!.color,
                                  fontFamily: AppStrings.cairoFontFamily,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      });
}
