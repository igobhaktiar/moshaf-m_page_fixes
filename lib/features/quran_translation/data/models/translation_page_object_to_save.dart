import 'dart:convert';

class TranslationPageObjectToSave {
  final int pageNumber;
  final String languageCode;

  TranslationPageObjectToSave({
    required this.pageNumber,
    required this.languageCode,
  });

  factory TranslationPageObjectToSave.fromRawJson(String str) =>
      TranslationPageObjectToSave.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TranslationPageObjectToSave.fromJson(Map<String, dynamic> json) =>
      TranslationPageObjectToSave(
        pageNumber: json["pageNumber"],
        languageCode: json["languageCode"],
      );

  Map<String, dynamic> toJson() => {
        "pageNumber": pageNumber,
        "languageCode": languageCode,
      };
}
