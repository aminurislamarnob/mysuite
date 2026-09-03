import 'dart:io';

import 'package:flutter/material.dart';

import '../theme/app_icons.dart';

/// A person's photo, or a coloured circle standing in for one.
///
/// Takes the pieces rather than a `Person` so the dashboard's greeting — which
/// knows initials, not rows — can use the same circle.
class PersonAvatar extends StatelessWidget {
  /// A file under the avatar store. Null, or missing on disk, falls back.
  final String? photoPath;

  /// Tints the fallback circle; ignored once there is a photo.
  final Color color;
  final double size;

  /// Drawn when there is no photo. Defaults to a person glyph.
  final Widget? fallback;

  const PersonAvatar({
    super.key,
    required this.photoPath,
    required this.color,
    this.size = 40,
    this.fallback,
  });

  @override
  Widget build(BuildContext context) {
    final path = photoPath;
    // A file can go missing under us — cleared storage, a restored backup that
    // carried the row but not the image — so the fallback is not only for
    // people who never set one.
    if (path != null && File(path).existsSync()) {
      return ClipOval(
        child: Image.file(
          File(path),
          width: size,
          height: size,
          fit: BoxFit.cover,
          // Bound the decode to what is actually drawn; these are 512px files
          // rendered into 40px circles.
          cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
          errorBuilder: (context, _, _) => _placeholder(context),
        ),
      );
    }
    return _placeholder(context);
  }

  Widget _placeholder(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.14),
      shape: BoxShape.circle,
    ),
    child:
        fallback ?? AppIcon(AppIcons.person, color: color, size: size * 0.45),
  );
}
