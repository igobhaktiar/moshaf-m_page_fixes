import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/core/utils/assets_manager.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

class QuranRadioPage extends StatelessWidget {
  const QuranRadioPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.translate.holy_quran_radio,
        ),
      ),
      body: Center(
        child: SizedBox(
  
          child: Image.asset(AppAssets.quranRadio, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
