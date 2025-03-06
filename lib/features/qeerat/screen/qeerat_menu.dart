import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_colors.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_strings.dart';
import 'package:qeraat_moshaf_kwait/core/utils/constants.dart';
import 'package:qeraat_moshaf_kwait/core/widgets/custom_switch_list_tile.dart';
import 'package:qeraat_moshaf_kwait/features/qeerat/cubit/qeera_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/qeerat/data/qeerat_naration_data.dart';

// Define a reusable TextStyle

class QeraatMenuScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("عرض القراءات العشر"),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // "All" toggle at the top
            BlocBuilder<QeraatCubit, List<QaraaStruct>>(
              builder: (context, qaraaList) {
                final allToggle = qaraaList.every((qaraa) => qaraa.isEnabled);

                return Card(
                  margin: const EdgeInsets.all(8),
                  clipBehavior: Clip.antiAlias,
                  color: context.theme.dialogBackgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: const BorderRadius.all(Radius.circular(15)),
                    side: BorderSide(
                        color: AppColors.border,
                        width: context.theme.brightness == Brightness.dark
                            ? 0.0
                            : 1.5),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: CustomSwitchListTile(
                      fontFamily: AppStrings.cairoFontFamily,
                      fontSize: 20,
                      title: "الكل",
                      value: allToggle,
                      onChanged: (value) {
                        context.read<QeraatCubit>().toggleAll(value);
                      },
                    ),
                  ),
                );
              },
            ),
            Expanded(
              child: BlocBuilder<QeraatCubit, List<QaraaStruct>>(
                builder: (context, qaraaList) {
                  return ListView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(16.0),
                    itemCount: qaraaList.length,
                    itemBuilder: (context, index) {
                      final qaraa = qaraaList[index];
                      return QeeatNarationSection(
                        qaraa: qaraa,
                        onQaraaChanged: (newValue) {
                          context
                              .read<QeraatCubit>()
                              .toggleQaraa(index, newValue);
                        },
                        onImam1Changed: (newValue) {
                          context
                              .read<QeraatCubit>()
                              .toggleImam1(index, newValue);
                        },
                        onImam2Changed: (newValue) {
                          context
                              .read<QeraatCubit>()
                              .toggleImam2(index, newValue);
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QeeatNarationSection extends StatefulWidget {
  QaraaStruct qaraa;
  Function(bool) onQaraaChanged;
  Function(bool) onImam1Changed;
  Function(bool) onImam2Changed;
  QeeatNarationSection({
    super.key,
    required this.qaraa,
    required this.onQaraaChanged,
    required this.onImam1Changed,
    required this.onImam2Changed,
  });

  @override
  State<QeeatNarationSection> createState() => _QeeatNarationSectionState();
}

class _QeeatNarationSectionState extends State<QeeatNarationSection> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 20),
      child: Column(
        children: [
          CustomSwitchListTile(
            fontFamily: AppStrings.cairoFontFamily,
            fontSize: 17,
            title: widget.qaraa.name,
            value: widget.qaraa.imam2.ThisHafs ? true : widget.qaraa.isEnabled,
            onChanged: widget.onQaraaChanged,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              margin: const EdgeInsets.all(8),
              clipBehavior: Clip.antiAlias,
              color: context.theme.cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                side: BorderSide(
                    color: AppColors.border,
                    width: context.theme.brightness == Brightness.dark
                        ? 0.0
                        : 1.5),
              ),
              child: Column(
                children: [
                  CustomSwitchListTile(
                    fontFamily: AppStrings.cairoFontFamily,
                    title: widget.qaraa.imam1.name,
                    value: widget.qaraa.imam1.isEnabled,
                    onChanged: widget.onImam1Changed,
                  ),
                  CustomSwitchListTile(
                    fontFamily: AppStrings.cairoFontFamily,
                    title: widget.qaraa.imam2.name,
                    value: widget.qaraa.imam2.ThisHafs
                        ? true
                        : widget.qaraa.imam2.isEnabled,
                    onChanged: widget.onImam2Changed,
                  ),
                ],
              ),
            ),
          ),
          AppConstants.appDivider(context, endIndent: 20, indent: 20)
        ],
      ),
    );
  }
}
