import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';
import 'package:record/record.dart';

import '../../../../core/utils/app_colors.dart';
import 'recorder_widget.dart';

class AddNoteStatefulContainer extends StatefulWidget {
  const AddNoteStatefulContainer({
    super.key,
    required this.noteTitleController,
    required this.noteTitleOnChange,
    required this.noteContentController,
    required this.noteContentOnChange,
    required this.isNoteContentEmpty,
    required this.audioPath,
    required this.audioPathOnStop,
    required this.clearAudioPath,
  });

  final TextEditingController noteTitleController;
  final Function(String)? noteTitleOnChange;
  final TextEditingController noteContentController;
  final Function(String)? noteContentOnChange;
  final bool isNoteContentEmpty;
  final String? audioPath;
  final Function(String) audioPathOnStop;
  final VoidCallback clearAudioPath;

  @override
  State<AddNoteStatefulContainer> createState() =>
      _AddNoteStatefulContainerState();
}

class _AddNoteStatefulContainerState extends State<AddNoteStatefulContainer> {
  bool showPlayer = false;
  String? localAudioPath;

  recorder() async {
    final record = AudioRecorder();

    if (await record.hasPermission()) {
      // Start recording to file
      await record.start(const RecordConfig(), path: 'aFullPath/myFile.m4a');
      // ... or to stream
    }

    final path = await record.stop();
    await record.cancel();

    record.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          controller: widget.noteTitleController,
          onChanged: (value) {
            if (widget.noteTitleOnChange != null) {
              setState(
                () {
                  widget.noteTitleOnChange!(value);
                },
              );
            }
          },
          autofocus: true,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.all(10),
            filled: true,
            fillColor: context.theme.brightness == Brightness.dark
                ? AppColors.cardBgDark
                : AppColors.backgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(9),
              borderSide: BorderSide.none,
            ),
            hintText: context.translate.title,
          ),
        ),
        if (!showPlayer) ...[
          const SizedBox(height: 16),
          TextField(
            controller: widget.noteContentController,
            onChanged: (value) {
              if (widget.noteContentOnChange != null) {
                setState(
                  () {
                    widget.noteContentOnChange!(value);
                  },
                );
              }
            },
            maxLines: 3,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(10),
              filled: true,
              fillColor: context.theme.brightness == Brightness.dark
                  ? AppColors.cardBgDark
                  : AppColors.backgroundColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: BorderSide.none,
              ),
              hintText: context.translate.notes_content,
            ),
          ),
        ],
        if (widget.noteContentController.text.isEmpty) ...[
          const SizedBox(height: 16),
          SizedBox(
            // height: 80,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Center(
              child: showPlayer
                  ? Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25),
                      child: AudioPlayerWidget(
                        source: localAudioPath!,
                        onDelete: () {
                          setState(() {
                            showPlayer = false;
                            localAudioPath = null;
                            widget.clearAudioPath();
                          });
                        },
                      ),
                    )
                  : Recorder(
                      onStop: (path) {
                        setState(() {
                          widget.audioPathOnStop(path);
                          localAudioPath = path;
                          showPlayer = true;
                        });
                      },
                    ),
            ),
          ),
        ],
        const SizedBox(height: 16),
      ],
    );
  }
}
