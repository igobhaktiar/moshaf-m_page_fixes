import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/core/utils/app_context.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/data/data_sources/moshaf_hisb_sakta_sajda_service.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/essential_moshaf_cubit.dart';
import 'package:qeraat_moshaf_kwait/features/essential_moshaf_feature/presentation/cubit/zoom_cubit/zoom_enum.dart';

class HizbAnimatedDialog extends StatelessWidget {
  final int zoomPercentage;

  const HizbAnimatedDialog({super.key, required this.zoomPercentage});

  @override
  Widget build(BuildContext context) {
    final cubit = EssentialMoshafCubit.get(context);
    final isRight = (cubit.currentPage + 1) % 2 == 0;
    bool showAnimation =
        MoshafHisbSaktaSajdaService().doesPageHasHizb(cubit.currentPage + 1);

    if (!showAnimation) return const SizedBox();

    return Stack(
      children: [
        Positioned.fill(
          child: AnimatedHizbIcon(
              key: ValueKey('hizb_${cubit.currentPage}'),
              moveRight: isRight,
              zoomPercentage: zoomPercentage),
        ),
      ],
    );
  }
}

class AnimatedHizbIcon extends StatefulWidget {
  final bool moveRight;
  final int zoomPercentage;

  const AnimatedHizbIcon(
      {Key? key, required this.moveRight, required this.zoomPercentage})
      : super(key: key);

  @override
  _AnimatedHizbIconState createState() => _AnimatedHizbIconState();
}

class _AnimatedHizbIconState extends State<AnimatedHizbIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _fadeAnimation;
  double screenWidth = 0;
  bool _isAnimating = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 4000), // Reduced duration
      vsync: this,
    );

    // Start the animation immediately in initState
    _controller.forward().then((_) {
      if (mounted) {
        setState(() {
          _isAnimating = false;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;

    _animation = Tween<double>(
      begin: widget.moveRight ? -150.0 : screenWidth + 150,
      end: widget.moveRight ? screenWidth + 150 : -150.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut, // Changed to easeOut for quicker start
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.2, curve: Curves.easeOut), // Adjusted timing
    ));
  }

  @override
  Widget build(BuildContext context) {
    int currentPage = EssentialMoshafCubit.get(context).currentPage + 1;
    MoshafHisbSaktaSajdaService moshafHisbSaktaSajdaService =
        MoshafHisbSaktaSajdaService();
    String? maskName = moshafHisbSaktaSajdaService.getMask(
      currentPage,
      isDark: AppContext.getAppContext()!.isDarkMode,
    );
    String maskPath = getMaskFullString(maskName);
    MaskType maskType = moshafHisbSaktaSajdaService.getMaskType(currentPage);
    String hizbPath = moshafHisbSaktaSajdaService.getHizbPath(currentPage);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if ((!_isAnimating || maskPath.isEmpty || hizbPath.isEmpty)) {
          return const SizedBox();
        }

        return Positioned(
          left: _animation.value,
          top: MediaQuery.of(context).size.height *
              (maskType == MaskType.longMask ? 0.25 : 0.3),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.asset(
                  maskPath,
                  fit: BoxFit.contain,
                ),
                Image.asset(
                  hizbPath,
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
