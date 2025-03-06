import 'package:flutter/material.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? colorLow, colorHigh;

  const GradientButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.colorHigh,
    this.colorLow,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.isDarkMode ? Colors.white : colorHigh ?? Colors.black,
              context.isDarkMode ? Colors.white : colorLow ?? Colors.white,
            ], // Customize colors here
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: context.isDarkMode ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }
}
