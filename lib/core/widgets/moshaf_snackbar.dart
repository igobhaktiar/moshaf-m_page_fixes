import 'package:flutter/material.dart';

class MoshafSnackbar {
  MoshafSnackbar._();
  static void triggerSnackbar(
    BuildContext context, {
    required String text,
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          text,
          textAlign: TextAlign.center,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
