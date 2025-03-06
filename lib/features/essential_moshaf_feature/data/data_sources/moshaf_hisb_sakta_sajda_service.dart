import 'dart:convert';

import 'package:flutter/material.dart';

import '../../presentation/cubit/zoom_cubit/zoom_enum.dart';
import 'ayah_svg_service_helper.dart';

enum MaskType { longMask, shortMask, sajdaMask, saktaMask }

String getMaskFullString(String? maskName) {
  if (maskName == null) return '';
  return 'assets/hisb_icons/$maskName';
}

class MoshafHisbSaktaSajdaService {
  Map<int, List<PageHisbSaktaSajda>> pageMap = {};

  void init() {
    pageMap = processData(moshafPageHisbSaktaSajdaData);
  }

  String getHizbPath(int pageNumber) {
    print("pagenumber is $pageNumber");
    init();

    List<PageHisbSaktaSajda>? currentPageHisbSaktaSajda = pageMap[pageNumber];

    if (currentPageHisbSaktaSajda != null &&
        currentPageHisbSaktaSajda.isNotEmpty) {
      // Remove all 'sajda' and 'sakta' files
      List<PageHisbSaktaSajda> filteredFiles = currentPageHisbSaktaSajda
          .where((file) =>
              !file.fileName.contains('sajda') &&
              !file.fileName.contains('sakta'))
          .toList();
      if (filteredFiles.isEmpty) {
        print('No valid Hisb images found after filtering sajda/sakta.');
        return '';
      } else {
        PageHisbSaktaSajda selectedFile = filteredFiles.first;
        print('Selected File: ${selectedFile.fileName}');

        return 'assets/hisb_icons/${selectedFile.fileName}';
      }
    } else {
      print('No valid Hisb images found after filtering sajda/sakta.');
    }
    return '';
  }

  Map<String, dynamic> longMasks = {
    'dark': 'long_mask_dark.png',
    'light': 'long_mask_light.png',
  };

  Map<String, dynamic> shortMasks = {
    'dark': 'short_mask_dark.png',
    'light': 'short_mask_light.png',
  };

  Map<String, dynamic> sajdaMasks = {
    'dark': 'sajda_mask_dark.png',
    'light': 'sajda_mask_light.png',
  };

  doesPageHasHizb(int pageNo) {
    //if long and short mask list contains the page number then it has hizb
    return longMaskList.contains(pageNo) || shortMaskList.contains(pageNo);
  }

  MaskType getMaskType(int pageNo) {
    if (longMaskList.contains(pageNo)) {
      return MaskType.longMask;
    } else if (shortMaskList.contains(pageNo)) {
      return MaskType.shortMask;
    }
    return MaskType.shortMask;
  }

  MaskType getHisbType(int pageNo, String fileName) {
    //check if filename contain sajda then first check the sajda list
    if (fileName.contains('sajda')) {
      if (shortSajdaList.contains(pageNo)) {
        return MaskType.sajdaMask;
      }
    }
    //sakta
    if (fileName.contains('sakta')) {
      if (saktaMaskList.contains(pageNo)) {
        return MaskType.saktaMask;
      }
    }

    if (longMaskList.contains(pageNo)) {
      if (saktaMaskList.contains(pageNo)) {
        return MaskType.saktaMask;
      } else {
        return MaskType.longMask;
      }
    } else if (shortMaskList.contains(pageNo)) {
      return MaskType.shortMask;
    } else if (saktaMaskList.contains(pageNo)) {
      return MaskType.saktaMask;
    } else if (shortSajdaList.contains(pageNo)) {
      return MaskType.sajdaMask;
    }
    return MaskType.shortMask;
  }

  Size getMaskSize(int pageNo, String fileName) {
    final maskType = getHisbType(pageNo, fileName);
    const defaultWidth = 23.333333333333332;
    print('MaskType: $maskType');
    switch (maskType) {
      case MaskType.shortMask:
        return const Size(defaultWidth, 64.66666666666667);
      case MaskType.sajdaMask:
        return const Size(defaultWidth, 37.333333333333336);
      case MaskType.saktaMask:
        return const Size(defaultWidth, 97.66666666666667);
      case MaskType.longMask:
        return const Size(defaultWidth, 108.0);
    }
  }
//enum for mask type

