import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../../core/utils/constants.dart';
import '../widgets/bloc_wrapped_state_widgets/review_answers_list_bloc_wrapped_display.dart';

class ReviewAnswersScreen extends StatelessWidget {
  const ReviewAnswersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(context.translate.quranQA),
        leading: AppConstants.customBackButton(context),
      ),
      body: const ReviewAnswersListBlocWrappedDisplay(),
    );
  }
}
