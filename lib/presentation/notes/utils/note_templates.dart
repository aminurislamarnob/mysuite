import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../core/utils/formatters.dart';

/// A starter document for a new note, expressed directly as a Quill delta.
class NoteTemplate {
  final String id;
  final String name;
  final IconData icon;
  final String Function() titleBuilder;
  final List<Map<String, dynamic>> Function() deltaBuilder;

  const NoteTemplate({
    required this.id,
    required this.name,
    required this.icon,
    required this.titleBuilder,
    required this.deltaBuilder,
  });

  String get title => titleBuilder();

  String get contentJson => jsonEncode(deltaBuilder());

  static Map<String, dynamic> _h(String text, int level) =>
      {'insert': '$text\n', 'attributes': {'header': level}};

  static Map<String, dynamic> _p(String text) => {'insert': '$text\n'};

  static Map<String, dynamic> _bullet(String text) =>
      {'insert': '$text\n', 'attributes': {'list': 'bullet'}};

  static Map<String, dynamic> _todo(String text) =>
      {'insert': '$text\n', 'attributes': {'list': 'unchecked'}};

  static final all = <NoteTemplate>[
    NoteTemplate(
      id: 'blank',
      name: 'Blank',
      icon: Icons.article_outlined,
      titleBuilder: () => 'Untitled',
      deltaBuilder: () => [
        {'insert': '\n'}
      ],
    ),
    NoteTemplate(
      id: 'meeting',
      name: 'Meeting notes',
      icon: Icons.groups_outlined,
      titleBuilder: () => 'Meeting — ${Fmt.dayMonth(DateTime.now())}',
      deltaBuilder: () => [
        _h('Meeting notes', 2),
        _p('Date: ${Fmt.fullDate(DateTime.now())}'),
        _p('Attendees: '),
        _h('Agenda', 3),
        _bullet(''),
        _h('Decisions', 3),
        _bullet(''),
        _h('Action items', 3),
        _todo(''),
      ],
    ),
    NoteTemplate(
      id: 'journal',
      name: 'Journal',
      icon: Icons.auto_stories_outlined,
      titleBuilder: () => Fmt.fullDate(DateTime.now()),
      deltaBuilder: () => [
        _h('How was today?', 3),
        _p(''),
        _h('Three good things', 3),
        _bullet(''),
        _h('Tomorrow', 3),
        _todo(''),
      ],
    ),
    NoteTemplate(
      id: 'daily',
      name: 'Daily log',
      icon: Icons.today_outlined,
      titleBuilder: () => 'Daily log — ${Fmt.dayMonth(DateTime.now())}',
      deltaBuilder: () => [
        _h('Priorities', 3),
        _todo(''),
        _h('Notes', 3),
        _p(''),
      ],
    ),
    NoteTemplate(
      id: 'shopping',
      name: 'Shopping list',
      icon: Icons.shopping_cart_outlined,
      titleBuilder: () => 'Shopping list',
      deltaBuilder: () => [
        _h('Shopping list', 3),
        _todo(''),
        _todo(''),
        _todo(''),
      ],
    ),
    NoteTemplate(
      id: 'idea',
      name: 'Idea',
      icon: Icons.lightbulb_outline,
      titleBuilder: () => 'Idea',
      deltaBuilder: () => [
        _h('The idea', 3),
        _p(''),
        _h('Why it matters', 3),
        _p(''),
        _h('Next steps', 3),
        _todo(''),
      ],
    ),
    NoteTemplate(
      id: 'recipe',
      name: 'Recipe',
      icon: Icons.restaurant_menu_outlined,
      titleBuilder: () => 'Recipe',
      deltaBuilder: () => [
        _h('Ingredients', 3),
        _bullet(''),
        _h('Method', 3),
        _p('1. '),
      ],
    ),
  ];
}
