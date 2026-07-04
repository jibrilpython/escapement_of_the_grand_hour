import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:escapement_of_the_grand_hour/main.dart';

void main() {
  testWidgets('app boots to horological experience', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'egh_user_v1': false});
    final prefs = await SharedPreferences.getInstance();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(child: MyApp(preferences: prefs)),
    );
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.textContaining('Escapement'), findsWidgets);
  });
}
