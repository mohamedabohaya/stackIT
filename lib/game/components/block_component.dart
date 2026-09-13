import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flutter/material.dart' show Alignment, Colors, HSLColor, LinearGradient;

/// A single stacked (or currently moving) block.
///
/// Drawn manually (rounded rect + soft shadow + top highlight) instead of an
/// image asset, per the "no custom art yet" constraint for this prototype.
class BlockComponent extends PositionComponent {
  BlockComponent({
    required super.position,
    required super.size,
    required this.color,
  }) : super(anchor: Anchor.topLeft);

  final Color color;

  static const double cornerRadius = 10;

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(cornerRadius));

    canvas.drawRRect(
      rrect.shift(const Offset(0, 5)),
      Paint()..color = Colors.black.withValues(alpha: 0.22),
    );

    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color, _darken(color, 0.14)],
      ).createShader(rect);
    canvas.drawRRect(rrect, bodyPaint);

    if (size.x > 12 && size.y > 10) {
      final highlightRect = Rect.fromLTWH(
        4,
        3,
        (size.x - 8).clamp(0, size.x),
        (size.y * 0.3).clamp(0, size.y),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(highlightRect, const Radius.circular(6)),
        Paint()..color = Colors.white.withValues(alpha: 0.20),
      );
    }
  }

  static Color _darken(Color c, double amount) {
    final hsl = HSLColor.fromColor(c);
    final darker = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return darker.toColor();
  }
}
