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
            if (isNewBest) ...[
              const SizedBox(height: 4),
              const Text(
                '+1 ❤️ for the new record!',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 24),
            ValueListenableBuilder<int>(
              valueListenable: game.heartsNotifier,
              builder: (context, hearts, _) => _ContinueButton(
                hearts: hearts,
                onTap: game.continueGame,
              ),
            ),
            const SizedBox(height: 12),
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

/// The "spend a heart to keep going" action. Redesigned as a gradient
/// pill with the action and its cost visually separated, rather than
/// cramming both into one long line of text.
class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.hearts, required this.onTap});

  final int hearts;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final canContinue = hearts > 0;
    final foreground = canContinue ? Colors.white : Colors.white38;

    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: canContinue ? onTap : null,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          backgroundColor: Colors.transparent,
          disabledBackgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          disabledForegroundColor: foreground,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: canContinue
                ? const LinearGradient(
                    colors: [Color(0xFFFF7A7A), Color(0xFFE0294A)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  )
                : null,
            color: canContinue ? null : Colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: canContinue ? null : Border.all(color: Colors.white24),
          ),
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  canContinue ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: foreground,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  'CONTINUE',
                  style: TextStyle(
                    color: foreground,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: canContinue ? 0.18 : 0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    canContinue ? '-1 · $hearts left' : 'no hearts',
                    style: TextStyle(color: foreground, fontWeight: FontWeight.w700, fontSize: 11.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
