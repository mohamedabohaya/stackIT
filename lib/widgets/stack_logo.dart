import 'package:flutter/material.dart';

/// A small static illustration of stacked blocks, reused by the splash
/// and home screens to echo the in-game block style without needing
/// custom art assets.
class StackLogo extends StatelessWidget {
  const StackLogo({super.key, this.scale = 1});

  final double scale;

  /// Bars from top (narrowest) to bottom (widest), matching the in-game
  /// stack orientation. Shared with the splash screen's drop-in animation.
  static const bars = <(Color, double)>[
    (Color(0xFFC6E85A), 86.0),
    (Color(0xFFFFA630), 118.0),
    (Color(0xFFEF476F), 150.0),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final (color, width) in bars)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: LogoBar(color: color, width: width * scale),
          ),
      ],
    );
  }
}

/// One rounded, gradient-shaded stack bar. Public so the splash screen can
/// animate the same visual bars independently.
class LogoBar extends StatelessWidget {
  const LogoBar({super.key, required this.color, required this.width});

  final Color color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 34,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [color, Color.lerp(color, Colors.black, 0.18)!],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
    );
  }
}
