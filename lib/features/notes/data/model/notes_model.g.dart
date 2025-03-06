// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteModelAdapter extends TypeAdapter<NoteModel> {
  @override
  final int typeId = 4;

  @override
  NoteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteModel(
      title: fields[6] as String,
      content: fields[7] as String?,
      page: fields[0] as int,
      surahNameArabic: fields[1] as String,
      surahNameEnglish: fields[2] as String,
      ayah: fields[3] as int,
      ayahText: fields[5] as String,
      date: fields[4] as DateTime,
      audioFilePath: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, NoteModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.page)
      ..writeByte(1)
      ..write(obj.surahNameArabic)
      ..writeByte(2)
      ..write(obj.surahNameEnglish)
      ..writeByte(3)
      ..write(obj.ayah)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.ayahText)
      ..writeByte(6)
      ..write(obj.title)
      ..writeByte(7)
      ..write(obj.content)
      ..writeByte(8)
      ..write(obj.audioFilePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
