import 'package:flutter/material.dart';

import '../stack_it_game.dart';

/// Always-visible current score / best score readout pinned to the top.
class ScoreOverlay extends StatelessWidget {
  const ScoreOverlay({super.key, required this.game});

  final StackItGame game;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ValueListenableBuilder<int>(
              valueListenable: game.scoreNotifier,
              builder: (context, score, _) => _ScorePill(label: 'SCORE', value: score),
            ),
            ValueListenableBuilder<int>(
              valueListenable: game.bestScoreNotifier,
              builder: (context, best, _) => _ScorePill(label: 'BEST', value: best),
            ),
          ],
        ),
      ),
    );
  }
}

class _ScorePill extends StatelessWidget {
  const _ScorePill({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          Text(
            '$value',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
