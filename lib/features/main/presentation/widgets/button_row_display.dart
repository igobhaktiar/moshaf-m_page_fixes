import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';

import '../../../../core/utils/assets_manager.dart';

class ButtonRowDisplay extends StatelessWidget {
  const ButtonRowDisplay({
    super.key,
    this.icon,
    required this.title,
    this.subtitle,
    this.height,
    required this.isChecked,
  });

  final String title;
  final String? icon, subtitle;
  final double? height;
  final bool isChecked;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (icon != null) ...[
                ClipOval(
                    child: Container(
                  height: 25,
                  width: 25,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    icon!,
                    height: 18,
                    color: context.theme.primaryIconTheme.color,
                  ),
                )),
                const SizedBox(
                  width: 15,
                ),
              ],
              Flexible(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: context.textTheme.bodyMedium,
                    ),
                    if (height != null)
                      SizedBox(
                        height: height,
                      ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: context.textTheme.displaySmall,
                      )
                  ],
                ),
              ),
            ],
          ),
        ),
        if (isChecked)
          SvgPicture.asset(
            AppAssets.checkMark,
            color: context.theme.primaryIconTheme.color,
          ),
      ],
    );
  }
}
