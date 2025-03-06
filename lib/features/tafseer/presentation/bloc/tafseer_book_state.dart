// import 'package:equatable/equatable.dart';
// import 'package:qeraat_moshaf_kwait/core/models/quran.dart';
// import 'package:qeraat_moshaf_kwait/core/models/surah.dart';
// import 'package:qeraat_moshaf_kwait/core/models/tafsser.dart';

// class TafseerBookState extends Equatable {
//   const TafseerBookState();
//   @override
//   List<Object> get props => [];
// }

// class TafseerBookLoading extends TafseerBookState {}

// class TafseerBookLoaded extends TafseerBookState {
//   final List<Tafsser> tafseerList;
//   final List<Quran> quranList;

//   TafseerBookLoaded({required this.tafseerList, required this.quranList});
// }

// class TafseerBookLoadFailed extends TafseerBookState {}

// class SelectedAyaTafseerLoading extends TafseerBookState {}

// class SelectedAyaTafseerLoaded extends TafseerBookState {
//   final Tafsser? tafseer;
//   final Quran? quran;
//   final Surah surah;

//   SelectedAyaTafseerLoaded({required this.tafseer, required this.quran, required this.surah});
// }

// class SelectedAyaTafseerLoadFailed extends TafseerBookState {}

// class MushaafTafseerLoading extends TafseerBookState {}

// class MushaafTafseerLoaded extends TafseerBookState {
//   final List<Tafsser> tafseerList;
//   final List<Quran> quranList;
//   final Surah surah;

//   MushaafTafseerLoaded({required this.tafseerList, required this.quranList, required this.surah});
// }

// class MushaafTafseerLoadFailed extends TafseerBookState {}
