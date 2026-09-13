import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';

/// A small satisfying burst of particles shown when a block lands successfully.
Component createStackParticles({required Vector2 position, required Color color}) {
  final random = Random();
  return ParticleSystemComponent(
    position: position,
    particle: Particle.generate(
      count: 12,
      lifespan: 0.55,
      generator: (i) {
        final angle = random.nextDouble() * pi * 2;
        final speed = 50 + random.nextDouble() * 90;
        return AcceleratedParticle(
          acceleration: Vector2(0, 260),
          speed: Vector2(cos(angle), sin(angle)) * speed,
          child: CircleParticle(
            radius: 1.5 + random.nextDouble() * 2,
            paint: Paint()..color = color.withValues(alpha: 0.9),
          ),
        );
      },
    ),
  );
}
