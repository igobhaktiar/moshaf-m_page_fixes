import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class TafseerBookEvent extends Equatable {
  const TafseerBookEvent();
  @override
  List<Object> get props => [];
}

class LoadTafseerPageData extends TafseerBookEvent {
  final BuildContext context;
  final String tafseerCode;

  LoadTafseerPageData({required this.context, required this.tafseerCode});
}

class LoadMushaafTafseerPageData extends TafseerBookEvent {
  final BuildContext context;
  final int currentPage;

  LoadMushaafTafseerPageData({required this.context, required this.currentPage});
}

class ChangeTafseerPageData extends TafseerBookEvent {
  final BuildContext context;
  final String tafseerCode;

  ChangeTafseerPageData({required this.context, required this.tafseerCode});
}

class GetSelectedAyaTafseer extends TafseerBookEvent {
  final BuildContext context;
  final String tafseerCode;
  final int surahIndex;
  final int ayaIndex;

  GetSelectedAyaTafseer(
      {required this.context,
      required this.tafseerCode,
      required this.surahIndex,
      required this.ayaIndex});
}
