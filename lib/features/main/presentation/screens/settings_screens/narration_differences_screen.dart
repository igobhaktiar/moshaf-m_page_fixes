import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/language_service.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../../../core/utils/app_colors.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../../core/widgets/custom_switch_list_tile.dart';

class NarrationDifferencesScreen extends StatelessWidget {
  const NarrationDifferencesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(context.translate.moshaf_narration_differences),
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
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: SingleChildScrollView(
                    child: Container(
                      child: Column(
                        children: [
                          NarrationDifferencesWidgetList(
                            groupTitle: context.translate.show_the_ten_readings,
                          ),
                          const SizedBox(),
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ]));
  }
}

class Narration {
  String arabic;
  String english;
  bool isSelected;

  Narration({
    required this.arabic,
    required this.english,
    required this.isSelected,
  });
}

class NarrationDifferencesWidgetList extends StatefulWidget {
  const NarrationDifferencesWidgetList({
    required this.groupTitle,
    Key? key,
  }) : super(key: key);

  final String groupTitle;

  @override
  State<NarrationDifferencesWidgetList> createState() =>
      _NarrationDifferencesWidgetListState();
}

class _NarrationDifferencesWidgetListState
    extends State<NarrationDifferencesWidgetList> {
  // List of narrations
  List<Narration> narrations = [
    Narration(
      english: "Qalun's narration from Nafi' Al-Madani",
      arabic: "رِوايَةُ قالون..عَنْ نَافِعِ المَدَنيّ",
      isSelected: false,
    ),
    Narration(
      english: "Warsh's narration from Nafi' Al-Madani",
      arabic: "رِوايَةُ ورش..عَنْ نَافِعِ المَدَنيّ",
      isSelected: false,
    ),
    Narration(
      english: "Al-Bazzi's narration from Ibn Kathir Al-Makki",
      arabic: "رِوايَةُ البَزّي.. عَنْ ابنِ كثيرِ المَكِّي",
      isSelected: false,
    ),
    Narration(
      english: "Qunbul's narration from Ibn Kathir Al-Makki",
      arabic: "رِوايَةُ قُنْبُل.. عَنْ ابنِ كثيرِ المَكِّي",
      isSelected: false,
    ),
    Narration(
      english: "Al-Duri's narration from Abu Amr Al-Basri",
      arabic: "رِوايَةُ الدُّوري.. عَنْ أبي عَمْرِو البَصْريّ",
      isSelected: false,
    ),
    Narration(
      english: "Al-Susi's narration from Abu Amr Al-Basri",
      arabic: "رِوايَةُ السُّوسِي.. عَنْ أبي عَمْرِو البَصْريّ",
      isSelected: false,
    ),
    Narration(
      english: "Hisham's narration from Ibn Amir Al-Shami",
      arabic: "رِوايَةُ هِشام.. عَنْ ابنِ عامِرِ الشَّامِيّ",
      isSelected: false,
    ),
    Narration(
      english: "Ibn Dhakwan's narration from Ibn Amir Al-Shami",
      arabic: "رِوايَةُ ابنِ ذَكْوان.. عَنْ ابنِ عامِرِ الشَّامِيّ",
      isSelected: false,
    ),
    Narration(
      english: "Shu'bah's narration from Asim Al-Kufi",
      arabic: "رِوايَةُ شُعبَة.. عَنْ عاصِمِ الكُوفيّ",
      isSelected: false,
    ),
    Narration(
      english: "Hafs's narration from Asim Al-Kufi",
      arabic: "رِوايَةُ حَفْص.. عَنْ عاصِمِ الكُوفيّ",
      isSelected: false,
    ),
    Narration(
      english: "Khalaf's narration from Hamzah Al-Kufi",
      arabic: "رِوايَةُ خَلَف.. عَنْ حَمزةَ الكُوفيّ",
      isSelected: false,
    ),
    Narration(
      english: "Khallad's narration from Hamzah Al-Kufi",
      arabic: "رِوايَةُ خَلّاد.. عَنْ حَمزةَ الكُوفيّ",
      isSelected: false,
    ),
    Narration(
      english: "Abu Al-Harith's narration from Al-Kisai",
      arabic: "رِوايَةُ أبي الحارِث.. عَنِ الكِسائيّ",
      isSelected: false,
    ),
    Narration(
      english: "Hafs Al-Duri's narration from Al-Kisai",
      arabic: "رِوايَةُ حَفْصِ الدُّوريّ.. عَنِ الكِسائيّ",
      isSelected: false,
    ),
    Narration(
      english: "Ibn Wardan's narration from Abu Ja'far Al-Madani",
      arabic: "رِوايَةُ ابنِ وَرْدان.. عَنْ أبي جَعْفَرِ المَدَنيّ",
      isSelected: false,
    ),
    Narration(
      english: "Ibn Jammaz's narration from Abu Ja'far Al-Madani",
      arabic: "رِوايَةُ ابنِ جَمَّاز.. عَنْ أبي جَعْفَرِ المَدَنيّ",
      isSelected: false,
    ),
    Narration(
      english: "Ruways's narration from Ya'qub Al-Basri",
      arabic: "رِوايَةُ رُوَيْس.. عَنْ يعقوبِ البَصْريّ",
      isSelected: false,
    ),
    Narration(
      english: "Rawh's narration from Ya'qub Al-Basri",
      arabic: "رِوايَةُ رَوْح.. عَنْ يعقوبِ البَصْريّ",
      isSelected: false,
    ),
    Narration(
      english: "Ishaq's narration from Khalaf Al-Baghdadi",
      arabic: "رِوايَةُ إسحٰق.. عَنْ خَلَفِ البَغْداديّ",
      isSelected: false,
    ),
    Narration(
      english: "Idris's narration from Khalaf Al-Baghdadi",
      arabic: "رِوايَةُ إدريس.. عَنْ خَلَفِ البَغْداديّ",
      isSelected: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 16, 15, 5),
          child: Text(
            widget.groupTitle,
            style: context.textTheme.displayMedium,
          ),
        ),
        Card(
          margin: const EdgeInsets.all(8),
          clipBehavior: Clip.antiAlias,
          color: context.theme.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.all(Radius.circular(15)),
            side: BorderSide(
                color: AppColors.border,
                width: context.theme.brightness == Brightness.dark ? 0.0 : 1.5),
          ),
          child: ListView.separated(
            itemCount: narrations.length,
            itemBuilder: (context, index) {
              return CustomSwitchListTile(
                title: LanguageService.isLanguageArabic(context)
                    ? narrations[index].arabic
                    : narrations[index].english,
                value: narrations[index].isSelected,
                onChanged: (value) {
                  setState(() {
                    narrations[index].isSelected = value;
                  });
                },
              );
            },
            separatorBuilder: (context, index) {
              return AppConstants.appDivider(context,
                  endIndent: 20, indent: 20);
            },
            shrinkWrap: true,
            physics: const ClampingScrollPhysics(),
          ),
        ),
      ],
    );
  }
}
