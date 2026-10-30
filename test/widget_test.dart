import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:uzum_meva/main.dart';
import 'package:uzum_meva/services/data_store.dart';

void main() {
  testWidgets('MevaApp smoke test', (WidgetTester tester) async {
    final store = LocalDataStore();
    // Build our app and trigger a frame.
    await tester.pumpWidget(MevaApp(store: store));

    // Verify that MaterialApp is present.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