  String longMaskListName = 'longMaskList';
  List<int> longMaskList = [
    11,
    22,
    32,
    42,
    51,
    62,
    72,
    82,
    92,
    102,
    112,
    121,
    132,
    142,
    151,
    162,
    173,
    182,
    192,
    201,
    212,
    222,
    231,
    242,
    252,
    262,
    282,
    292,
    302,
    309,
    312,
    322,
    332,
    334,
    342,
    352,
    362,
    371,
    379,
    382,
    392,
    402,
    413,
    422,
    431,
    442,
    443,
    451,
    462,
    472,
    482,
    491,
    502,
    513,
    522,
    531,
    553,
    562,
    567,
    572,
    578,
    588,
    582,
    591,
  ];

  final String shortMaskListName = 'shortMaskList';
  List<int> shortMaskList = [
    5,
    7,
    9,
    14,
    17,
    19,
    24,
    27,
    29,
    34,
    37,
    39,
    44,
    46,
    49,
    54,
    56,
    59,
    64,
    67,
    69,
    74,
    77,
    79,
    84,
    87,
    89,
    94,
    97,
    100,
    104,
    106,
    109,
    114,
    117,
    119,
    124,
    126,
    129,
    134,
    137,
    140,
    144,
    146,
    148,
    154,
    156,
    158,
    164,
    167,
    170,
    175,
    177,
    179,
    184,
    187,
    189,
    194,
    196,
    199,
    204,
    206,
    209,
    214,
    217,
    219,
    224,
    226,
    228,
    233,
    236,
    238,
    244,
    247,
    249,
    254,
    256,
    259,
    264,
    267,
    270,
    275,
    277,
    284,
    287,
    289,
    295,
    297,
    299,
    304,
    306,
    315,
    317,
    319,
    324,
    326,
    329,
    336,
    339,
    344,
    347,
    350,
    354,
    374,
    356,
    359,
    367,
    369,
    377,
    382,
    384,
    386,
    389,
    394,
    396,
    399,
    404,
    407,
    410,
    415,
    418,
    420,
    425,
    426,
    429,
    433,
    436,
    439,
    444,
    446,
    449,
    454,
    456,
    459,
    464,
    467,
    469,
    474,
    477,
    479,
    484,
    486,
    488,
    493,
    496,
    499,
    505,
    507,
    510,
    515,
    517,
    519,
    524,
    526,
    534,
    536,
    539,
    544,
    547,
    550,
    554,
    558,
    560,
    564,
    566,
    569,
    575,
    577,
    579,
    585,
    587,
    589,
    594,
    596,
    600,
  ];

  String shortSajdaListName = 'shortSajdaList';
  List<int> shortSajdaList = [
    176,
    251,
    293,
    341,
    365,
    416,
    454,
    589,
    480,
    598,
  ];
  List<int> saktaMaskList = [588, 578, 567, 443, 293];

  bool isPageBeingAligned(int pageNumber) {
    bool pageAligned = false;
    if (shortMaskList.contains(pageNumber)) {
      pageAligned = true;
    }
    if (longMaskList.contains(pageNumber)) {
      pageAligned = true;
    }
    return pageAligned;
  }

  String? getMask(
    int pageNumber, {
    bool isDark = false,
    String? listName,
  }) {
    if (listName == null) {
      if (longMaskList.contains(pageNumber)) {
        if (isDark) {
          return longMasks['dark'];
        } else {
          return longMasks['light'];
        }
      }

      if (shortMaskList.contains(pageNumber)) {
        if (isDark) {
          return shortMasks['dark'];
        } else {
          return shortMasks['light'];
        }
      }

      if (shortSajdaList.contains(pageNumber)) {
        if (isDark) {
          return sajdaMasks['dark'];
        } else {
          return sajdaMasks['light'];
        }
      }
    } else {
      if (listName == longMaskListName) {
        if (isDark) {
          return longMasks['dark'];
        } else {
          return longMasks['light'];
        }
      } else if (listName == shortMaskListName) {
        if (isDark) {
          return shortMasks['dark'];
        } else {
          return shortMasks['light'];
        }
      } else if (listName == shortSajdaListName) {
        if (isDark) {
          return sajdaMasks['dark'];
        } else {
          return sajdaMasks['light'];
        }
      }
    }

    return null;
  }

