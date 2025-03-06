import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/screens/bottom_sheet_views/bookmarksview.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/screens/bottom_sheet_views/shwahid_view.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
import '../../../../qeerat/data/qeerat_service.dart';
import '../../../../tenReadings/data/models/khelafia_word_model.dart';
import '../../../../tenReadings/presentation/cubit/tenreadings_cubit.dart';

class OsoulView extends StatefulWidget {
  const OsoulView({
    Key? key,
    this.withScaffold = true,
  }) : super(key: key);
  final bool withScaffold;

  @override
  State<OsoulView> createState() => _OsoulViewState();
}

class _OsoulViewState extends State<OsoulView> {
  List<OsoulModel> currentOsoulModelsListToShow = [];

  @override
  void initState() {
    super.initState();
    _oSoulToShow();
  }

  Future<void> _oSoulToShow() async {
    int currentPage = EssentialMoshafCubit.get(context).currentPage;
    List<OsoulModel> oSoulToShow = await QeeratService.getQeeratPageJson(
        currentPage + 1, QeeratState.osoul) as List<OsoulModel>;

    currentOsoulModelsListToShow = oSoulToShow;
    setState(() {});
  }

  Widget _extendedBodyDisplay() {
    return Card(
        color: context.theme.brightness == Brightness.dark
            ? AppColors.osoulCellBgDark
            : AppColors.tabBackground,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          //outer border for the table
          side: BorderSide(
            width: 1.0,
            color: context.theme.brightness == Brightness.dark
                ? Colors.grey
                : AppColors.inactiveColor,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var osoulItemModel in currentOsoulModelsListToShow)
              Container(
                decoration: BoxDecoration(
                  //topbottom border for cells
                  border: Border.symmetric(
                      horizontal: BorderSide(
                    width: 0.5,
                    color: context.theme.brightness == Brightness.dark
                        ? Colors.grey
                        : AppColors.inactiveColor,
                  )),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        // width: context.width * 0.3,
                        padding: const EdgeInsets.symmetric(
                            vertical: 7, horizontal: 10),

                        //todo: right section here
                        child: RichText(
                            text: TextSpan(children: [
                          for (var singleChar in osoulItemModel.keyChars!)
                            if (singleChar.unicode != null)
                              TextSpan(
                                  text: addTapOrNewLine(singleChar),
                                  style: TextStyle(
                                    fontFamily: singleChar.fontFamily,
                                    fontWeight: singleChar.getFontWeight(),
                                    fontSize: singleChar.size! * 1.5,
                                    color: context.isDarkMode
                                        ? Colors.white
                                        : singleChar.color!.getColor(),
                                  ))
                        ])),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 7, horizontal: 10),
                        decoration:
                            _buildCellBorder(context, isRightBorder: true),
                        //todo: left section
                        child: RichText(
                            text: TextSpan(children: [
                          for (var singleChar in osoulItemModel.valueChars!)
                            if (singleChar.unicode != null)
                              TextSpan(
                                  text: addTapOrNewLine(singleChar),
                                  style: TextStyle(
                                    fontFamily: singleChar.fontFamily,
                                    fontWeight: singleChar.getFontWeight(),
                                    fontSize: singleChar.size! * 1.5,
                                    color: context.isDarkMode
                                        ? Colors.white
                                        : singleChar.color!.getColor(),
                                  ))
                        ])),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ));
  }

  Widget _bodyDisplay() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: currentOsoulModelsListToShow.isNotEmpty
          ? (widget.withScaffold)
              ? Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    // const ViewDashIndicator(),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: widget.withScaffold
                            ? const ClampingScrollPhysics()
                            : const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(10),
                        child: _extendedBodyDisplay(),
                      ),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.all(10),
                  child: _extendedBodyDisplay(),
                )
          : CenteredEmptyListMsgWidget(
              msg: context.translate.no_osoul_in_this_page),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.withScaffold) {
      return Scaffold(
        body: _bodyDisplay(),
      );
    } else {
      return _bodyDisplay();
    }
  }

  BoxDecoration _buildCellBorder(BuildContext context,
      {bool isRightBorder = false}) {
    return BoxDecoration(
      border: Border(
        left: isRightBorder
            ? BorderSide.none
            : BorderSide(
                width: 1.0,
                color: context.theme.brightness == Brightness.dark
                    ? Colors.grey
                    : AppColors.inactiveColor,
              ),
        right: isRightBorder
            ? BorderSide(
                width: 1.0,
                color: context.theme.brightness == Brightness.dark
                    ? Colors.grey
                    : AppColors.inactiveColor,
              )
            : BorderSide.none,
      ),
    );
  }
}

class EmptyViewWidget extends StatelessWidget {
  const EmptyViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        icon: const Icon(
          Icons.refresh,
          size: 35,
        ),
        onPressed: () {
          context
              .read<TenReadingsCubit>()
              .readDownloadedJsonFilesForCurrrentPage();
        },
      ),
    );
  }
}
