import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_strings.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/data/models/ayat_swar_models.dart';
import 'package:qeraat_moshaf_kwait/features/notes/data/model/notes_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit({required this.sharedPreferences}) : super(NotesInitial());

  static NotesCubit get(BuildContext context) => BlocProvider.of(context);

  late final Box notesBox;
  late ValueListenable<Box> notesBoxListenable;
  final SharedPreferences sharedPreferences;

  Future<void> init() async {
    notesBox = Hive.box(AppStrings.notesBox);
    notesBoxListenable = notesBox.listenable();
  }

  void addAudioNote({
    required String title,
    required String audioFilePath,
    required AyahModel ayah,
  }) {
    final note = NoteModel(
      title: title,
      audioFilePath: audioFilePath,
      page: ayah.page!,
      surahNameArabic: ayah.surah!,
      surahNameEnglish: ayah.surahEnglish!,
      ayah: ayah.numberInSurah!,
      ayahText: ayah.text!,
      date: DateTime.now(),
    );
    notesBox.add(note);
    emit(NotesLoaded(List<NoteModel>.from(notesBox.values)));
  }

  void addTextNote({
    required String title,
    required String content,
    required AyahModel ayah,
  }) {
    final note = NoteModel(
      title: title,
      content: content,
      page: ayah.page!,
      surahNameArabic: ayah.surah!,
      surahNameEnglish: ayah.surahEnglish!,
      ayah: ayah.numberInSurah!,
      ayahText: ayah.text!,
      date: DateTime.now(),
    );
    notesBox.add(note);
    emit(NotesLoaded(List<NoteModel>.from(notesBox.values)));
    print('Note added');
  }

  Future<void> deleteNoteAt(int index) async => await notesBox.deleteAt(index);
}