  // Input data
  List<List<dynamic>> moshafPageHisbSaktaSajdaData = [
    [5, "005.png", 329.06, 122.05],
    [7, "007.png", 329.06, 256.25],
    [9, "009.png", 329.06, 149.35],
    [11, "011.png", 329.06, 305.75],
    [14, "014.png", 31.31, 282.35],
    [17, "017.png", 329.06, 40.55],
    [19, "019.png", 329.06, 231.25],
    [22, "022.png", 31.31, 35.95],
    [24, "024.png", 31.31, 176.35],
    [27, "027.png", 329.06, 41.05],
    [29, "029.png", 329.06, 311.25],
    [32, "032.png", 31.31, 34.90],
    [34, "034.png", 31.31, 337.85],
    [37, "037.png", 329.06, 257.15],
    [39, "039.png", 329.06, 256.05],
    [42, "042.png", 31.31, 35.75],
    [44, "044.png", 31.31, 282.15],
    [46, "046.png", 31.31, 148.35],
    [49, "049.png", 329.06, 42.05],
    [51, "051.png", 329.06, 331.40],
    [54, "054.png", 31.31, 174.15],
    [56, "056.png", 31.31, 362.25],
    [59, "059.png", 329.06, 229.25],
    [62, "062.png", 31.31, 62.50],
    [64, "064.png", 31.31, 282.05],
    [67, "067.png", 329.06, 41.15],
    [69, "069.png", 329.06, 336.35],
    [72, "072.png", 31.31, 278.85],
    [74, "074.png", 31.31, 337.95],
    [77, "077.png", 329.06, 97.15],
    [79, "079.png", 329.06, 41.65],
    [82, "082.png", 31.31, 36.25],
    [84, "084.png", 31.31, 255.25],
    [87, "087.png", 329.06, 282.25],
    [89, "089.png", 329.06, 363.55],
    [92, "092.png", 31.31, 61.75],
    [94, "094.png", 31.31, 282.65],
    [97, "097.png", 329.06, 41.85],
    [100, "100.png", 31.31, 40.75],
    [102, "102.png", 31.31, 36.00],
    [104, "104.png", 31.31, 40.55],
    [106, "106.png", 31.31, 229.85],
    [109, "109.png", 329.06, 148.45],
    [112, "112.png", 31.31, 170.40],
    [114, "114.png", 31.31, 201.75],
    [117, "117.png", 329.06, 41.55],
    [119, "119.png", 329.06, 148.05],
    [121, "121.png", 329.06, 248.80],
    [124, "124.png", 31.31, 95.35],
    [126, "126.png", 31.31, 42.45],
    [129, "129.png", 329.06, 202.85],
    [132, "132.png", 31.31, 36.00],
    [134, "134.png", 31.31, 336.55],
    [137, "137.png", 329.06, 41.65],
    [140, "140.png", 31.31, 40.75],
    [142, "142.png", 31.31, 36.65],
    [144, "144.png", 31.31, 148.35],
    [146, "146.png", 31.31, 256.25],
    [148, "148.png", 31.31, 282.05],
    [151, "151.png", 329.06, 90.30],
    [154, "154.png", 31.31, 41.15],
    [156, "156.png", 31.31, 203.15],
    [158, "158.png", 31.31, 308.35],
    [162, "162.png", 31.31, 37.80],
    [164, "164.png", 31.31, 364.05],
    [167, "167.png", 329.06, 228.95],
    [170, "170.png", 31.31, 41.55],
    [173, "173.png", 329.06, 36.80],
    [175, "175.png", 329.06, 95.25],
    [176, "176-sajda.png", 31.31, 421.59],
    [177, "177.png", 329.06, 96.85],
    [179, "179.png", 329.06, 255.75],
    [182, "182.png", 31.31, 36.40],
    [184, "184.png", 31.31, 390.25],
    [187, "187.png", 329.06, 72.55],
    [189, "189.png", 329.06, 310.75],
    [192, "192.png", 31.31, 116.05],
    [194, "194.png", 31.31, 309.95],
    [196, "196.png", 31.31, 257.35],
    [199, "199.png", 329.06, 202.45],
    [201, "201.png", 329.06, 357.90],
    [204, "204.png", 31.31, 309.85],
    [206, "206.png", 31.31, 363.75],
    [209, "209.png", 329.06, 202.95],
    [212, "212.png", 31.31, 37.10],
    [214, "214.png", 31.31, 390.95],
    [217, "217.png", 329.06, 41.25],
    [219, "219.png", 329.06, 68.95],
    [222, "222.png", 31.31, 36.35],
    [224, "224.png", 31.31, 202.45],
    [226, "226.png", 31.31, 176.75],
    [228, "228.png", 31.31, 310.65],
    [231, "231.png", 329.06, 90.30],
    [233, "233.png", 329.06, 391.35],
    [236, "236.png", 31.31, 150.65],
    [238, "238.png", 31.31, 390.45],
    [242, "242.png", 31.31, 37.50],
    [244, "244.png", 31.31, 310.65],
    [247, "247.png", 329.06, 284.55],
    [249, "249.png", 329.06, 337.35],
    [251, "251-sajda.png", 329.06, 126.19],
    [252, "252.png", 31.31, 36.75],
    [254, "254.png", 31.31, 41.95],
    [256, "256.png", 31.31, 335.45],
    [259, "259.png", 329.06, 176.95],
    [262, "262.png", 31.31, 88.85],
    [264, "264.png", 31.31, 390.35],
    [267, "267.png", 329.06, 254.95],
    [270, "270.png", 31.31, 175.95],
    [272, "272.png", 31.31, 306.20],
    [275, "275.png", 329.06, 94.45],
    [277, "277.png", 329.06, 149.55],
    [280, "280.png", 31.31, 41.55],
    [282, "282.png", 31.31, 91.35],
    [284, "284.png", 31.31, 229.75],
    [287, "287.png", 329.06, 41.85],
    [289, "289.png", 329.06, 177.15],
    [292, "292.png", 31.31, 144.35],
    [293, "293-sakta.png", 329.06, 338.59],
    [293, "293-sajda.png", 329.06, 182.49],
    [295, "295.png", 329.06, 95.45],
    [297, "297.png", 329.06, 310.45],
    [299, "299.png", 329.06, 309.55],
    [302, "302.png", 31.31, 37.65],
    [304, "304.png", 31.31, 69.85],
    [306, "306.png", 31.31, 309.75],
    [309, "309.png", 329.06, 223.90],
    [312, "312.png", 31.31, 196.60],
    [315, "315.png", 329.06, 122.45],
    [317, "317.png", 329.06, 229.85],
    [319, "319.png", 329.06, 337.45],
    [322, "322.png", 31.31, 88.55],
    [324, "324.png", 31.31, 176.85],
    [326, "326.png", 31.31, 258.05],
    [329, "329.png", 329.06, 69.05],
    [332, "332.png", 31.31, 90.05],
    [334, "334.png", 31.31, 224.10],
    [336, "336.png", 31.31, 392.15],
    [339, "339.png", 329.06, 203.15],
    [341, "341-sajda.png", 329.06, 261.39],
    [342, "342.png", 31.31, 87.25],
    [344, "344.png", 31.31, 284.45],
    [347, "347.png", 329.06, 43.05],
    [350, "350.png", 31.31, 98.35],
    [352, "352.png", 31.31, 37.95],
    [354, "354.png", 31.31, 256.85],
    [356, "356.png", 31.31, 392.05],
    [359, "359.png", 329.06, 364.25],
    [362, "362.png", 31.31, 36.60],
    [364, "364.png", 31.31, 310.85],
    [365, "365-sajda.png", 329.06, 207.89],
    [367, "367.png", 329.06, 97.05],
    [369, "369.png", 329.06, 310.45],
    [371, "371.png", 329.06, 410.15],
    [374, "374.png", 31.31, 364.75],
    [377, "377.png", 329.06, 97.85],
    [379, "379.png", 329.06, 166.55],
    [382, "382.png", 31.31, 33.95],
    [384, "384.png", 31.31, 147.95],
    [386, "386.png", 31.31, 337.05],
    [389, "389.png", 329.06, 41.75],
    [392, "392.png", 31.31, 37.50],
    [394, "394.png", 31.31, 282.95],
    [396, "396.png", 31.31, 282.55],
    [399, "399.png", 329.06, 177.05],
    [402, "402.png", 31.31, 33.90],
    [404, "404.png", 31.31, 336.65],
    [407, "407.png", 329.06, 364.85],
    [410, "410.png", 31.31, 125.45],
    [413, "413.png", 329.06, 140.75],
    [415, "415.png", 329.06, 393.45],
    [416, "416-sajda.png", 31.31, 232.09],
    [418, "418.png", 31.31, 96.15],
    [420, "420.png", 31.31, 120.25],
    [422, "422.png", 31.31, 36.70],
    [425, "425.png", 329.06, 44.05],
    [426, "426.png", 31.31, 311.05],
    [429, "429.png", 329.06, 152.05],
    [431, "431.png", 329.06, 88.85],
    [433, "433.png", 329.06, 310.65],
    [436, "436.png", 31.31, 283.25],
    [439, "439.png", 329.06, 177.75],
    [442, "442.png", 31.31, 32.70],
    [443, "443-sakta.png", 329.06, 336.59],
    [444, "444.png", 31.31, 122.35],
    [446, "446.png", 31.31, 392.05],
    [449, "449.png", 329.06, 94.15],
    [451, "451.png", 329.06, 275.70],
    [454, "454-sajda.png", 31.31, 314.09],
    [454, "454.png", 31.31, 122.15],
    [456, "456.png", 31.31, 229.85],
    [459, "459.png", 329.06, 229.55],
    [462, "462.png", 31.31, 35.15],
    [464, "464.png", 31.31, 255.05],
    [467, "467.png", 329.06, 150.35],
    [469, "469.png", 329.06, 176.65],
    [472, "472.png", 31.31, 35.10],
    [474, "474.png", 31.31, 363.95],
    [477, "477.png", 329.06, 284.45],
    [479, "479.png", 329.06, 204.85],
    [480, "480-sajda.png", 31.31, 420.49],
    [482, "482.png", 31.31, 35.10],
    [484, "484.png", 31.31, 122.75],
    [486, "486.png", 31.31, 257.25],
    [488, "488.png", 31.31, 363.85],
    [491, "491.png", 329.06, 88.10],
    [493, "493.png", 329.06, 310.85],
    [496, "496.png", 31.31, 390.55],
    [499, "499.png", 329.06, 364.15],
    [502, "502.png", 31.31, 249.25],
    [505, "505.png", 329.06, 42.25],
    [507, "507.png", 329.06, 364.85],
    [510, "510.png", 31.31, 177.85],
    [513, "513.png", 329.06, 172.50],
    [515, "515.png", 329.06, 260.15],
    [517, "517.png", 329.06, 177.65],
    [519, "519.png", 329.06, 256.65],
    [522, "522.png", 31.31, 36.20],
    [524, "524.png", 31.31, 258.45],
    [526, "526.png", 31.31, 391.15],
    [528, "528-sajda.png", 31.31, 259.09],
    [529, "529.png", 329.06, 69.45],
    [531, "531.png", 329.06, 195.90],
    [534, "534.png", 31.31, 255.05],
    [536, "536.png", 31.31, 391.05],
    [539, "539.png", 329.06, 280.85],
    [542, "542.png", 31.31, 92.15],
    [544, "544.png", 31.31, 148.45],
    [547, "547.png", 329.06, 95.95],
    [550, "550.png", 31.31, 67.05],
    [553, "553.png", 329.06, 91.45],
    [554, "554.png", 31.31, 364.45],
    [558, "558.png", 31.31, 95.65],
    [560, "560.png", 31.31, 94.75],
    [562, "562.png", 31.31, 86.70],
    [564, "564.png", 31.31, 228.55],
    [566, "566.png", 31.31, 338.75],
    [567, "567-sakta.png", 329.06, 334.79],
    [569, "569.png", 329.06, 122.25],
    [572, "572.png", 31.31, 90.05],
    [575, "575.png", 329.06, 41.45],
    [577, "577.png", 329.06, 227.75],
    [578, "578-sakta.png", 31.31, 93.59],
    [579, "579.png", 329.06, 281.05],
    [582, "582.png", 31.31, 90.65],
    [585, "585.png", 329.06, 95.75],
    [587, "587.png", 329.06, 96.75],
    [588, "588-sakta.png", 31.31, 148.44],
    [589, "589.png", 329.06, 149.75],
    [589, "589-sajda.png", 329.06, 395.39],
    [591, "591.png", 329.06, 331.30],
    [594, "594.png", 31.31, 231.05],
    [596, "596.png", 31.31, 412.65],
    [598, "598-sajda.png", 31.31, 99.19],
    [600, "600.png", 31.31, 68.45]
  ];

