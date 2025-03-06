import 'dart:developer';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/enums/moshaf_type_enum.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_strings.dart';
import 'package:qeraat_moshaf_kwait/core/utils/assets_manager.dart';
import 'package:qeraat_moshaf_kwait/features/bookmarks/presentation/screens/theme_cubit.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../features/drawer/data/data_sources/drawer_constants.dart';
import '../../features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
import '../../features/essential_moshaf_feature/presentation/cubit/lang_cubit.dart';
import '../../features/tenReadings/presentation/cubit/tenreadings_cubit.dart';
import 'app_colors.dart';

class AppConstants {
  static final GlobalKey<ScaffoldState> moshafScaffoldKey =
      GlobalKey<ScaffoldState>();

  //* CONSTANT METHODS
  static Widget customBackButton(
    BuildContext context, {
    void Function()? onPressed,
    IconData? customIcon,
    Color? customIconColor,
    bool invertIconColors = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: IconButton(
        color: customIconColor ?? (invertIconColors ? Colors.white : null),
        onPressed: onPressed ?? () => Navigator.pop(context),
        icon: Icon(customIcon ?? Icons.arrow_back_ios),
      ),
    );
  }

  static Widget customHomeButton(
    BuildContext context, {
    void Function()? onPressed,
    bool doublePop = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed ??
            (doublePop
                ? () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  }
                : () => Navigator.of(context, rootNavigator: true).pop()),
        child: Padding(
            padding: EdgeInsets.only(
              left: LangCubit.get(context).currentLocale.languageCode ==
                      AppStrings.englishCode
                  ? 5
                  : 10.0,
              top: 10,
              bottom: 10,
              right: LangCubit.get(context).currentLocale.languageCode ==
                      AppStrings.englishCode
                  ? 10.0
                  : 5,
            ),
            child: SizedBox(
              height: 40,
              width: 40,
              child: Image.asset(
                DrawerConstants.drawerQuranIcon,
              ),
            )

            // SvgPicture.asset(
            //   AppAssets.fihrisActive,
            //   color: context.theme.primaryIconTheme.color,
            // ),
            ),
      ),
    );
  }

  static Future<bool> isDirectory(String path) => Directory(path).exists();
  static showConfirmationDialog(
    BuildContext context, {
    required String confirmMsg,
    void Function()? okCallback,
    void Function()? cancelCallback,
    bool withOkButton = true,
    Color? okButtonTextColor,
    Color? refuseButtonTextColor,
    String? refuseButtonText,
    String? acceptButtonText,
    List<Widget> additionalBtns = const [],
    Future<bool> Function()? onDialogDismissed,
  }) {
    showDialog(
      barrierColor: Colors.black.withOpacity(0.4),
      context: context,
      builder: (ctx) => WillPopScope(
        onWillPop: onDialogDismissed ?? () async => true,
        child: AlertDialog(
          backgroundColor: context.theme.dialogBackgroundColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
          content: Text(
            confirmMsg,
            style: context.textTheme.bodyMedium!
                .copyWith(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          actionsAlignment: MainAxisAlignment.start,
          actionsOverflowAlignment: OverflowBarAlignment.start,
          actions: <Widget>[
            ...additionalBtns,
            TextButton(
              onPressed: () {
                if (cancelCallback != null) {
                  cancelCallback();
                  log("CANCELLCALLBACK WAS TRIGGERRED!", name: "INFO");
                } else {
                  Navigator.pop(context);
                }
              },
              child: Text(
                refuseButtonText ?? context.translate.no,
                style: TextStyle(
                    color: refuseButtonTextColor ??
                        context.theme.textButtonTheme.style!.textStyle!
                            .resolve({})!.color,
                    fontWeight: FontWeight.bold),
              ),
            ),
            if (withOkButton)
              TextButton(
                onPressed: () {
                  if (okCallback != null) {
                    okCallback();
                    log("OKCALLBACK WAS TRIGGERRED!", name: "INFO");
                  } else {
                    Navigator.pop(context);
                  }
                },
                child: Text(
                  acceptButtonText ?? context.translate.yes,
                  style: TextStyle(
                      color: context.theme.textButtonTheme.style!.textStyle!
                          .resolve({})!.color,
                      fontWeight: FontWeight.bold),
                ),
              ),
          ].reversed.toList(),
        ),
      ),
    );
  }

  static Widget appDivider(
    BuildContext context, {
    double indent = 0,
    double endIndent = 0,
    Color? color,
    double? thickness,
  }) {
    return Divider(
      color: color ?? context.theme.dividerColor,
      thickness: 1.5,
      indent: indent,
      endIndent: endIndent,
      height: 0,
    );
  }

  static void showErrorDialog(
      {required BuildContext context, required String msg}) {
    showDialog(
        context: context,
        builder: (context) => CupertinoAlertDialog(
              title: Text(
                msg,
                style: const TextStyle(color: Colors.black, fontSize: 16),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                      foregroundColor: Colors.black,
                      textStyle: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.bold)),
                  child: const Text('Ok'),
                )
              ],
            ));
  }

  static showDarkThemeNotAvailableDialog(BuildContext context) {
    showConfirmationDialog(
      context,
      confirmMsg: context
          .translate.dark_mode_is_not_available_currently_for_tenreadings_mode,
      acceptButtonText: context.translate.continue_to_ten_readings,
      refuseButtonText: context.translate.cancel,
      okCallback: () {
        context
            .read<TenReadingsCubit>()
            .readDownloadedJsonFilesForCurrrentPage();

        EssentialMoshafCubit.get(context)
            .changeMoshafType(MoshafTypes.TEN_READINGS);
        context.read<ThemeCubit>().setCurrentTheme(1);
        Navigator.pop(context);
      },
    );
  }

  static void showToast(
    BuildContext context, {
    required String msg,
    Color? color,
    ToastGravity? gravity,
  }) {
    FToast fToast = FToast();
    fToast.init(context);
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
      margin: const EdgeInsets.symmetric(horizontal: 10.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50.0),
        color: context.isDarkMode ? Colors.white : AppColors.activeButtonColor,
      ),
      child: Text(
        msg,
        textDirection: context.translate.localeName == AppStrings.arabicCode
            ? TextDirection.rtl
            : TextDirection.ltr,
        style: TextStyle(
            color:
                context.isDarkMode ? AppColors.activeButtonColor : Colors.white,
            fontFamily: "",
            fontWeight: FontWeight.normal),
      ),
    );
    fToast.showToast(
      child: toast,
      gravity: ToastGravity.BOTTOM,
      toastDuration: const Duration(seconds: 5),
    );
  }

  //* CONSTANT ATTRIBUTES
  static const Duration enteringAnimationDuration = Duration(milliseconds: 375);

  static const double moshafPageAspectRatio = 1024 / 1656;
  static const double quranAndroidPageAspectRatio = 1352 / 2170;
  static const double clippedPortionFromQuranScreen = 85.72;
  static const int ayahNumberUnicodeStarter = 64511;

  static const List<String> juzQuartersIcons = [
    AppAssets.quarter_1,
    AppAssets.quarter_2,
    AppAssets.quarter_3,
    AppAssets.quarter_4,
    AppAssets.quarter_1,
    AppAssets.quarter_2,
    AppAssets.quarter_3,
    AppAssets.quarter_4,
  ];
}

class ListItemData {
  String? icon;
  void Function()? onPressed;
  String? name;
  bool? hasIcon, isSvg;
  String? image;
  String? subTitle;
  String? key;

  ListItemData({
    required this.icon,
    required this.name,
    this.hasIcon = false,
    this.isSvg = true,
    this.onPressed,
    this.subTitle = '',
    this.key,
  });

  ListItemData.icon({
    required this.icon,
    this.onPressed,
  });
  ListItemData.hasSubtitle({
    this.onPressed,
    required this.name,
    required this.subTitle,
    required this.icon,
  });
  ListItemData.onlyNameAndSubtitle({
    required this.name,
    required this.subTitle,
  });
  ListItemData.image({
    this.icon = AppAssets.backArrow,
    required this.image,
    required this.name,
    this.onPressed,
    this.isSvg = true,
  });
}

String formatDuration(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final hours = duration.inHours;
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));

  return hours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
}
