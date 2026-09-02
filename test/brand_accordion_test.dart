import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forui/forui.dart';
import 'package:mysuite/core/theme/app_forui_theme.dart';
import 'package:mysuite/core/theme/app_theme.dart';
import 'package:mysuite/core/widgets/common.dart';

/// A page that rebuilds a *fresh* forui theme on every build, the way
/// `MaterialApp.builder` does whenever a setting changes.
class _Host extends StatefulWidget {
  const _Host();

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  int _builds = 0;

  @override
  Widget build(BuildContext context) {
    _builds++;
    return MaterialApp(
      theme: AppTheme.light(),
      home: FTheme(
        // Deliberately not `brandForuiTheme`, which is memoised: this is the
        // worst case, a genuinely new style object above the accordion.
        data: brandForuiThemeFrom(AppTheme.tokens(brightness: Brightness.light)),
        child: Scaffold(
          // Top-aligned so the accordion sizes to its content rather than
          // being stretched to the viewport, which is what makes its height
          // readable as "open" or "closed".
          body: Align(
            alignment: Alignment.topLeft,
            child: BrandAccordion(
              title: 'Lock individual modules',
              child: Column(
                children: [
                  Text('rebuilds: $_builds'),
                  TextButton(
                    onPressed: () => setState(() {}),
                    child: const Text('toggle a switch'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('BrandAccordion stays open when the page above it rebuilds',
      (tester) async {
    // forui's managed accordion item resets its reveal animation to
    // `initiallyExpanded` in didChangeDependencies, so any inherited change
    // above it snapped the panel shut. In Settings that meant flipping a
    // module-lock switch closed the list the switch was sitting in.
    await tester.pumpWidget(const _Host());

    final collapsed = tester.getSize(find.byType(FAccordionItem)).height;

    await tester.tap(find.text('Lock individual modules'));
    await tester.pumpAndSettle();
    final expanded = tester.getSize(find.byType(FAccordionItem)).height;
    expect(expanded, greaterThan(collapsed));

    // A rebuild from inside the panel, which is what the switches do.
    await tester.tap(find.text('toggle a switch'));
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(FAccordionItem)).height, expanded);
    expect(find.text('rebuilds: 2'), findsOneWidget);
  });

  testWidgets('BrandAccordion still opens and closes on tap', (tester) async {
    await tester.pumpWidget(const _Host());

    final collapsed = tester.getSize(find.byType(FAccordionItem)).height;

    await tester.tap(find.text('Lock individual modules'));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.byType(FAccordionItem)).height,
      greaterThan(collapsed),
    );

    await tester.tap(find.text('Lock individual modules'));
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byType(FAccordionItem)).height, collapsed);
  });
}
