import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:qeraat_moshaf_kwait/features/qeerat/cubit/qeera_cubit.dart';
import 'package:xml/xml.dart';

void updateQeraatStyles(XmlDocument document, BuildContext context) {
  final qaraaList = context.read<QeraatCubit>().state;

  // Iterate over each element with the 'qeraat' class
  final elementsWithClassQeraat = document
      .findAllElements('svg')
      .firstOrNull
      ?.descendants
      .whereType<XmlElement>()
      .where((element) {
    final classAttribute = element.getAttribute('class');
    return classAttribute != null &&
        classAttribute.split(' ').contains('qeraat');
  }).toList();

  if (elementsWithClassQeraat != null && elementsWithClassQeraat.isNotEmpty) {
    for (var element in elementsWithClassQeraat) {
      final classAttribute = element.getAttribute('class');
      for (var qaraa in qaraaList) {
        if ((classAttribute?.split(' ').contains(qaraa.imam1.id) ?? false) &&
            qaraa.imam1.isEnabled) {
          element.setAttribute("style", "stroke: red; stroke-width: 1;");
        } else if ((classAttribute?.split(' ').contains(qaraa.imam2.id) ??
                false) &&
            qaraa.imam2.isEnabled) {
          element.setAttribute("style", "stroke: red; stroke-width: 1;");
        }
      }
    }
  }
}
