import 'package:qeraat_moshaf_kwait/core/utils/assets_manager.dart';

String getReciterName(String folderName, bool isArabic) {
  final reciter = availableReciters.firstWhere(
    (reciter) => reciter['folderName'] == folderName,
    orElse: () => null,
  );

  if (reciter == null) {
    return '';
  }

  return isArabic ? reciter['nameArabic'] : reciter['nameEnglish'];
}

List availableReciters = [
  {
    "id": 1,
    "nameEnglish": "Bader Al-Ali",
    "englishShort": "Al-Ali",
    "nameArabic": "بدر العلي",
    "arabicShort": "العلي",
    "folderName": "bader-al-ali",
    "allowedReciters": "bader-al-ali",
    "photo": AppAssets.badr_al_ali,
    "is_default": false
  },
  {
    "id": 2,
    "nameEnglish": "Mishari Al-afasy",
    "englishShort": "Al-Afasy",
    "nameArabic": "مشاري العفاسي",
    "arabicShort": "العفاسي",
    "folderName": "mishari-alafasy",
    "allowedReciters": "mishari-alafasy",
    "photo": AppAssets.sheikh,
    "is_default": false
  },
  {
    "id": 3,
    "nameEnglish": "Abdul Rahman Al Sudais",
    "englishShort": "Sudais",
    "nameArabic": "عبد الرحمن السديس",
    "arabicShort": "السديس",
    "folderName": "abdul-rahman-al-sudais",
    "allowedReciters": "abdul-rahman-al-sudais",
    "photo": AppAssets.sodais,
    "is_default": false
  },
  {
    "id": 4,
    "nameEnglish": "Mahmoud Al-Hosary",
    "englishShort": "Hosary",
    "nameArabic": "محمود الحصري",
    "arabicShort": "الحصري",
    "folderName": "mahmoud-al-hussary",
    "allowedReciters": "mahmoud-al-hussary",
    "photo": AppAssets.hosary,
    "is_default": false
  },
  {
    "id": 5,
    "nameEnglish": "Muhammad Siddiq Al Minshawi",
    "englishShort": "Minshawi",
    "nameArabic": "محمد صديق المنشاوي",
    "arabicShort": "المنشاوي",
    "folderName": "muhammad-siddiq-al-minshawi",
    "allowedReciters": "muhammad-siddiq-al-minshawi",
    "photo": AppAssets.minshawy,
    "is_default": false
  },
  {
    "id": 6,
    "nameEnglish": "Saud Al Shuraim",
    "englishShort": "Shuraim",
    "nameArabic": "سعود الشريم",
    "arabicShort": "الشريم",
    "folderName": "saud-al-shuraim",
    "allowedReciters": "saud-al-shuraim",
    "photo": AppAssets.shreem,
    "is_default": false
  },
  {
    "id": 7,
    "nameEnglish": "Ibrahim Al Akhdar",
    "englishShort": "Akhdar",
    "nameArabic": "إبراهيم الأخضر",
    "arabicShort": "الأخضر",
    "folderName": "ibrahim-al-akhdar",
    "allowedReciters": "ibrahim-al-akhdar",
    "photo": AppAssets.akhdar,
    "is_default": false
  },
  {
    "id": 8,
    "nameEnglish": "Khaled Al-Mahna",
    "englishShort": "Mahna",
    "nameArabic": "خالد المهنا",
    "arabicShort": "المهنا",
    "folderName": "khaled-al-mahna",
    "allowedReciters": "khaled-al-mahna",
    "photo": AppAssets.mahna,
    "is_default": false
  },
  {
    "id": 9,
    "nameEnglish": "Mohammed Ayoub",
    "englishShort": "Ayoub",
    "nameArabic": "محمد أيوب",
    "arabicShort": "أيوب",
    "folderName": "mohammed-ayoub",
    "allowedReciters": "mohammed-ayoub",
    "photo": AppAssets.ayoub,
    "is_default": false
  },
  {
    "id": 10,
    "nameEnglish": "Maher Al-Muaiqly",
    "englishShort": "Muaiqly",
    "nameArabic": "ماهر المعيقلي",
    "arabicShort": "المعيقلي",
    "folderName": "maher-al-muaiqly",
    "allowedReciters": "maher-al-muaiqly",
    "photo": AppAssets.muaiqly,
    "is_default": false
  },
  {
    "id": 11,
    "nameEnglish": "Ali Al-Huthaify",
    "englishShort": "Huthaify",
    "nameArabic": "علي الحذيفي",
    "arabicShort": "الحذيفي",
    "folderName": "ali-al-huthaify",
    "allowedReciters": "ali-al-huthaify",
    "photo": AppAssets.huthaify,
    "is_default": false
  },
  {
    "id": 12,
    "nameEnglish": "Abdullah Basfar",
    "englishShort": "Basfar",
    "nameArabic": "عبد الله بصفر",
    "arabicShort": "بصفر",
    "folderName": "abdullah-basfar",
    "allowedReciters": "abdullah-basfar",
    "photo": AppAssets.basfar,
    "is_default": false
  }
];
