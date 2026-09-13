import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

import 'block_component.dart';

/// The offcut of a block that didn't overlap the stack below it.
/// Tumbles and fades away for a bit of visual polish, then removes itself.
class FallingPieceComponent extends PositionComponent {
  FallingPieceComponent({
    required super.position,
    required super.size,
    required this.color,
  }) : _spinSpeed = (Random().nextBool() ? 1 : -1) * (1.5 + Random().nextDouble() * 2),
       super(anchor: Anchor.topLeft);

  final Color color;
  final double _spinSpeed;

  double _velocityY = -60;
  double _opacity = 1;

  static const double _gravity = 1500;

  @override
  void update(double dt) {
    super.update(dt);
    _velocityY += _gravity * dt;
    position.y += _velocityY * dt;
    angle += _spinSpeed * dt;
    _opacity -= dt * 1.6;
    if (_opacity <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    final rect = Rect.fromLTWH(0, 0, size.x, size.y);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(BlockComponent.cornerRadius));
    canvas.drawRRect(rrect, Paint()..color = color.withValues(alpha: _opacity.clamp(0, 1)));
  }
}
