import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/enums/moshaf_type_enum.dart';
import 'package:qeraat_moshaf_kwait/core/responsiveness/responsive_framework_helper.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_colors.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_strings.dart';
import 'package:qeraat_moshaf_kwait/features/ayatHighlight/presentation/cubit/ayathighlight_cubit.dart' show AyatHighlightCubit, AyatHighlightState;
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart' show EssentialMoshafCubit;
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/zoom_cubit/zoom_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/widgets/bottom_widget_bloc_wrapped_quran_page_widget.dart';
import 'package:qeraat_moshaf_kwait/features/tenReadings/data/models/khelafia_word_model.dart';
import 'package:qeraat_moshaf_kwait/features/tenReadings/presentation/cubit/tenreadings_cubit.dart';

class QuranPageWidget extends StatefulWidget {
  const QuranPageWidget({
    Key? key,
    required this.index,
    required this.actualWidth,
    required this.actualHeight,
    required this.leftPadding,
    required this.rightPadding,
    required this.isOpened,
    required this.isZooming,
  }) : super(key: key);

  final int index;
  final double actualWidth;
  final double actualHeight;
  final double rightPadding;
  final double leftPadding;
  final bool isOpened, isZooming;

  @override
  State<QuranPageWidget> createState() => _QuranPageWidgetState();
}

class _QuranPageWidgetState extends State<QuranPageWidget> {
  File? lastPageImage;

  List<KhelafiaWordModel>? wordsToHighlight = [];

  bool blockScroll = false;

  Color? _getColor(BuildContext context) {
    if (context.theme.brightness == Brightness.dark) {
      return Colors.white;
    } else {
      return AppColors.primary;
    }
  }

  Color? _getIconColor(BuildContext context) {
    if (context.theme.brightness == Brightness.dark) {
      return Colors.black;
    } else {
      return Colors.white;
    }
  }

  Widget zoomIcon() {
    return Padding(
      padding: const EdgeInsets.only(top: 25.0),
      child: CircleAvatar(
        backgroundColor: _getColor(context),
        child: Icon(
          Icons.zoom_in,
          color: _getIconColor(context),
          size: 25,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AyatHighlightCubit, AyatHighlightState>(builder: (context, state) {
      return BlocBuilder<ZoomCubit, ZoomState>(
        builder: (context, zoomCubitState) {
          print(MediaQuery.of(context).size.height);
          print(ResponsiveFrameworkHelper().getResponsiveEnumStatus());
          print(widget.actualHeight);
          return SizedBox(
            height: ResponsiveFrameworkHelper().getHeightByCurrentEnum(
              context,
              zoomCubitState.zoomPercentage,
              customHeightForMobilePortrait: widget.actualHeight,
            ),
            width: MediaQuery.of(context).size.width,
            child: BottomWidgetBlocWrappedQuranPageWidget(
              isOpened: widget.isOpened,
              actualHeight: ResponsiveFrameworkHelper().getHeightByCurrentEnum(
                context,
                zoomCubitState.zoomPercentage,
                customHeightForMobilePortrait: widget.actualHeight,
              ),
              actualWidth: widget.actualWidth,
            ),
          );
        },
      );
    });
  }

  bool checkScreen(BuildContext context, TenReadingsCubit tenCubit, TenReadingsState tenState2) {
    final moshafType = context.read<EssentialMoshafCubit>().currentMoshafType;
    final isColoredPageExists = File("${tenCubit.coloredImagesSubFolderPath}${AppStrings.getColoredImageFileName(widget.index + 1)}").existsSync();
    return (moshafType == MoshafTypes.TEN_READINGS && ((tenCubit.coloredImagesSubFolderPath.isNotEmpty && isColoredPageExists) || tenState2 is TenreadingsServicesLoaded));
  }
}
