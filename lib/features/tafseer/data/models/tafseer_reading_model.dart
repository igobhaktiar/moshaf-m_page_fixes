import 'package:flutter/material.dart';

import '../../../../core/utils/assets_manager.dart';

class TafseerPageList {
  final int pageIndex;
  List<AyahWithTafseer> ayahs;

  TafseerPageList({
    required this.pageIndex,
    required this.ayahs,
  });
}

class AyahWithTafseer {
  final int ayahId;
  final String verseUthmani;
  final int surahIndex;
  final String surahName;
  final String tafseerText;

  AyahWithTafseer(
      {required this.ayahId,
      required this.verseUthmani,
      required this.surahIndex,
      required this.surahName,
      required this.tafseerText});
}

class TafseerReadingModel {
  final String tafseerCode,
      tafseerNameArabic,
      tafseerNameEnglish,
      tafseerDescription,
      tafseerImage;
  final Color color;

  TafseerReadingModel({
    required this.tafseerCode,
    required this.tafseerNameArabic,
    required this.tafseerDescription,
    required this.tafseerNameEnglish,
    required this.tafseerImage,
    required this.color,
  });
}

List<AyahWithTafseer> removeDuplicates(List<AyahWithTafseer> ayahs) {
  final uniqueAyahs = <AyahWithTafseer>[];

  for (final ayah in ayahs) {
    bool isDuplicate = uniqueAyahs.any((unique) =>
        unique.ayahId == ayah.ayahId &&
        unique.verseUthmani == ayah.verseUthmani &&
        unique.surahIndex == ayah.surahIndex &&
        unique.surahName == ayah.surahName &&
        unique.tafseerText == ayah.tafseerText);

    if (!isDuplicate) {
      uniqueAyahs.add(ayah);
    } else {
      print("duplicate detected");
    }
  }
  print("unique ayah length=${uniqueAyahs.length}");
  return uniqueAyahs;
}

class TafseerReadingService {
  List<TafseerReadingModel> getTafseerList() {
    return [
      TafseerReadingModel(
        tafseerCode: "ar-qo",
        tafseerNameArabic: 'تفسیر المنان',
        tafseerDescription:
            "الشيخ عبد الكريم بن أحمد الحجوري العمري أعدَّ تفسير (نعمة المنان في تفسير القرآن)، وهو تفسير معاصر يشرح آيات القرآن الكريم بأسلوب مبسط وواضح، مما يجعله مرجعًا مفيدًا للعديد من الطلاب والباحثين الذين يرغبون في فهم النص القرآني، والتفسير إحدى إصدارات الهيئة العامة للعناية بطباعة ونشر القرآن الكريم والسنة النبوية وعلومها.",
        tafseerNameEnglish: 'Tafseer Al Mannan',
        tafseerImage: AppAssets.mananIcon,
        color: Colors.lime[700]!,
      ),
      TafseerReadingModel(
        tafseerCode: "ar-mu",
        tafseerNameArabic: 'تفسير الميسر',
        tafseerDescription:
            "من إصدارات مجمع الملك فهد لطباعة المصحف الشريف، وهي مؤسسة عريقة ومتخصصة في طباعة ونشر المصحف الشريف، تأسس المجمع عام ١٤٠٥ هـ (١٩٨٤م) بهدف طباعة المصحف وتوزيعه على المسلمين في جميع أنحاء العالم، بالإضافة إلى طباعة المصحف، يقوم المجمع بنشر كتب علوم القرآن والسنة وترجمتها إلى العديد من اللغات.",
        tafseerNameEnglish: 'Tafseer Al Muyassar',
        tafseerImage: AppAssets.muyassarIcon,
        color: Colors.deepPurple[200]!,
      ),
      TafseerReadingModel(
        tafseerCode: "ar-bg",
        tafseerNameArabic: 'تفسير البغوي',
        tafseerDescription:
            "الإمام الحسين بن مسعود البغوي، ولد في (بغثور) سنة (٤٣٣هـ) أو (٤٣٦هـ)، وتوفي بمدينة (مرو الروذ) عام (٥١٦ هـ)، وهو فقيه ومفسر شهير من علماء الإسلام، اشتهر بتأليفه العديد من الكتب المهمة في التفسير والفقه، ومن أبرز أعماله تفسيره الشهير (معالم التنزيل)، ويُعَدُّ مرجعاً موثوقاً في علوم القرآن والسنة.",
        tafseerNameEnglish: 'Tafseer Al-Baghawi',
        tafseerImage: AppAssets.baghawiIcon,
        color: Colors.purple,
      ),
      TafseerReadingModel(
        tafseerCode: "ar-ta",
        tafseerNameArabic: 'تفسير الطبري',
        tafseerNameEnglish: 'Tafseer Al-Tabari',
        tafseerDescription:
            "أبو جعفر محمد بن جرير الطبري (٢٢٤ هـ - ٣١٠ هـ) مفسر ومؤرخ وفقيه إسلامي بارز، وُلد في مدينة آمل بطبرستان، واشتهر بتفسيره (جامع البيان)، وتاريخه: (تاريخ الأمم والملوك)، توفي في بغداد، ويُعَد من أهم العلماء في تاريخ الإسلام.",
        tafseerImage: AppAssets.tabariIcon,
        color: Colors.lightBlue[700]!,
      ),
      TafseerReadingModel(
        tafseerCode: "ar-ik",
        tafseerNameArabic: 'تفسير ابن كثير',
        tafseerDescription:
            "الإمام ابن كثير، إسماعيل بن عمر بن كثير، أبو الفداء، ولد في (بُصرا) سنة ٧٠١هـ، وتوفي في (دمشق) عام ٧٧٤هـ، عُرف بتفسيره المشهور (تفسير ابن كثير)، وبمؤلفاته في التاريخ، مثل البداية والنهاية، وتميَّز بدقة علمه، وسعة اطلاعه في علوم الحديث والتفسير.",
        tafseerNameEnglish: 'Tafseer Ibn Kathir',
        tafseerImage: AppAssets.kathirIcon,
        color: Colors.black,
      ),
    ];
  }

  List<String> tafseerBooksCode = [
    "ar-qo",
    "ar-mu",
    "ar-bg",
    "ar-ta",
    "ar-ik",
  ];

  List<Color?> booksColors = [
    Colors.lime[700],
    Colors.deepPurple[200],
    Colors.purple,
    Colors.lightBlue[700],
    Colors.black,
  ];
}
