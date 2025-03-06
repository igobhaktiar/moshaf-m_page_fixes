// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:qeraat_moshaf_kwait/core/models/index_uthmanic_hafs.dart';
// import 'package:qeraat_moshaf_kwait/core/models/quran.dart';
// import 'package:qeraat_moshaf_kwait/core/models/surah.dart';
// import 'package:qeraat_moshaf_kwait/core/models/tafsser.dart';
// import 'package:qeraat_moshaf_kwait/core/models/verses.dart';
// import 'package:qeraat_moshaf_kwait/core/utils/app_strings.dart';
// import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
// import 'package:qeraat_moshaf_kwait/features/listening/presentation/cubit/listening_cubit.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// import 'index.dart';

// class TafseerBookBloc extends Bloc<TafseerBookEvent, TafseerBookState> {
//   final SharedPreferences sharedPreferences;
//   int currentPage = 0;
//   TafseerBookBloc({required this.sharedPreferences}) : super(TafseerBookState()) {
//     on<LoadTafseerPageData>((event, emit) async {
//       emit(TafseerBookLoading());
//       int? lastAccessedPage = await sharedPreferences.getInt(AppStrings.lastAccessedTafseerPageKey);

//       if (lastAccessedPage != null) {
//         currentPage = lastAccessedPage;
//       } else {
//         currentPage = 1;
//         await sharedPreferences.setInt(AppStrings.lastAccessedTafseerPageKey, 1);
//       }
//       IndexUthmanicHafs? indexUthmanicHafs = await event.context
//           .read<EssentialMoshafCubit>()
//           .driftShamelDatabase
//           .indexUthmanicHafsDao
//           .getDataByPageIndex(currentPage);
//       if (indexUthmanicHafs != null) {
//         List<Verses> verseList = await event.context
//             .read<EssentialMoshafCubit>()
//             .driftShamelDatabase
//             .versesDao
//             .getAllDataBySurahAndAyaIndexes(indexUthmanicHafs.surahIndex!,
//                 indexUthmanicHafs.ayahFromIndex!, indexUthmanicHafs.ayahToIndex!);
//         if (verseList.isNotEmpty) {
//           List<Tafsser> tafseerList = await event.context
//               .read<EssentialMoshafCubit>()
//               .driftShamelDatabase
//               .tafsserDao
//               .getAllDataByTafseerCodeAndVerseId(
//                   verseList.first.id!, verseList.last.id!, /*event.tafseerCode*/ event.tafseerCode);
//           List<Quran> quranList = await event.context
//               .read<EssentialMoshafCubit>()
//               .driftShamelDatabase
//               .quranDao
//               .getAllDataByVerseId(verseList.first.id!, verseList.last.id!);
//           emit(TafseerBookLoaded(tafseerList: tafseerList, quranList: quranList));
//         } else {
//           emit(TafseerBookLoadFailed());
//         }
//       } else {
//         emit(TafseerBookLoadFailed());
//       }
//     });

//     on<ChangeTafseerPageData>((event, emit) async {
//       emit(TafseerBookLoading());
//       await sharedPreferences.setInt(AppStrings.lastAccessedTafseerPageKey, currentPage);
//       IndexUthmanicHafs? indexUthmanicHafs = await event.context
//           .read<EssentialMoshafCubit>()
//           .driftShamelDatabase
//           .indexUthmanicHafsDao
//           .getDataByPageIndex(currentPage);
//       if (indexUthmanicHafs != null) {
//         List<Verses> verseList = await event.context
//             .read<EssentialMoshafCubit>()
//             .driftShamelDatabase
//             .versesDao
//             .getAllDataBySurahAndAyaIndexes(indexUthmanicHafs.surahIndex!,
//                 indexUthmanicHafs.ayahFromIndex!, indexUthmanicHafs.ayahToIndex!);
//         if (verseList.isNotEmpty) {
//           List<Tafsser> tafseerList = await event.context
//               .read<EssentialMoshafCubit>()
//               .driftShamelDatabase
//               .tafsserDao
//               .getAllDataByTafseerCodeAndVerseId(
//                   verseList.first.id!, verseList.last.id!, /*event.tafseerCode*/ event.tafseerCode);
//           List<Quran> quranList = await event.context
//               .read<EssentialMoshafCubit>()
//               .driftShamelDatabase
//               .quranDao
//               .getAllDataByVerseId(verseList.first.id!, verseList.last.id!);
//           emit(TafseerBookLoaded(tafseerList: tafseerList, quranList: quranList));
//         } else {
//           emit(TafseerBookLoadFailed());
//         }
//       } else {
//         emit(TafseerBookLoadFailed());
//       }
//     });

