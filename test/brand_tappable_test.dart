import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mysuite/core/widgets/common.dart';
import 'package:mysuite/presentation/shell/app_shell.dart';

import 'brand_theme_test.dart' show pumpBranded;

/// The centre `+` gained a long press for the assistant. A tap must still
/// open Quick Add and only Quick Add, and a hold must do only the other.
void main() {
  testWidgets('BrandTappable separates tap from long press', (tester) async {
    var taps = 0;
    var holds = 0;
    await pumpBranded(
      tester,
      BrandTappable(
        onPressed: () => taps++,
        onLongPress: () => holds++,
        child: const SizedBox(width: 60, height: 60),
      ),
    );

    await tester.tap(find.byType(BrandTappable));
    await tester.pump();
    expect((taps, holds), (1, 0));

    await tester.longPress(find.byType(BrandTappable));
    await tester.pump();
    expect((taps, holds), (1, 1));
  });

  testWidgets('QuickAddButton forwards both gestures', (tester) async {
    var taps = 0;
    var holds = 0;
    await pumpBranded(
      tester,
      QuickAddButton(onPressed: () => taps++, onLongPress: () => holds++),
    );

    await tester.tap(find.byType(QuickAddButton));
    await tester.pump();
    await tester.longPress(find.byType(QuickAddButton));
    await tester.pump();
    expect((taps, holds), (1, 1));
    // The tooltip arms a show-delay timer on the long press; let it run out
    // so the binding does not report it as leaked.
    await tester.pump(const Duration(seconds: 2));
  });
}
