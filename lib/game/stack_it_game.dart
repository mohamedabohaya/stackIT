import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import '../models/game_theme.dart';
import '../services/score_service.dart';
import '../services/store_service.dart';
import 'components/block_component.dart';
import 'components/falling_piece_component.dart';
import 'components/stack_particles.dart';

class StackItGame extends FlameGame {
  StackItGame({
    required this.scoreService,
    required this.storeService,
    this.theme = kClassicTheme,
  });

  final ScoreService scoreService;
  final StoreService storeService;
  final GameTheme theme;

  static const double worldWidth = 400;
  static const double worldHeight = 800;
  static const double blockHeight = 44;
  static const double baseBlockWidth = 220;
  static const double baseSpeed = 130;
  static const double speedPerLevel = 6;
  static const double maxSpeed = 340;
  static const double minSurviveWidth = 4;
  static const double cameraTopMargin = 220;

  final List<_PlacedBlock> _stack = [];
  BlockComponent? _movingBlockComponent;
  _MovingState? _moving;

  int score = 0;
  int bestScore = 0;
  bool isGameOver = false;

  final ValueNotifier<int> scoreNotifier = ValueNotifier<int>(0);
  final ValueNotifier<int> bestScoreNotifier = ValueNotifier<int>(0);

  @override
  Color backgroundColor() => theme.backgroundColor;

  @override
  Future<void> onLoad() async {
    camera.viewfinder.visibleGameSize = Vector2(worldWidth, worldHeight);
    bestScore = await scoreService.loadBestScore();
    bestScoreNotifier.value = bestScore;
    _startNewGame();
  }

  void _startNewGame() {
    world.removeAll(world.children.toList());
    _stack.clear();
    score = 0;
    scoreNotifier.value = 0;
    isGameOver = false;
    camera.viewfinder.position = Vector2(worldWidth / 2, worldHeight / 2);

    final baseLeft = (worldWidth - baseBlockWidth) / 2;
    final baseTop = worldHeight - blockHeight - 60;

    world.add(RectangleComponent(
      position: Vector2(0, baseTop + blockHeight),
      size: Vector2(worldWidth, worldHeight - (baseTop + blockHeight) + 4000),
      paint: Paint()..color = theme.groundColor,
    ));

    final base = _PlacedBlock(left: baseLeft, width: baseBlockWidth, top: baseTop, colorIndex: 0);
    _stack.add(base);
    world.add(BlockComponent(
      position: Vector2(base.left, base.top),
      size: Vector2(base.width, blockHeight),
      color: _colorForIndex(0),
    ));

    _spawnMovingBlock();
  }

  Color _colorForIndex(int index) => theme.blockColors[index % theme.blockColors.length];

  void _spawnMovingBlock() {
    final last = _stack.last;
    final width = last.width;
    final top = last.top - blockHeight;
    final fromLeft = Random().nextBool();
    final startLeft = fromLeft ? 0.0 : worldWidth - width;
    final speed = min(maxSpeed, baseSpeed + score * speedPerLevel);

    _moving = _MovingState(
      left: startLeft,
      width: width,
      top: top,
      direction: fromLeft ? 1 : -1,
      speed: speed,
    );

    _movingBlockComponent = BlockComponent(
      position: Vector2(startLeft, top),
      size: Vector2(width, blockHeight),
      color: _colorForIndex(_stack.length),
    );
    world.add(_movingBlockComponent!);

    _adjustCameraFor(top);
  }

  void _adjustCameraFor(double topY) {
    final currentTopEdge = camera.viewfinder.position.y - worldHeight / 2;
    final desiredTopEdge = topY - cameraTopMargin;
    if (desiredTopEdge < currentTopEdge) {
      final targetCenterY = desiredTopEdge + worldHeight / 2;
      camera.viewfinder.add(
        MoveToEffect(
          Vector2(worldWidth / 2, targetCenterY),
          EffectController(duration: 0.4, curve: Curves.easeOutCubic),
        ),
      );
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    final moving = _moving;
    if (isGameOver || moving == null) return;

    moving.left += moving.direction * moving.speed * dt;
    if (moving.left <= 0) {
      moving.left = 0;
      moving.direction = 1;
    } else if (moving.left + moving.width >= worldWidth) {
      moving.left = worldWidth - moving.width;
      moving.direction = -1;
    }
    _movingBlockComponent?.position.x = moving.left;
  }

  void handleTap() {
    if (isGameOver) return;
    final moving = _moving;
    if (moving == null) return;

    final last = _stack.last;
    final overlapLeft = max(moving.left, last.left);
    final overlapRight = min(moving.left + moving.width, last.left + last.width);
    final overlapWidth = overlapRight - overlapLeft;

    if (overlapWidth < minSurviveWidth) {
      _endGame();
      return;
    }

    _movingBlockComponent?.removeFromParent();
    _movingBlockComponent = null;

    final leftoverLeftWidth = overlapLeft - moving.left;
    final leftoverRightWidth = (moving.left + moving.width) - overlapRight;
    final cutColor = _colorForIndex(_stack.length);

    if (leftoverLeftWidth > 0.5) {
      world.add(FallingPieceComponent(
        position: Vector2(moving.left, moving.top),
        size: Vector2(leftoverLeftWidth, blockHeight),
        color: cutColor,
      ));
    }
    if (leftoverRightWidth > 0.5) {
      world.add(FallingPieceComponent(
        position: Vector2(overlapRight, moving.top),
        size: Vector2(leftoverRightWidth, blockHeight),
        color: cutColor,
      ));
    }

    final placed = _PlacedBlock(
      left: overlapLeft,
      width: overlapWidth,
      top: moving.top,
      colorIndex: _stack.length,
    );
    _stack.add(placed);
    world.add(BlockComponent(
      position: Vector2(placed.left, placed.top),
      size: Vector2(placed.width, blockHeight),
      color: cutColor,
    ));
    world.add(createStackParticles(
      position: Vector2(overlapLeft + overlapWidth / 2, moving.top),
      color: cutColor,
    ));

    score++;
    scoreNotifier.value = score;
    _moving = null;

    _spawnMovingBlock();
  }

  void _endGame() {
    isGameOver = true;
    _movingBlockComponent?.removeFromParent();
    _movingBlockComponent = null;
    _moving = null;
    if (score > bestScore) {
      bestScore = score;
      bestScoreNotifier.value = bestScore;
      scoreService.saveBestScore(bestScore);
    }
    if (score > 0) {
      storeService.addCoins(score);
    }
    overlays.add('gameOver');
  }

  void retry() {
    overlays.remove('gameOver');
    _startNewGame();
  }
}

class _PlacedBlock {
  _PlacedBlock({
    required this.left,
    required this.width,
    required this.top,
    required this.colorIndex,
  });

  final double left;
  final double width;
  final double top;
  final int colorIndex;
}

class _MovingState {
  _MovingState({
    required this.left,
    required this.width,
    required this.top,
    required this.direction,
    required this.speed,
  });

  double left;
  final double width;
  final double top;
  int direction;
  final double speed;
}
