import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:mysuite/core/theme/app_forui_theme.dart';
import 'package:mysuite/core/theme/app_theme.dart';
import 'package:mysuite/core/widgets/common.dart';

Widget _host(Widget child) => MaterialApp(
  theme: AppTheme.light(),
  home: FTheme(
    data: brandForuiTheme(brightness: Brightness.light),
    child: Scaffold(body: Align(alignment: Alignment.topCenter, child: child)),
  ),
);

void main() {
  testWidgets('prefix sits on the tile inset, not flush to the border', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const BrandField(
          hint: 'Amount',
          prefix: Text('\$', key: Key('prefix')),
          suffix: Icon(Icons.close, key: Key('suffix')),
        ),
      ),
    );

    final field = tester.getRect(find.byType(FTextField));
    final prefix = tester.getRect(find.byKey(const Key('prefix')));
    final suffix = tester.getRect(find.byKey(const Key('suffix')));

    expect(prefix.left - field.left, BrandField.affixInset);
    expect(field.right - suffix.right, BrandField.affixInset);
  });

  testWidgets('prefix and leading tile glyph share an inset', (tester) async {
    await tester.pumpWidget(
      _host(
        const Column(
          children: [
            BrandField(prefix: Text('\$', key: Key('prefix'))),
            BrandTile(
              title: Text('Category'),
              leading: Icon(Icons.category, key: Key('leading')),
            ),
          ],
        ),
      ),
    );

    final prefix = tester.getRect(find.byKey(const Key('prefix')));
    final leading = tester.getRect(find.byKey(const Key('leading')));
    expect(prefix.left, leading.left);
  });
}
