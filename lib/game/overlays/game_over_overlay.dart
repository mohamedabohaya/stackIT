import 'package:flutter/material.dart';

import '../stack_it_game.dart';

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({super.key, required this.game});

  final StackItGame game;

  @override
  Widget build(BuildContext context) {
    final isNewBest = game.score > 0 && game.score >= game.bestScore;

    return Container(
      color: Colors.black.withValues(alpha: 0.55),
      alignment: Alignment.center,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 40),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 28),
        decoration: BoxDecoration(
          color: const Color(0xFF232752),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'GAME OVER',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${game.score}',
              style: const TextStyle(
                color: Colors.amberAccent,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            if (isNewBest)
              const Text(
                'NEW BEST!',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              )
            else
              Text(
                'Best: ${game.bestScore}',
                style: const TextStyle(color: Colors.white70),
              ),
            if (game.score > 0) ...[
              const SizedBox(height: 8),
              Text(
                '+${game.score} 🪙',
                style: const TextStyle(
                  color: Colors.amberAccent,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: game.retry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amberAccent,
                  foregroundColor: const Color(0xFF232752),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'RETRY',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'HOME',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
