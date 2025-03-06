import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qeraat_moshaf_kwait/features/externalLibraries/presentation/screens/external_libraries_screen.dart';
import 'package:qeraat_moshaf_kwait/features/externalLibraries/presentation/screens/new_external_liberary_screen.dart';

void main() {
  group('External libraries test UI', () {
    testWidgets('External Library test', (WidgetTester tester) async {
      await tester
          .pumpWidget(const MaterialApp(home: NewExternalLibrariesScreen()));
      expect(find.text('Hello'), findsOneWidget);
    });
  });
}
