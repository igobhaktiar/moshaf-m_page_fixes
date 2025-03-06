import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:qeraat_moshaf_kwait/config/themes/theme_context.dart';

class CustomerColorPicker extends StatelessWidget {
  const CustomerColorPicker({
    super.key,
    required this.moshafColor,
    required this.isSelectedFromPreviousList,
    required this.onChange,
  });
  final Color moshafColor;
  final bool isSelectedFromPreviousList;
  final Function(Color) onChange;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        HueRingPicker(
          pickerColor: moshafColor,
          onColorChanged: (value) => onChange(value),
          portraitOnly: true,
        ),
        Positioned(
          top: 300,
          left: 25,
          child: ClipOval(
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelectedFromPreviousList
                      ? context.theme.cardColor
                      : Colors.red, // Red border
                  width: 2.0, // Thickness of the border
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
