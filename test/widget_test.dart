import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pet_diary/main.dart';

void main() {
  testWidgets('Petiary smoke test', (WidgetTester tester) async {
    // Active app
    await tester.pumpWidget(MainClass());
  });
}
