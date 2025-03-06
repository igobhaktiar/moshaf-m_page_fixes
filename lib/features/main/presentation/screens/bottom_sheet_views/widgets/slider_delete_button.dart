import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';
import 'package:qeraat_moshaf_kwait/l10n/localization_context.dart';

import '../../../../../../core/utils/app_colors.dart';
import '../../../../../../core/utils/assets_manager.dart';

class SliderDeleteButton extends StatelessWidget {
  const SliderDeleteButton({
    super.key,
    required this.child,
    this.onDeletePressed,
    this.enabled,
  });
  final Widget child;
  final VoidCallback? onDeletePressed;
  final bool? enabled;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      enabled: (enabled != null) ? (enabled!) : true,
      closeOnScroll: true,
      key: const ValueKey(0),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          Expanded(
            child: Container(
              color: context.theme.brightness == Brightness.dark
                  ? context.theme.scaffoldBackgroundColor
                  : const Color(0xFFFEF2F2),
              // width: double.infinity,

              child: Align(
                child: Builder(
                  builder: (ctx) {
                    return InkWell(
                      onTap: onDeletePressed,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          SvgPicture.asset(
                            AppAssets.delete,
                            color: Colors.red,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            context.translate.delete,
                            style: const TextStyle(
                                fontSize: 16,
                                height: 1.4,
                                color: AppColors.red,
                                fontWeight: FontWeight.w500),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                // alignment: Alignment.,
              ),
            ),
          )
        ],
      ),
      child: child,
    );
  }
}
