import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/cubit/ayah_render_bloc/ayah_render_bloc_helper.dart';

import '../cubit/tafseer_page/tafseer_page_cubit_service.dart';
import 'tafseer_page_screen.dart';

class TafseerPageWithDropdownBookSelectionDisplay extends StatelessWidget {
  const TafseerPageWithDropdownBookSelectionDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    TafseerPageCubitService().initAndLoadPageFromBottomBar(
      context,
      fetchPageNumber: AyahRenderBlocHelper.getPageIndex(context) + 1,
    );
    return const TafseerPageScreen(
      removeNavigation: true,
    );
  }
}
