import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/constants.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/assets_manager.dart';
import '../../../essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
import '../widgets/fihris_list_views.dart';

enum FihrisTypes { SWAR, AJZAA, AHZAB }

const double borderRadius = 25.0;

class FihrisScreen extends StatefulWidget {
  const FihrisScreen({
    Key? key,
    this.fromDialog = false,
    this.onTapFihrisItem,
    this.activePageIndex = 0,
  }) : super(key: key);
  final bool fromDialog;
  final Function(int)? onTapFihrisItem;
  final int activePageIndex;
  @override
  _FihrisScreenState createState() => _FihrisScreenState();
}

class _FihrisScreenState extends State<FihrisScreen>
    with SingleTickerProviderStateMixin {
  late PageController _fihrisPageController;
  int activePageIndex = 0;

  @override
  void dispose() {
    _fihrisPageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _fihrisPageController = PageController();
    activePageIndex = widget.activePageIndex;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.activePageIndex != 0) {
        _onHeaderCategoryTap(widget.activePageIndex);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> fihrisTypesViews = [
      SwarList(
        onTapFihrisItem: widget.onTapFihrisItem,
      ),
      AjzaaList(
        onTapFihrisItem: widget.onTapFihrisItem,
      ),
      AhzabList(
        onTapFihrisItem: widget.onTapFihrisItem,
      )
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.translate.quuarn_fihris,
        ),

        // title: Text(context.translate.quuarn_fihris),
        // leading: AppConstants.customBackButton(context, onPressed: () {
        //   EssentialMoshafCubit.get(context).toggleRootView();
        // }),
        leading: AppConstants.customBackButton(
          context,
          customIcon: Icons.close,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
              image: context.isDarkMode
                  ? null
                  : const DecorationImage(
                      image: AssetImage(AppAssets.pattern), fit: BoxFit.cover)),
        ),
      ),
      body: BlocListener<EssentialMoshafCubit, EssentialMoshafState>(
        listener: (context, state) {
          if (state is ChangeFihrisIndex) {
            _onHeaderCategoryTap(state.viewIndex);
          }
        },
        child: SafeArea(
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              Container(),
              GestureDetector(
                onTap: () {
                  FocusScope.of(context).requestFocus(FocusNode());
                },
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: _fihrisTypesMenuBar(context),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _fihrisPageController,
                        physics: const ClampingScrollPhysics(),
                        onPageChanged: (int i) {
                          FocusScope.of(context).requestFocus(FocusNode());
                          setState(() => activePageIndex = i);
                        },
                        itemBuilder: (context, index) =>
                            fihrisTypesViews[index],
                        itemCount: fihrisTypesViews.length,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _fihrisTypesMenuBar(BuildContext context) {
    return Container(
      // margin: EdgeInsets.symmetric(horizontal: 30),
      padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 5),
      // alignment: Alignment.center,
      decoration: BoxDecoration(
          border: Border.all(
              color: (context.theme.brightness == Brightness.dark
                  ? AppColors.scaffoldBgDark
                  : AppColors.border),
              width: (context.theme.brightness == Brightness.dark ? 0.0 : 1.0)),
          color: context.theme.brightness == Brightness.dark
              ? context.theme.cardColor
              : AppColors.tabBackground,
          borderRadius: BorderRadius.circular(30)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          headerItem(context, index: 0, title: context.translate.the_surah),
          headerItem(context, index: 1, title: context.translate.the_juz),
          headerItem(context, index: 2, title: context.translate.the_hizb),
        ],
      ),
    );
  }

  Widget headerItem(BuildContext context,
      {required String title, required int index}) {
    return InkWell(
      onTap: () {
        _onHeaderCategoryTap(index);
      },
      child: Container(
        height: 25,
        padding: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
            color: (activePageIndex == index)
                ? (context.theme.brightness == Brightness.dark
                    ? AppColors.activeTypeBgDark
                    : Colors.black)
                : (context.theme.brightness == Brightness.dark
                    ? context.theme.cardColor
                    : AppColors.tabBackground),
            borderRadius: BorderRadius.circular(30)),
        child: Center(
          child: Text(
            title,
            style: context.textTheme.bodyMedium!.copyWith(
              fontSize: 13,
              color: activePageIndex == index
                  ? AppColors.white
                  : (context.theme.brightness == Brightness.dark
                      ? AppColors.border
                      : AppColors.inactiveColor),
            ),
            // style: (activePageIndex == index)
            //     ? TextStyle(color: AppColors.white, fontSize: 13)
            //     : TextStyle(color: AppColors.inactiveColor, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  void _onHeaderCategoryTap(int page) {
    //todo: what is the hill!!
    _fihrisPageController.animateToPage(page,
        duration: const Duration(microseconds: 1000), curve: Curves.decelerate);
  }
}
