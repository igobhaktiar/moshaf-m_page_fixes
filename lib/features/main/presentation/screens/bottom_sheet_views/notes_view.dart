import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_colors.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_strings.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/notes/data/model/notes_model.dart';
import 'package:qeraat_moshaf_kwait/features/notes/presentation/cubit/notes_cubit.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../../../config/app_config/app_config.dart';
import '../../../../../core/utils/app_context.dart';
import '../../../../../core/utils/assets_manager.dart';
import '../../../../../core/utils/constants.dart';
import '../../../../essential_moshaf_feature/presentation/cubit/bottom_widget_cubit/bottom_widget_cubit.dart';
import '../../../../notes/presentation/widgets/recorder_widget.dart';
import '../../cubit/ayah_render_bloc/ayah_render_bloc_helper.dart';
import 'widgets/slider_delete_button.dart';

class NotesView extends StatefulWidget {
  final bool withDash;
  final bool dense;
  final bool forSavedView;
  final bool popWhenClicked;
  final bool showAppbar;
  const NotesView({
    this.withDash = true,
    this.dense = false,
    this.forSavedView = false,
    Key? key,
    this.popWhenClicked = false,
    this.showAppbar = false,
  }) : super(key: key);

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.showAppbar
          ? AppBar(
              title: Text(context.translate.notes),
              leading: AppConstants.customBackButton(context),
            )
          : null,
      body: BlocBuilder<NotesCubit, NotesState>(builder: (context, state) {
        var cubit = NotesCubit.get(context);
        return ValueListenableBuilder(
          valueListenable: cubit.notesBoxListenable,
          builder: (context, Box box, boxWidget) {
            return box.isEmpty
                ? Column(
                    children: [
                      if (widget.withDash) const ViewDashIndicator(),
                      Expanded(
                        child: CenteredEmptyListMsgWidget(
                            msg: context.translate.notes_list_is_empty),
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        if (widget.withDash) const ViewDashIndicator(),
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              for (int i = 0; i < box.length; i++)
                                SlidableNoteListTile(
                                  dense: widget.dense,
                                  popWhenClicked: widget.popWhenClicked,
                                  forSavedView: widget.forSavedView,
                                  isInBottomSheet: widget.showAppbar,
                                  key: Key((box.getAt(i) as NoteModel)
                                      .date
                                      .toIso8601String()),
                                  note: box.getAt(i) as NoteModel,
                                  index: i,
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
          },
        );
      }),
    );
  }
}

class SlidableNoteListTile extends StatefulWidget {
  final bool dense;
  final bool popWhenClicked;
  final bool forSavedView;
  final bool isInBottomSheet;
  final NoteModel note;
  final int index;

  const SlidableNoteListTile({
    required this.dense,
    required this.popWhenClicked,
    this.isInBottomSheet = false,
    required this.forSavedView,
    required Key key,
    required this.note,
    required this.index,
  }) : super(key: key);

  @override
  State<SlidableNoteListTile> createState() => _SlidableNoteListTileState();
}

class _SlidableNoteListTileState extends State<SlidableNoteListTile> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  String? _error;
  late String _directoryPath;

  @override
  void initState() {
    super.initState();
    _initDirectory();
  }

  Future<void> _initDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    _directoryPath = directory.path;
  }

  Future<void> _createFile() async {
    final completeFileName = widget.note.audioFilePath!.split('/').last;
    final filePath = '$_directoryPath/$completeFileName';
    final file = File(filePath);

    if (!(await file.exists())) {
      await file.create(recursive: true);
      debugPrint('Created file path: ${file.path}');
    }
  }

  Future<void> _createDirectory() async {
    final directory = Directory(_directoryPath);
    if (!(await directory.exists())) {
      await directory.create(recursive: true);
      debugPrint('Created directory path: ${directory.path}');
    }
  }

  Future<void> _writeFileToStorage() async {
    await _createDirectory();
    await _createFile();
  }

