import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';

class BottomOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  final bool isBold;

  const BottomOption({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.25,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color,
              child: Icon(
                icon,
                size: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: isBold ? null : FontWeight.w600,
                color: context.isDarkMode ? Colors.white : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
