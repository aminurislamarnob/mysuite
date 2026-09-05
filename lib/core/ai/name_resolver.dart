/// A match and how confident it is. Exact matches need no warning on the
/// preview card; a substring or hint match is worth pointing out.
class Resolved<T> {
  final T item;
  final bool exact;

  const Resolved(this.item, {required this.exact});
}

/// Matches a spoken or model-written name against the user's own rows.
///
/// Never creates anything: an unmatched name comes back null and the caller
/// decides what the fallback is and whether to warn. Order of preference is
/// case-insensitive equality, then containment either way (so "bkash
/// account" finds "bKash" and "Food" finds "Food & drink"), then hint words
/// such as "lunch" for Food, checked against [haystack] when given so the
/// offline parser can match against the whole clause.
class NameResolver {
  const NameResolver._();

  static Resolved<T>? resolve<T>(
    String? query,
    List<T> items,
    List<String> Function(T) namesOf, {
    Map<String, List<String>> hints = const {},
    String? haystack,
  }) {
    final q = query?.trim().toLowerCase() ?? '';
    if (q.isNotEmpty) {
      for (final item in items) {
        if (namesOf(item).any((n) => n.trim().toLowerCase() == q)) {
          return Resolved(item, exact: true);
        }
      }
      T? best;
      var bestLength = 0;
      for (final item in items) {
        for (final name in namesOf(item)) {
          final n = name.trim().toLowerCase();
          if (n.isEmpty) continue;
          if ((q.contains(n) || n.contains(q)) && n.length > bestLength) {
            best = item;
            bestLength = n.length;
          }
        }
      }
      if (best != null) return Resolved(best, exact: false);
    }

    final text = (haystack ?? query)?.toLowerCase();
    if (text == null || text.isEmpty) return null;
    for (final entry in hints.entries) {
      for (final word in entry.value) {
        if (!RegExp('\\b${RegExp.escape(word)}').hasMatch(text)) continue;
        final canonical = entry.key.toLowerCase();
        for (final item in items) {
          if (namesOf(item).any((n) => n.trim().toLowerCase() == canonical)) {
            return Resolved(item, exact: false);
          }
        }
      }
    }
    return null;
  }
}
