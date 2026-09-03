import 'package:flutter_test/flutter_test.dart';
import 'package:mysuite/core/utils/formatters.dart';

void main() {
  group('Fmt.initials', () {
    test('one name gives one letter', () {
      expect(Fmt.initials('Aminur'), 'A');
    });

    test('two names give first and last', () {
      expect(Fmt.initials('Aminur Islam'), 'AI');
    });

    test('a middle name is skipped, not taken over the surname', () {
      expect(Fmt.initials('Md. Aminur Islam'), 'MI');
    });

    test('always upper case, whatever was typed', () {
      expect(Fmt.initials('aminur islam'), 'AI');
    });

    test('extra whitespace does not become an initial', () {
      expect(Fmt.initials('  Aminur   Islam  '), 'AI');
    });

    test('an unset name yields nothing, so the caller draws a glyph', () {
      expect(Fmt.initials(''), isEmpty);
      expect(Fmt.initials('   '), isEmpty);
    });

    test('non-latin names keep their own first characters', () {
      expect(Fmt.initials('আমিনুর ইসলাম'), 'আই');
    });
  });
}
