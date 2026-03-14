// Basic Flutter widget test for Global Gather app.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:globalevents_frontend/app.dart';

void main() {
  testWidgets('App builds without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: GlobalEventsApp(),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
