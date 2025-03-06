import '../models/translation_language_display_model.dart';

class QuranTranslationService {
  List<TranslationLanguageDisplayModel> getLanguageList() {
    return [
      TranslationLanguageDisplayModel(
        languageCode: "en",
        languageNameArabic: 'إنجليزي', //English
        languageNameEnglish: 'English',
      ),
      TranslationLanguageDisplayModel(
        languageCode: "fr",
        languageNameArabic: 'فرنسي', // French
        languageNameEnglish: 'French',
      ),
      TranslationLanguageDisplayModel(
        languageCode: "es",
        languageNameArabic: 'الإسبانية', // Spanish
        languageNameEnglish: 'Spanish',
      ),
      TranslationLanguageDisplayModel(
        languageCode: "it",
        languageNameArabic: 'الإيطالية', // Italian
        languageNameEnglish: 'Italian',
      ),
      TranslationLanguageDisplayModel(
        languageCode: "pr",
        languageNameArabic: 'الفارسية', // Persian
        languageNameEnglish: 'Persian',
      ),
      TranslationLanguageDisplayModel(
        languageCode: "tr",
        languageNameArabic: 'التركية', // Turkish
        languageNameEnglish: 'Turkey',
      ),
      TranslationLanguageDisplayModel(
        languageCode: "de",
        languageNameArabic: 'الألمانية', // German
        languageNameEnglish: 'German',
      ),
      TranslationLanguageDisplayModel(
        languageCode: "ru",
        languageNameArabic: 'الروسية', // Russian
        languageNameEnglish: 'Russian',
      ),
      TranslationLanguageDisplayModel(
        languageCode: "ur",
        languageNameArabic: 'الأردية', // Urdu
        languageNameEnglish: 'Urdu',
      ),
      TranslationLanguageDisplayModel(
        languageCode: "pt",
        languageNameArabic: 'البرتغالية', // Portuguese
        languageNameEnglish: 'Portugal',
      ),
    ];
  }
}

//crh - Crimean Tatar
// de - German
// en - English
// fr - French
// ru - Russian
// sd - Sindhi
// sw - Swahili
