import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';

enum KnightState {walk, attack}

class Walk extends FlameGame with TapCallbacks {
  final _knightSize = Vector2(587.0, 707.0);
  SpriteAnimationGroupComponent? _knightComponent;

  @override
  void onLoad() async {
    final knightSheet = SpriteSheet(
      image: await images.load('knight.png'),
      srcSize: _knightSize,
    );
    final walkAnimation = knightSheet.createAnimation(row: 0, to: 10, stepTime: 0.1);
    final attackAnimation = knightSheet.createAnimation(row: 1, to: 10, stepTime: 0.05, loop: false);
    _knightComponent = SpriteAnimationGroupComponent(
      animations: {
        KnightState.walk: walkAnimation,
        KnightState.attack: attackAnimation,
      },
      current: KnightState.walk,
      size: Vector2(_knightSize.x / 2, _knightSize.y / 2),
      position: Vector2(size.x * 0.5, size.y * 0.5),
      anchor: Anchor.center,
    );
    _knightComponent?.animationTickers?[KnightState.attack]?.onComplete = () {
      _knightComponent?.current = KnightState.walk;
      _knightComponent?.animationTickers?[KnightState.attack]?.reset();
    };

    add(_knightComponent!);
    super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    _knightComponent?.current = KnightState.attack;
    super.onTapDown(event);
  }
}
