class ImamStruct {
  String name;
  String id;
  bool isEnabled;
  bool ThisHafs;
  ImamStruct(
      {required this.id,
      required this.name,
      required this.isEnabled,
      required this.ThisHafs});
}

class QaraaStruct {
  String name;
  bool isEnabled;
  ImamStruct imam1;
  ImamStruct imam2;

  QaraaStruct({
    required this.name,
    required this.isEnabled,
    required this.imam1,
    required this.imam2,
  });
}

List<QaraaStruct> qaraaList = []; // Initialize with an empty list

void initqaraaList() {
  if (qaraaList.length > 0) return;
  // Create ImamStruct instances
  ImamStruct imam1 =
      ImamStruct(id: 'imam1', name: 'قالون', isEnabled: true, ThisHafs: false);
  ImamStruct imam2 =
      ImamStruct(id: 'imam2', name: 'ورش', isEnabled: true, ThisHafs: false);
  ImamStruct imam3 =
      ImamStruct(id: 'imam3', name: 'البزي', isEnabled: true, ThisHafs: false);
  ImamStruct imam4 =
      ImamStruct(id: 'imam4', name: 'قنبل', isEnabled: true, ThisHafs: false);
  ImamStruct imam5 = ImamStruct(
      id: 'imam5', name: 'دوري أبي عمرو', isEnabled: true, ThisHafs: false);
  ImamStruct imam6 =
      ImamStruct(id: 'imam6', name: 'السوسي', isEnabled: true, ThisHafs: false);
  ImamStruct imam7 =
      ImamStruct(id: 'imam7', name: 'هشام', isEnabled: true, ThisHafs: false);
  ImamStruct imam8 = ImamStruct(
      id: 'imam8', name: 'ابن ذكوان', isEnabled: true, ThisHafs: false);
  ImamStruct imam9 =
      ImamStruct(id: 'imam9', name: 'شعبة', isEnabled: true, ThisHafs: false);
  ImamStruct imam10 =
      ImamStruct(id: 'imam10', name: 'حفص', isEnabled: true, ThisHafs: true);
  ImamStruct imam11 =
      ImamStruct(id: 'imam11', name: 'خلف', isEnabled: true, ThisHafs: false);
  ImamStruct imam12 =
      ImamStruct(id: 'imam12', name: 'خلاد', isEnabled: true, ThisHafs: false);
  ImamStruct imam13 = ImamStruct(
      id: 'imam13', name: 'أبو الحارث', isEnabled: true, ThisHafs: false);
  ImamStruct imam14 = ImamStruct(
      id: 'imam14', name: 'دوري الكسائي', isEnabled: true, ThisHafs: false);
  ImamStruct imam15 = ImamStruct(
      id: 'imam15', name: 'ابن وردان', isEnabled: true, ThisHafs: false);
  ImamStruct imam16 = ImamStruct(
      id: 'imam16', name: 'ابن جماز', isEnabled: true, ThisHafs: false);
  ImamStruct imam17 =
      ImamStruct(id: 'imam17', name: 'رويس', isEnabled: true, ThisHafs: false);
  ImamStruct imam18 =
      ImamStruct(id: 'imam18', name: 'روح', isEnabled: true, ThisHafs: false);
  ImamStruct imam19 =
      ImamStruct(id: 'imam19', name: 'إسحاق', isEnabled: true, ThisHafs: false);
  ImamStruct imam20 =
      ImamStruct(id: 'imam20', name: 'إدريس', isEnabled: true, ThisHafs: false);

  // Initialize the qaraaList with QaraaStruct objects

  qaraaList = [
    QaraaStruct(
        name: 'نافع المدني', isEnabled: true, imam1: imam1, imam2: imam2),
    QaraaStruct(
        name: 'عبد الله بن كثير المكي',
        isEnabled: true,
        imam1: imam3,
        imam2: imam4),
    QaraaStruct(
        name: 'أبو عمرو البصري', isEnabled: true, imam1: imam5, imam2: imam6),
    QaraaStruct(
        name: 'ابن عامر الشامي', isEnabled: true, imam1: imam7, imam2: imam8),
    QaraaStruct(
        name: 'عاصم بن أبي النجود الكوفي',
        isEnabled: true,
        imam1: imam9,
        imam2: imam10),
    QaraaStruct(
        name: 'حمزة الزيات الكوفي',
        isEnabled: true,
        imam1: imam11,
        imam2: imam12),
    QaraaStruct(
        name: 'الكسائي الكوفي', isEnabled: true, imam1: imam13, imam2: imam14),
    QaraaStruct(
        name: 'أبو جعفر المدني', isEnabled: true, imam1: imam15, imam2: imam16),
    QaraaStruct(
        name: 'يعقوب الحضرمي', isEnabled: true, imam1: imam17, imam2: imam18),
    QaraaStruct(
        name: 'خلف البزار العاشر',
        isEnabled: true,
        imam1: imam19,
        imam2: imam20),
  ];
}
