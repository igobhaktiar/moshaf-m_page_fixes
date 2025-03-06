import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/features/main/presentation/screens/quran_fihris_screen.dart';

import '../../../../core/default_dialog.dart';

showFihrisDialog(
  BuildContext context,
  Function(int)? onTapFihrisItem,
) async {
  showDefaultDialog(
    context,
    dialogPaddingNull: true,
    withSaveButton: false,
    content: SingleChildScrollView(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.9,
        width: double.infinity,
        child: FihrisScreen(
          fromDialog: true,
          onTapFihrisItem: onTapFihrisItem,
        ),
      ),
    ),
    onDialogDismissed: () async {
      return true;
    },
  );
}
