import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image/image.dart' as DartImage;
import 'package:path_provider/path_provider.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/assets_manager.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';

import '../../../../core/utils/app_strings.dart';
import '../../../../core/utils/constants.dart';
import '../../../essential_moshaf_feature/data/models/ayat_swar_models.dart';

shareAyahAsImage(BuildContext context, {required AyahModel ayah}) async {
  try {
    ScreenshotController screenshotController = ScreenshotController();

    Uint8List imageBytes = await screenshotController.captureFromWidget(
      Material(
        child: Center(
          child: ScreenshotWidget(ayah: ayah),
        ),
      ),
      context: context,
      delay: const Duration(milliseconds: 1000),
    );

    var dir = (Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationSupportDirectory())!;
    File screenshotFile = File("${dir.path}/screenshot.png")
      ..createSync(recursive: true);
    await screenshotFile.writeAsBytes(imageBytes);

    DartImage.Image? imageData =
        DartImage.decodeImage(screenshotFile.readAsBytesSync());
    if (imageData == null) return;

    DartImage.Image resizedImage = DartImage.copyResize(imageData, width: 1024);
    File resizedScreenshotFile = File("${dir.path}/resizedScreenshot.png")
      ..createSync(recursive: true)
      ..writeAsBytesSync(DartImage.encodePng(resizedImage));

    await Share.shareFiles([resizedScreenshotFile.path],
        subject: "مصحف دولة الكويت للقراءات العشر \n ${AppStrings.appUrl}");
  } catch (e) {
    AppConstants.showToast(context,
        msg: context.translate.something_went_wrong);
  }
}

class ScreenshotWidget extends StatelessWidget {
  const ScreenshotWidget({
    super.key,
    required this.ayah,
  });
  final AyahModel ayah;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.white,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMetadataRow(context, ayah),
            const SizedBox(height: 20),
            _buildAyahText(context, ayah),
            const SizedBox(height: 20),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildMetadataRow(BuildContext context, AyahModel ayah) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildMetadataItem(
          context,
          AppAssets.pageMetadataFrame,
          AppAssets.getSurahName(ayah.surahNumber!),
        ),
        _buildMetadataItem(
          context,
          AppAssets.pageMetadataFrame,
          AppAssets.getJuzName(ayah.juz!),
        ),
      ],
    );
  }

  Widget _buildMetadataItem(
      BuildContext context, String frameAsset, String contentAsset) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SvgPicture.asset(
          frameAsset,
          width: 170,
          fit: BoxFit.fitWidth,
        ),
        Container(
          margin: const EdgeInsets.only(top: 10),
          height: 30,
          child: SvgPicture.asset(contentAsset, height: 22),
        ),
      ],
    );
  }

  Widget _buildAyahText(BuildContext context, AyahModel ayah) {
    return SingleChildScrollView(
      child: RichText(
        textAlign: TextAlign.justify,
        text: TextSpan(
          children: [
            TextSpan(
              text: ayah.text ?? '',
              style: context.textTheme.bodyMedium!.copyWith(
                color: Colors.black,
                fontSize: 40,
                height: 1.9,
                fontWeight: FontWeight.w100,
                fontFamily: AppStrings.amiriFontFamily,
              ),
            ),
            TextSpan(
              text:
                  ' ${String.fromCharCode(ayah.numberInSurah! + AppConstants.ayahNumberUnicodeStarter)}',
              style: context.textTheme.bodyMedium!.copyWith(
                color: Colors.black,
                fontSize: 45,
                fontWeight: FontWeight.w100,
                fontFamily: AppStrings.uthmanicAyatNumbersFontFamily,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      color: const Color(0xFFF7F5F2),
      child: SvgPicture.asset(
        AppAssets.qsaLogoWithMoshafSloganForImageShare,
        height: 60,
      ),
    );
  }
}
