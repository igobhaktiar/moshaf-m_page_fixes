import 'package:hive/hive.dart';
part 'notes_model.g.dart';

// Run this command to generate the type adapter
// flutter packages pub run build_runner build

@HiveType(typeId: 4)
class NoteModel {
  @HiveField(0)
  int page;
  @HiveField(1)
  String surahNameArabic;
  @HiveField(2)
  String surahNameEnglish;
  @HiveField(3)
  int ayah;
  @HiveField(4)
  DateTime date;
  @HiveField(5)
  String ayahText;
  @HiveField(6)
  String title;

  @HiveField(7)
  String? content; // Nullable to allow for audio notes


  @HiveField(8)
  String? audioFilePath; // Nullable to allow for text notes

  NoteModel({
    required this.title,
    this.content,
    required this.page,
    required this.surahNameArabic,
    required this.surahNameEnglish,
    required this.ayah,
    required this.ayahText,
    required this.date,
    this.audioFilePath,
  });
}
