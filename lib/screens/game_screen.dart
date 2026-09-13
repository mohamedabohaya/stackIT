import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../game/overlays/game_over_overlay.dart';
import '../game/overlays/score_overlay.dart';
import '../game/stack_it_game.dart';
import '../models/game_theme.dart';
import '../services/score_service.dart';
import '../services/store_service.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key, this.theme = kClassicTheme});

  final GameTheme theme;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late final StackItGame _game;

  @override
  void initState() {
    super.initState();
    _game = StackItGame(
      scoreService: ScoreService(),
      storeService: StoreService(),
      theme: widget.theme,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.theme.backgroundColor,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: (_) => _game.handleTap(),
        child: Stack(
          children: [
            Positioned.fill(
              child: GameWidget<StackItGame>(
                game: _game,
                overlayBuilderMap: {
                  'gameOver': (context, game) => GameOverOverlay(game: game),
                },
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: ScoreOverlay(game: _game),
            ),
          ],
        ),
      ),
    );
  }
}
