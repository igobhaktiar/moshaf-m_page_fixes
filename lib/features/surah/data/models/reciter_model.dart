class ReciterModel {
  int? id;
  String? nameEnglish;
  String? nameArabic;
  bool? isDefault;
  String? photo;
  String? allowedReciters;

  ReciterModel({
    this.id,
    this.nameEnglish,
    this.nameArabic,
    this.isDefault,
    this.photo,
  });

  ReciterModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nameEnglish = json['nameEnglish'];
    nameArabic = json['nameArabic'];
    isDefault = json['is_default'];
    photo = json['photo'];
    allowedReciters = json['allowedReciters'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nameEnglish'] = nameEnglish;
    data['nameArabic'] = nameArabic;
    data['is_default'] = isDefault;
    data['photo'] = photo;
    data['allowedReciters'] = allowedReciters ?? "";
    return data;
  }
}
