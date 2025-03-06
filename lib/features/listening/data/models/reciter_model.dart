class ReciterModel {
  int? id;
  String? nameEnglish;
  String? nameArabic;
  String? folderName;
  bool? isDefault;
  String? photo;
  String? compressedFile;

  ReciterModel({
    this.id,
    this.nameEnglish,
    this.nameArabic,
    this.isDefault,
    this.folderName,
    this.photo,
    this.compressedFile,
  });

  ReciterModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    nameEnglish = json['nameEnglish'];
    nameArabic = json['nameArabic'];
    isDefault = json['is_default'];
    folderName = json['folderName'];
    photo = json['photo'];
    compressedFile = json['compressed_file'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['nameEnglish'] = nameEnglish;
    data['nameArabic'] = nameArabic;
    data['folderName'] = folderName;
    data['is_default'] = isDefault;
    data['photo'] = photo;
    data['compressed_file'] = compressedFile;
    return data;
  }
}