//     on<GetSelectedAyaTafseer>((event, emit) async {
//       emit(SelectedAyaTafseerLoading());
//       Verses? verse = await event.context
//           .read<EssentialMoshafCubit>()
//           .driftShamelDatabase
//           .versesDao
//           .getDataBySurahAndAyaIndex(event.surahIndex, event.ayaIndex);
//       if (verse != null) {
//         Tafsser? tafseer = await event.context
//             .read<EssentialMoshafCubit>()
//             .driftShamelDatabase
//             .tafsserDao
//             .getDataByVerseIdAndTafseerCode(
//                 verse.id!,
//                 /*event.tafseerCode*/ event.context
//                         .read<ListeningCubit>()
//                         .currentTafseer
//                         ?.tafseerCode ??
//                     "ar-qo");
//         Quran? quran = await event.context
//             .read<EssentialMoshafCubit>()
//             .driftShamelDatabase
//             .quranDao
//             .getDataByVerseId(verse.id!);
//         Surah? surah = await event.context
//             .read<EssentialMoshafCubit>()
//             .driftShamelDatabase
//             .surahDao
//             .getDataBySurahIndex(event.surahIndex!);
//         emit(SelectedAyaTafseerLoaded(tafseer: tafseer, quran: quran, surah: surah!));
//       } else {
//         emit(SelectedAyaTafseerLoadFailed());
//       }
//     });

//     on<LoadMushaafTafseerPageData>((event, emit) async {
//       emit(MushaafTafseerLoading());
//       /*List<Book> books = await event.context
//           .read<EssentialMoshafCubit>().driftEsNavioDatabase.bookDao.getAllData();
//       for(int i = 0; i < books.length; i++){
//         print(books[i]);
//       }*/
//       IndexUthmanicHafs? indexUthmanicHafs = await event.context
//           .read<EssentialMoshafCubit>()
//           .driftShamelDatabase
//           .indexUthmanicHafsDao
//           .getDataByPageIndex(event.currentPage);
//       if (indexUthmanicHafs != null) {
//         List<Verses> verseList = await event.context
//             .read<EssentialMoshafCubit>()
//             .driftShamelDatabase
//             .versesDao
//             .getAllDataBySurahAndAyaIndexes(indexUthmanicHafs.surahIndex!,
//                 indexUthmanicHafs.ayahFromIndex!, indexUthmanicHafs.ayahToIndex!);
//         if (verseList.isNotEmpty) {
//           List<Tafsser> tafseerList = await event.context
//               .read<EssentialMoshafCubit>()
//               .driftShamelDatabase
//               .tafsserDao
//               .getAllDataByTafseerCodeAndVerseId(
//                   verseList.first.id!,
//                   verseList.last.id!,
//                   /*event.tafseerCode*/ event.context
//                           .read<ListeningCubit>()
//                           .currentTafseer
//                           ?.tafseerCode ??
//                       "ar-qo");
//           List<Quran> quranList = await event.context
//               .read<EssentialMoshafCubit>()
//               .driftShamelDatabase
//               .quranDao
//               .getAllDataByVerseId(verseList.first.id!, verseList.last.id!);
//           Surah? surah = await event.context
//               .read<EssentialMoshafCubit>()
//               .driftShamelDatabase
//               .surahDao
//               .getDataBySurahIndex(indexUthmanicHafs.surahIndex!);
//           emit(MushaafTafseerLoaded(tafseerList: tafseerList, quranList: quranList, surah: surah!));
//         } else {
//           emit(MushaafTafseerLoadFailed());
//         }
//       } else {
//         emit(MushaafTafseerLoadFailed());
//       }
//     });
//   }
// }
