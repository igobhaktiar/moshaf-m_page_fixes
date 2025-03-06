import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/core/default_dialog.dart'
    show showDefaultDialog;
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/data/models/ayat_swar_models.dart';
import 'package:qeraat_moshaf_kwait/features/notes/presentation/cubit/notes_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/notes/presentation/widgets/add_note_stateful_container.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

void showAddNoteDialog(BuildContext context, AyahModel ayah) {
  String noteTitle = '';
  String noteContent = '';
  TextEditingController noteTitleController = TextEditingController();
  TextEditingController noteContentController = TextEditingController();
  noteTitleController.addListener(() {});
  noteContentController.addListener(() {});

  String audioFilePath = "";

  // bool showPlayer = false;
  String? audioPath;

  showDefaultDialog(
    context,
    title: context.translate.add_note,
    onSaved: () {
      if (noteTitle.isNotEmpty) {
        final cubit = context.read<NotesCubit>();
        // ignore: unnecessary_null_comparison
        if (audioPath != null) {
          print("Adding the: $audioPath");
          cubit.addAudioNote(
            title: noteTitleController.text,
            audioFilePath: audioPath!,
            ayah: ayah,
          );
        } else {
          cubit.addTextNote(
            title: noteTitleController.text,
            content: noteContentController.text,
            ayah: ayah,
          );
        }
        Navigator.pop(context);
      } else {
        debugPrint("Enter a title first");
      }
    },
    onDialogDismissed: () async {
      log("dialog dismissed");
      return true;
    },
    withSaveButton: true,
    btntext: context.translate.add,
    content: AddNoteStatefulContainer(
      noteTitleController: noteTitleController,
      noteTitleOnChange: (value) {
        noteTitle = value;
      },
      noteContentController: noteContentController,
      noteContentOnChange: (value) {
        noteContent = value;
      },
      isNoteContentEmpty: noteContent.isEmpty,
      audioPath: audioPath,
      audioPathOnStop: (value) {
        audioPath = value;
      },
      clearAudioPath: () {
        audioPath = null;
      },
    ),

    // StatefulBuilder(builder: (context, updateState) {
    //   return Column(
    //     children: [
    //       TextField(
    //         controller: noteTitleController,
    //         onChanged: (value) => updateState(() => noteTitle = value),
    //         autofocus: true,
    //         textAlign: TextAlign.center,
    //         decoration: InputDecoration(
    //           contentPadding: const EdgeInsets.all(10),
    //           filled: true,
    //           fillColor: context.theme.brightness == Brightness.dark
    //               ? AppColors.cardBgDark
    //               : AppColors.backgroundColor,
    //           border: OutlineInputBorder(
    //             borderRadius: BorderRadius.circular(9),
    //             borderSide: BorderSide.none,
    //           ),
    //           hintText: "Title",
    //         ),
    //       ),
    //       const SizedBox(height: 16),
    //       TextField(
    //         controller: noteContentController,
    //         onChanged: (value) => updateState(() => noteContent = value),
    //         maxLines: 3,
    //         decoration: InputDecoration(
    //           contentPadding: const EdgeInsets.all(10),
    //           filled: true,
    //           fillColor: context.theme.brightness == Brightness.dark
    //               ? AppColors.cardBgDark
    //               : AppColors.backgroundColor,
    //           border: OutlineInputBorder(
    //             borderRadius: BorderRadius.circular(9),
    //             borderSide: BorderSide.none,
    //           ),
    //           hintText: "Notes Content",
    //         ),
    //       ),
    //       const SizedBox(height: 16),
    //       SizedBox(
    //         height: 200,
    //         width: MediaQuery.of(context).size.width * 0.8,
    //         child: Center(
    //           child: showPlayer
    //               ? Padding(
    //                   padding: const EdgeInsets.symmetric(horizontal: 25),
    //                   child: AudioPlayerWidget(
    //                     source: audioPath!,
    //                     onDelete: () {
    //                       updateState(() => showPlayer = false);
    //                     },
    //                   ),
    //                 )
    //               : Recorder(
    //                   onStop: (path) {
    //                     print(path);

    //                     updateState(() {
    //                       audioPath = path;
    //                       showPlayer = true;
    //                     });
    //                   },
    //                 ),
    //         ),
    //       ),
    //       const SizedBox(height: 16),
    //     ],
    //   );
    // }),
  );
}
