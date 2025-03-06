import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/ayah_render_bloc/ayah_render_bloc_helper.dart';
import 'package:qeraat_moshaf_kwait/features/quran_translation/presentation/screens/translation_page_screen.dart';

import '../cubit/translation_page/translation_page_cubit_service.dart';

class TranslationPageWithDropdownBookSelectionDisplay extends StatelessWidget {
  const TranslationPageWithDropdownBookSelectionDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    TranslationPageCubitService().initAndLoadPageFromBottomBar(
      context,
      fetchPageNumber: AyahRenderBlocHelper.getPageIndex(context) + 1,
    );
    return const TranslationPageScreen(
      removeNavigation: true,
    );
  }
}
