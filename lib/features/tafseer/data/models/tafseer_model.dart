class AyahTafseerModel {
  int? number;
  String? text;
  String? tafseer;
  int? numberInSurah;
  int? manzil;
  int? page;
  String? surah;
  String? surahEnglish;
  int? surahNumber;

  AyahTafseerModel({
    this.number,
    this.text,
    this.tafseer,
    this.numberInSurah,
    this.manzil,
    this.page,
    this.surah,
    this.surahEnglish,
    this.surahNumber,
  });

  AyahTafseerModel.fromJson(Map<String, dynamic> json) {
    number = json['number'];
    text = json['text'];
    tafseer = json['tafseer'];
    numberInSurah = json['numberInSurah'];
    manzil = json['manzil'];
    page = json['page'];
    surah = json['surah'];
    surahEnglish = json['surah_english'];
    surahNumber = json['surah_number'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['number'] = number;
    data['text'] = text;
    data['tafseer'] = tafseer;
    data['numberInSurah'] = numberInSurah;
    data['manzil'] = manzil;
    data['page'] = page;
    data['surah'] = surah;
    data['surah_english'] = surahEnglish;
    data['surah_number'] = surahNumber;
    return data;
  }
}