  void _playAudio() async {
    if (_isPlaying) {
      await _audioPlayer.stop();
      setState(() {
        _isPlaying = false;
      });
    } else {
      try {
        if (widget.note.audioFilePath != null) {
          await _writeFileToStorage();

          final completeFileName = widget.note.audioFilePath!.split('/').last;
          final filePath = '$_directoryPath/$completeFileName';
          final file = File(filePath);
          debugPrint('Audio file path: $filePath');

          if (await file.exists()) {
            // Local file path
            final duration = await _audioPlayer.setFilePath(filePath);
            _audioPlayer.play();
            setState(() {
              _isPlaying = true;
              _error = null;
            });

            _audioPlayer.playerStateStream.listen((state) {
              if (state.processingState == ProcessingState.completed) {
                setState(() {
                  _isPlaying = false;
                });
              }
            });
          } else {
            throw Exception('Audio file does not exist');
          }
        } else {
          throw Exception('Audio file path is null');
        }
      } catch (e) {
        debugPrint('Error starting player: $e');
        setState(() {
          _error = e.toString();
        });
      }
    }
  }

  _onDeletePressed(BuildContext context) {
    AppConstants.showConfirmationDialog(context,
        confirmMsg: context.translate
            .do_you_want_to_delete_this_item(context.translate.this_item),
        okCallback: () {
      NotesCubit.get(context)
          .deleteNoteAt(widget.index)
          .whenComplete(() => Navigator.pop(context));
    });
  }

  void _onNoteTapped(BuildContext context, bool isInBottomSheet) {
    BuildContext? appContext = AppContext.getAppContext();
    if (appContext != null) {
      // appContext.read<EssentialMoshafCubit>().navigateToPage(widget.note.page);
      AyahRenderBlocHelper.pageChangeInitialize(
        appContext,
        widget.note.page - 1,
      );
      Future.delayed(const Duration(milliseconds: 500), () {
        var surahNumber = appContext
            .read<EssentialMoshafCubit>()
            .getSurahNumberFromItsName(widget.note.surahNameEnglish);
        if (surahNumber != null) {
          AyahRenderBlocHelper.colorAyaAndUpdateBloc(
            surahNumber: surahNumber,
            ayahNumber: widget.note.ayah,
          );
        }
        if (isInBottomSheet) {
          Navigator.of(context).pop();
        }
        appContext
            .read<EssentialMoshafCubit>()
            .showBottomNavigateByPageLayer(false);
        //Notes navigation
        if (!AppConfig.isQeeratView()) {
          BottomWidgetCubit.get(appContext)
              .setBottomWidgetState(true, customIndex: 3);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliderDeleteButton(
      onDeletePressed: () => _onDeletePressed(context),
      child: ListTile(
        dense: widget.dense,
        contentPadding: EdgeInsets.symmetric(
            vertical: widget.dense ? 0 : 10, horizontal: 25),
        minVerticalPadding: widget.dense ? 0 : 10,
        minLeadingWidth: 0,
        title: Text(
          widget.note.title.toString(),
          style: context.textTheme.bodyMedium!.copyWith(
              color: context.theme.brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
              fontWeight: FontWeight.w700),
        ),
        leading: SvgPicture.asset(
          AppAssets.yourNotesMiniMenuIcon,
          height: 25,
          width: 25,
          color:
              context.theme.brightness == Brightness.dark ? Colors.white : null,
        ),
        trailing: _error != null
            ? Text('Error: $_error', style: const TextStyle(color: Colors.red))
            : Text(
                '${context.translate.localeName == AppStrings.arabicCode ? widget.note.surahNameArabic : widget.note.surahNameEnglish} - ${context.translate.the_ayah} ${widget.note.ayah}',
                style: context.textTheme.bodySmall!
                    .copyWith(fontSize: 16, fontWeight: FontWeight.w500),
              ),
        subtitle: widget.note.audioFilePath != null
            ? AudioPlayerWidget(
                source: widget.note.audioFilePath!,
                smallButton: true,
              )
            : Text(widget.note.content ?? ''),
        onTap: () {
          _onNoteTapped(context, widget.isInBottomSheet);
          if (widget.popWhenClicked) {
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

class CenteredEmptyListMsgWidget extends StatelessWidget {
  const CenteredEmptyListMsgWidget({
    Key? key,
    required this.msg,
  }) : super(key: key);
  final String msg;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        msg,
        textDirection: context.translate.localeName == AppStrings.arabicCode
            ? TextDirection.rtl
            : TextDirection.ltr,
        style: context.textTheme.bodyMedium!.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ViewDashIndicator extends StatelessWidget {
  const ViewDashIndicator({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.read<EssentialMoshafCubit>().hideFlyingLayers(),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        width: 31,
        decoration: BoxDecoration(
          border: Border.all(width: 2.5, color: AppColors.lightBrown),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
