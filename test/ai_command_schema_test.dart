import 'package:flutter_test/flutter_test.dart';
import 'package:mysuite/core/ai/ai_action.dart';
import 'package:mysuite/core/ai/ai_command_schema.dart';

/// The schema is what every provider's strict mode validates against, so
/// the properties it promises have to be the ones the parser reads, and the
/// shape has to satisfy the strictest validator (OpenAI's).
void main() {
  void expectStrict(Map<String, Object?> object, String where) {
    expect(object['type'], 'object', reason: where);
    expect(object['additionalProperties'], isFalse, reason: where);
    final props = object['properties'] as Map;
    final required = object['required'] as List;
    expect(
      required.toSet(),
      props.keys.toSet(),
      reason: '$where: strict mode needs every property in required',
    );
  }

  test('root and action objects are strict', () {
    final root = AiCommandSchema.root;
    expectStrict(root, 'root');
    final actions = (root['properties'] as Map)['actions'] as Map;
    expectStrict(Map<String, Object?>.from(actions['items'] as Map), 'action');
  });

  test('kind enum lists exactly the action kinds', () {
    final kind = (AiCommandSchema.action['properties'] as Map)['kind'] as Map;
    expect(kind['enum'], AiActionKind.values.map((k) => k.wire).toList());
  });

  test('every non-kind field is nullable', () {
    final props = AiCommandSchema.action['properties'] as Map;
    for (final entry in props.entries) {
      if (entry.key == 'kind') continue;
      final type = (entry.value as Map)['type'];
      expect(type, contains('null'), reason: entry.key);
    }
  });

  test('the tool catalogue has one strict tool per kind', () {
    final tools = AiCommandSchema.tools;
    expect(tools.map((t) => t.name), AiActionKind.values.map((k) => k.wire));
    for (final tool in tools) {
      expectStrict(tool.inputSchema, tool.name);
      expect(tool.description, isNotEmpty);
    }
    final expense = tools.firstWhere((t) => t.name == 'add_expense');
    expect((expense.inputSchema['properties'] as Map).keys, contains('amount'));
    expect(
      (expense.inputSchema['properties'] as Map).keys,
      isNot(contains('focus_minutes')),
    );
  });

  test('openApiSubset drops additionalProperties and unions', () {
    final subset = AiCommandSchema.openApiSubset(AiCommandSchema.root);
    void walk(Object? node) {
      if (node is Map) {
        expect(node.containsKey('additionalProperties'), isFalse);
        final type = node['type'];
        expect(type is List, isFalse, reason: 'unions must be flattened');
        node.values.forEach(walk);
      } else if (node is List) {
        node.forEach(walk);
      }
    }

    walk(subset);
    final items =
        ((subset['properties'] as Map)['actions'] as Map)['items'] as Map;
    final amount = (items['properties'] as Map)['amount'] as Map;
    expect(amount['type'], 'number');
    expect(amount['nullable'], isTrue);
  });
}