  Map<int, List<PageHisbSaktaSajda>> processData(List<List<dynamic>> data) {
    Map<int, List<PageHisbSaktaSajda>> pageMap = {};

    // Group the data by page number
    for (var entry in data) {
      int page = entry[0];
      String fileName = entry[1];
      double x = entry[2];
      double y = entry[3];

      PageHisbSaktaSajda pageHisbSaktaSajda = PageHisbSaktaSajda(
        pageNumber: page,
        fileName: fileName,
        x: x,
        y: y,
      );

      // If the page doesn't exist in the map, create a new entry
      if (!pageMap.containsKey(page)) {
        pageMap[page] = [];
      }

      // Add the PageHeader to the respective page
      pageMap[page]!.add(pageHisbSaktaSajda);
    }

    return pageMap;
  }

  String getImageString({
    required int pageNumber,
    required int zoomPercentage,
    required String svgString,
    required double imageWidth,
    required double imageHeight,
    required String base64Image,
    required int currentIndex,
    required int totalImagesToRender,
    bool isMask = false,
    bool isLongMask = false,
    bool isSajdaMask = false,
    double thisX = 0,
    double thisY = 0,
  }) {
    debugPrint('Image Size: width=$imageWidth, height=$imageHeight');

    double x = thisX, y = thisY;

    // Base y-offset calculation
    double yOffset = 300;
    if (totalImagesToRender > 1) {
      yOffset = (200 * currentIndex).toDouble();
    }
    Offset centerCoordinates = Offset(175, yOffset);

    double hisbXOffset = 0; // Adjustment for Hisb alignment
    double maskXOffset = -2; // Adjustment for mask alignment (Fine-tuned)

    if (ZoomService().getZoomEnumFromPercentage(zoomPercentage) ==
        ZoomEnum.extralarge) {
      double alignmentConstant = 0;
      double normalizedX = 0, normalizedY = 0;

      (normalizedX, normalizedY) =
          AyahSvgServiceHelper.fetchNormalizedXY(svgString);
      y = centerCoordinates.dy - normalizedY - imageHeight / 1.5;

      if (pageNumber < 3) {
        x = centerCoordinates.dx - (normalizedX - 5.5);
      } else if (pageNumber % 2 == 0) {
        x = centerCoordinates.dx + 10 - (normalizedX - 5.5) + alignmentConstant;
      } else {
        x = centerCoordinates.dx - 40 - (normalizedX - 5.5) - alignmentConstant;
      }
    } else {
      y = centerCoordinates.dy - imageHeight / 2 - 35;
      x = centerCoordinates.dx;

      if (pageNumber < 3) {
        x = centerCoordinates.dx;
      } else if (pageNumber % 2 == 0) {
        x = centerCoordinates.dx;
      } else {
        x = centerCoordinates.dx - 45;
      }
    }

    if (isMask) {
      y += isLongMask ? 2.5 : (isSajdaMask ? 15 : 9);
      x += maskXOffset; // Fine-tuning mask alignment
      x -= isLongMask ? 17 : 22;
    } else {
      x += hisbXOffset; // Fine-tuning Hisb alignment
    }

    debugPrint(
        'Final Image Position -> Page: $pageNumber, X: $x, Y: $y, Width: $imageWidth, Height: $imageHeight, isMask: $isMask');

    return '<image preserveAspectRatio="none" x="$x" y="$y" width="$imageWidth" height="$imageHeight" class="day" href="data:image/png;base64,$base64Image" />';
  }

  String getSmallImageString({
    required double imageWidth,
    required double imageHeight,
    required double x,
    required double y,
    required String base64Image,
  }) {
    return '<image preserveAspectRatio="none" x="$x" y="$y " width="$imageWidth" height="$imageHeight" class="day" href="data:image/png;base64,$base64Image" />';
  }
}

class PageHisbSaktaSajda {
  final int pageNumber;
  final String fileName;
  final double x;
  final double y;

  PageHisbSaktaSajda({
    required this.pageNumber,
    required this.fileName,
    required this.x,
    required this.y,
  });

  factory PageHisbSaktaSajda.fromRawJson(String str) =>
      PageHisbSaktaSajda.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PageHisbSaktaSajda.fromJson(Map<String, dynamic> json) =>
      PageHisbSaktaSajda(
        pageNumber: json["page_number"],
        fileName: json["file"],
        x: json["x"]?.toDouble(),
        y: json["y"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "page_number": pageNumber,
        "file": fileName,
        "x": x,
        "y": y,
      };
}
