import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/constants.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/screens/bottom_sheet_views/bookmarksview.dart';
import 'package:qeraat_moshaf_kwait/features/tenReadings/data/models/khelafia_word_model.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../../essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
import '../../../../qeerat/data/qeerat_service.dart';

class ShwahidView extends StatefulWidget {
  const ShwahidView({
    Key? key,
    this.withScaffold = true,
  }) : super(key: key);
  final bool withScaffold;

  @override
  State<ShwahidView> createState() => _ShwahidViewState();
}

class _ShwahidViewState extends State<ShwahidView> {
  List<ShwahidDalalatGroupModel> currentShwahidModelsListToShow = [];

  @override
  void initState() {
    super.initState();
    _shawahidToShow();
  }

  Future<void> _shawahidToShow() async {
    int currentPage = EssentialMoshafCubit.get(context).currentPage;
    List<ShwahidDalalatGroupModel> shawahidToShow =
        await QeeratService.getQeeratPageJson(
                currentPage + 1, QeeratState.shawahed)
            as List<ShwahidDalalatGroupModel>;

    currentShwahidModelsListToShow = shawahidToShow;
    setState(() {});
  }

  Widget _bodyDisplay() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: currentShwahidModelsListToShow.isNotEmpty
          ? ListView.separated(
              physics: widget.withScaffold
                  ? const ClampingScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(10),
              separatorBuilder: (context, index) {
                return AppConstants.appDivider(context);
              },
              itemCount: currentShwahidModelsListToShow.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return ShwahidDalalatWidget(
                    shahidDalalahItem: currentShwahidModelsListToShow[index]);
              })
          : CenteredEmptyListMsgWidget(
              msg: context.translate.no_shwahid_in_this_page),
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

class ShwahidDalalatWidget extends StatelessWidget {
  const ShwahidDalalatWidget({
    Key? key,
    required this.shahidDalalahItem,
  }) : super(key: key);
  final ShwahidDalalatGroupModel shahidDalalahItem;

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            //todo: shahid is here
            for (var linePhrase in shahidDalalahItem.shahedChars!)
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: RichText(
                        text: TextSpan(children: [
                      for (var singleChar in linePhrase)
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
                ],
              ),

            //todo: dalalat lines here

            for (var linePhrase in shahidDalalahItem.daleelChars!)
              Column(
                children: [
                  const SizedBox(height: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: RichText(
                            text: TextSpan(children: [
                          for (var singleChar in linePhrase)
                            // for (CharPropertiesModel singleChar
                            //     in singleShahidLine.dalalat!)
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
                    ],
                  ),
                ],
              ),
          ],
        ));
  }
}

String addTapOrNewLine(CharPropertiesModel charModel) {
  String? originalUnicode = charModel.unicode;
  if (originalUnicode == null) {
    return '';
  } else {
    if (charModel.addTab == true) {
      originalUnicode = '\t$originalUnicode';
    }
    if (charModel.isNewLine == true) {
      originalUnicode = '\n$originalUnicode';
    }
    return originalUnicode;
  }
}
