import 'package:flutter/material.dart';

import '../../../../core/utils/constants.dart';
import '../screens/quran_fihris_screen.dart';
import 'fihris_list_view_items.dart';

class FihrisListBody extends StatefulWidget {
  final List<dynamic> fihrisItems;

  final FihrisTypes fihrisType;
  const FihrisListBody({
    Key? key,
    required this.fihrisItems,
    required this.fihrisType,
    this.onTapFihrisItem,
  }) : super(key: key);
  final Function(int)? onTapFihrisItem;
  @override
  State<FihrisListBody> createState() => _FihrisListBodyState();
}

class _FihrisListBodyState extends State<FihrisListBody>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          separatorBuilder: ((context, index) =>
              AppConstants.appDivider(context)),
          physics: const ClampingScrollPhysics(),
          itemCount: widget.fihrisItems.length,
          itemBuilder: ((context, index) {
            return widget.fihrisType == FihrisTypes.SWAR
                ? SurahListViewItem(
                    surahFihrisModel: widget.fihrisItems[index],
                    onTapFihrisItem: widget.onTapFihrisItem,
                  )
                : widget.fihrisType == FihrisTypes.AJZAA
                    ? JuzListViewItem(
                        juzFihrisModel: widget.fihrisItems[index],
                        onTapFihrisItem: widget.onTapFihrisItem,
                      )
                    : HizbListViewItem(
                        hizbFihrisModel: widget.fihrisItems[index],
                        onTapFihrisItem: widget.onTapFihrisItem,
                      );
          })),
    );
  }
}
