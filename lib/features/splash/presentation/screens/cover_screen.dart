import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qeraat_moshaf_kwait/core/utils/assets_manager.dart';
import 'package:qeraat_moshaf_kwait/core/utils/mediaquery_values.dart';

import '../../../../config/app_config/app_config.dart';
import '../../../drawer/data/data_sources/drawer_constants.dart';
import '../../../essential_moshaf_feature/presentation/screens/ordinary_moshaf_main_screen.dart';

class CoverScreen extends StatefulWidget {
  const CoverScreen({super.key});

  @override
  State<CoverScreen> createState() => _CoverScreenState();
}

class _CoverScreenState extends State<CoverScreen> {
  bool isToShowSponsorView = false;
  bool showLoadingScreen = true;
  @override
  void initState() {
    // return;
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        showLoadingScreen = false;
      });
      FlutterNativeSplash.remove();
      _navigateToNextPage();
    });
  }

  _navigateToNextPage() {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const OrdinaryMoshafMainScreen(),
          transitionDuration: Duration.zero, // No transition duration
          reverseTransitionDuration:
              Duration.zero, // No reverse transition duration
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: context.height,
            width: context.width,
            decoration: const BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(AppAssets.patternBgWithTextBehind))),
            child: const SplashView(),

            // !isToShowSponsorView
            //     ? FadeOut(
            //         delay: const Duration(seconds: 6), child: const SplashView())
            //     : FadeIn(child: const SpnonsorView()),
          ),
          // if (showLoadingScreen)
          //   Container(
          //     height: context.height,
          //     width: context.width,
          //     decoration: const BoxDecoration(
          //       color: Colors.white,
          //     ),
          //     child: Center(
          //       child: Image.asset(
          //         AppAssets.appIcon,
          //         fit: BoxFit.contain,
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
}

class SplashView extends StatelessWidget {
  const SplashView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            SvgPicture.asset(
              AppAssets.upperDecoration,
              width: context.width,
            ),
            const Spacer(),
            const Spacer(),
            SvgPicture.asset(
              AppAssets.lowerDecoration,
              width: context.width,
            ),
          ],
        ),

        // SvgPicture.asset(
        //   AppAssets.hollyQuran,
        //   height: context.height / 3.5,
        //   // height: context.height / 2.6,
        // ),
        if (AppConfig.isQeeratView()) ...[
          Positioned(
            bottom: context.height * 0.28,
            child: Column(
              children: [
                SvgPicture.asset(
                  AppAssets.hollyQuran,
                  height: context.height / 3.5,
                  // height: context.height / 2.6,
                ),
                const SizedBox(
                  height: 15,
                ),
                SvgPicture.asset(
                  AppAssets.qeeratSplashText,
                  height: context.height / 7,
                  width: context.width,
                ),
              ],
            ),
          ),
        ] else
          Image.asset(
            DrawerConstants.drawerLogo,
            fit: BoxFit.cover,
            height: context.height / 2.4,
            width: context.width,
          ),
        Positioned(
          bottom: context.height * 0.2,
          child: Column(
            children: [
              // SvgPicture.asset(
              //   AppAssets.forTenReadings,
              // ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  AppConfig.getAppVersionToShow(),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class SpnonsorView extends StatelessWidget {
  const SpnonsorView({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Spacer(
          flex: 3,
        ),
        SvgPicture.asset(
          AppAssets.qsaVertical,
          height: context.height / 4,
        ),
        const SizedBox(height: 30),
        Container(
          padding: EdgeInsets.symmetric(horizontal: context.width / 5),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: const LinearProgressIndicator(
              minHeight: 6,
              color: Color(0xffB9AA95),
              backgroundColor: Color(0xffF4EBDC),
            ),
          ),
        ),
        const Spacer(
          flex: 2,
        ),
        SvgPicture.asset(AppAssets.bobyanSponsor),
        const SizedBox(height: 5),
        Center(
          child: Text(
            AppConfig.getAppVersionToShow(),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
