import 'package:ember/actors/ember.dart';
import 'package:ember/actors/water_enemy.dart';
import 'package:ember/managers/segment_manager.dart';
import 'package:ember/objects/ground_block.dart';
import 'package:ember/objects/platform_block.dart';
import 'package:ember/objects/star.dart';
import 'package:ember/overlays/hud.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

class EmberQuestGame extends FlameGame
    with HasCollisionDetection, HasKeyboardHandlerComponents {
  late EmberPlayer _ember;
  late double lastBlockXPosition = 0.0;
  late UniqueKey lastBlockKey;

  double objectSpeed = 0.0;
  int starsCollected = 0;
  int health = 3;

  @override
  Future<void> onLoad() async {
    await images.loadAll([
      'block.png',
      'ember.png',
      'ground.png',
      'heart_half.png',
      'heart.png',
      'star.png',
      'water_enemy.png',
    ]);

    camera.viewfinder.anchor = Anchor.topLeft;
    initializeGame(true);
  }

  void initializeGame(bool loadHud) {
    // Assume that size.x < 3200
    final segmentsToLoad = (size.x / 640).ceil();
    segmentsToLoad.clamp(0, segments.length);

    for (var i = 0; i <= segmentsToLoad; i++) {
      loadGameSegments(i, (640 * i).toDouble());
    }

    _ember = EmberPlayer(
      position: Vector2(128, canvasSize.y - 128),
    );
    world.add(_ember);
    if (loadHud) {
      camera.viewport.add(Hud());
    }
  }

  void reset() {
    starsCollected = 0;
    health = 3;
    initializeGame(false);
  }

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 173, 223, 247);
  }

  void loadGameSegments(int segmentIndex, double xPositionOffset) {
    for (final block in segments[segmentIndex]) {
      final component = switch (block.blockType) {
        const (GroundBlock) => GroundBlock(
            gridPosition: block.gridPosition,
            xOffset: xPositionOffset,
          ),
        const (PlatformBlock) => PlatformBlock(
            gridPosition: block.gridPosition,
            xOffset: xPositionOffset,
          ),
        const (Star) => Star(
            gridPosition: block.gridPosition,
            xOffset: xPositionOffset,
          ),
        const (WaterEnemy) => WaterEnemy(
            gridPosition: block.gridPosition,
            xOffset: xPositionOffset,
          ),
        _ => throw UnimplementedError(),
      };
      world.add(component);
    }
  }

  @override
  void update(double dt) {
    if (health <= 0) {
      overlays.add('GameOver');
    }
    super.update(dt);
  }
}
