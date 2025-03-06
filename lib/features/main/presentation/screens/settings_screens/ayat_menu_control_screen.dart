// ayat menu
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/assets_manager.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/widgets/button_row_display.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
import '../../cubit/ayat_menu_control_cubit/ayat_menu_control_cubit.dart';
import '../../cubit/ayat_menu_control_cubit/ayat_menu_control_service.dart';

class AyatMenuControlScreen extends StatelessWidget {
  const AyatMenuControlScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(context.translate.ayat_interactive_menu),
          leading: AppConstants.customBackButton(context),
          actions: [
            AppConstants.customHomeButton(context, doublePop: true),
          ],
        ),
        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0.0, 16, 0.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        BlocBuilder<AyatMenuControlCubit, AyatMenuControlState>(
                          builder: (context, ayatMenuControlState) {
                            return _AyatMenuWidgetList(
                              groupTitle:
                                  context.translate.ayat_interactive_menu,
                              ayatMenuListData: _ayatMenuListTiles(context),
                              selectedMenu: ayatMenuControlState.selectedMenu,
                            );
                          },
                        ),
                        const SizedBox(),
                      ],
                    ),
                  ),
                ),
              )
            ]));
  }

  List<ListItemData> _ayatMenuListTiles(BuildContext context) {
    //* Menu Selections
    final ayatMenuList = [
      // Menu Expanded
      ListItemData(
        icon: AppAssets.expandedMenuIcon,
        name: context.translate.expanded,
        subTitle: context.translate.expanded_details,
        onPressed: () {
          AyatMenuControlService.setAyatMenu(
            context,
            menu: AyatMenu.expanded,
          );
        },
        key: AyatMenu.expanded.name,
      ),

      // Menu Compact
      ListItemData(
        icon: AppAssets.compactMenuIcon,
        name: context.translate.compact,
        subTitle: context.translate.compact_details,
        onPressed: () {
          AyatMenuControlService.setAyatMenu(
            context,
            menu: AyatMenu.compact,
          );
        },
        key: AyatMenu.compact.name,
      ),
      // If want to add a new menu add here
    ];
    return ayatMenuList;
  }
}

class _AyatMenuWidgetList extends StatelessWidget {
  const _AyatMenuWidgetList({
    required this.ayatMenuListData,
    required this.groupTitle,
    required this.selectedMenu,
    Key? key,
  }) : super(key: key);
  final List<ListItemData> ayatMenuListData;
  final String groupTitle;
  final AyatMenu selectedMenu;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 16, 15, 5),
          child: Text(
            groupTitle,
            style: context.textTheme.displayMedium,
          ),
        ),
        Card(
            clipBehavior: Clip.antiAlias,
            color: context.theme.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              side: BorderSide(
                  color: AppColors.border,
                  width:
                      context.theme.brightness == Brightness.dark ? 0.0 : 1.5),
            ),
            child: BlocBuilder<EssentialMoshafCubit, EssentialMoshafState>(
              builder: (context, state) {
                final stateIcon = EssentialMoshafCubit.get(context).stateIcon;
                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  separatorBuilder: (_, index) {
                    return stateIcon
                        ? const SizedBox()
                        : AppConstants.appDivider(context, indent: 40);
                  },
                  itemCount: ayatMenuListData.length,
                  itemBuilder: (_, index) {
                    return Opacity(
                      opacity: index == 2 &&
                              context
                                  .read<EssentialMoshafCubit>()
                                  .isInTenReadingsMode()
                          ? 0.4
                          : 1.0,
                      child: Padding(
                          padding: index != 1
                              ? const EdgeInsets.symmetric(
                                  horizontal: 5, vertical: 12)
                              : EdgeInsets.zero,
                          child: InkWell(
                            onTap: ayatMenuListData[index].onPressed,
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 20),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: index == 1
                                          ? const EdgeInsets.fromLTRB(
                                              5, 12, 5, 20)
                                          : EdgeInsets.zero,
                                      child: ButtonRowDisplay(
                                        icon: ayatMenuListData[index].icon!,
                                        title: ayatMenuListData[index].name!,
                                        height: 8,
                                        subtitle:
                                            ayatMenuListData[index].subTitle!,
                                        isChecked:
                                            (ayatMenuListData[index].key! ==
                                                selectedMenu.name),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )),
                    );
                  },
                );
              },
            )),
      ],
    );
  }
}
