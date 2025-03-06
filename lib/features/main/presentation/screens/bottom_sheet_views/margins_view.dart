import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/screens/bottom_sheet_views/bookmarksview.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/screens/bottom_sheet_views/shwahid_view.dart';
import 'package:qeraat_moshaf_kwait/features/tenReadings/data/models/khelafia_word_model.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../../essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
import '../../../../qeerat/data/qeerat_service.dart';

class MarginsView extends StatefulWidget {
  const MarginsView({
    Key? key,
    this.withScaffold = true,
  }) : super(key: key);
  final bool withScaffold;

  @override
  State<MarginsView> createState() => _MarginsViewState();
}

class _MarginsViewState extends State<MarginsView> {
  List<HwamishModel> currentHawameshModelsListToShow = [];

  @override
  void initState() {
    super.initState();
    _hwamishModelToShow();
  }

  Future<void> _hwamishModelToShow() async {
    int currentPage = EssentialMoshafCubit.get(context).currentPage;
    List<HwamishModel> hawameshToShow = await QeeratService.getQeeratPageJson(
        currentPage + 1, QeeratState.hawamesh) as List<HwamishModel>;

    currentHawameshModelsListToShow = hawameshToShow;
    setState(() {});
  }

  Widget _extendedBodyDisplay(HwamishModel currrentHamishModel) {
    return Container(
      padding: (!widget.withScaffold)
          ? const EdgeInsets.symmetric(horizontal: 15)
          : EdgeInsets.zero,
      margin: const EdgeInsets.symmetric(vertical: 3),
      child: RichText(
          text: TextSpan(children: [
        for (CharPropertiesModel singleChar in currrentHamishModel.hamishLine!)
          TextSpan(
              text:
                  "${addTapOrNewLine(singleChar)}${singleChar.unicode == ':' ? '\n' : ''}",
              style: TextStyle(
                fontFamily: singleChar.fontFamily,
                fontWeight: singleChar.getFontWeight(),
                fontSize: singleChar.size! * 1.5,
                color: context.isDarkMode
                    ? Colors.white
                    : singleChar.color!.getColor(),
              ))
      ])),
    );
  }

  Widget _bodyDisplay() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: currentHawameshModelsListToShow.isNotEmpty
          ? (widget.withScaffold)
              ? ListView.builder(
                  physics: widget.withScaffold
                      ? const ClampingScrollPhysics()
                      : const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(10),
                  itemCount: currentHawameshModelsListToShow != null
                      ? currentHawameshModelsListToShow.length
                      : 0,
                  itemBuilder: (context, index) {
                    var currrentHamishModel =
                        currentHawameshModelsListToShow[index];
                    return _extendedBodyDisplay(currrentHamishModel);
                  })
              : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    for (var currrentHamishModel
                        in currentHawameshModelsListToShow)
                      _extendedBodyDisplay(currrentHamishModel),
                  ],
                )
          : CenteredEmptyListMsgWidget(
              msg: context.translate.no_hwamish_in_this_page),
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
}
