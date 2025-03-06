import 'dart:convert';

class TafseerPageObjectToSave {
  final int pageNumber;
  final String tafseerCode;

  TafseerPageObjectToSave({
    required this.pageNumber,
    required this.tafseerCode,
  });

  factory TafseerPageObjectToSave.fromRawJson(String str) =>
      TafseerPageObjectToSave.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory TafseerPageObjectToSave.fromJson(Map<String, dynamic> json) =>
      TafseerPageObjectToSave(
        pageNumber: json["pageNumber"],
        tafseerCode: json["tafseerCode"],
      );

  Map<String, dynamic> toJson() => {
        "pageNumber": pageNumber,
        "tafseerCode": tafseerCode,
      };
}
