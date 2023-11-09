import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';

/// サンプルゲーム
class Sample extends FlameGame with TapCallbacks {
  // キャラクターの定義
  final _knight = Knight();

  @override
  void onLoad() async {
    add(
      PositionComponent(
        children: [_knight],
        position: Vector2(size.x * 0.5, size.y * 0.5),
        anchor: Anchor.center,
      ));
    super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    // キャラクターの状態を変更する
    _knight.current = KnightState.attack;
    super.onTapDown(event);
  }
}

/// キャラクター
class Knight extends SpriteAnimationGroupComponent {
  // サイズの定義
  final _knightSize = Vector2(587.0, 707.0);

  @override
  Future<void> onLoad() async {
    // スプライトシートを定義する
    final knightSheet = SpriteSheet(
      image: await Flame.images.load('knight.png'),
      srcSize: _knightSize,
    );

    // スプライトシートから作成したアニメーションを設定する
    animations = {
      KnightState.walk: knightSheet.createAnimation(row: 0, to: 10, stepTime: 0.1),
      KnightState.attack: knightSheet.createAnimation(row: 1, to: 10, stepTime: 0.05, loop: false),
    };

    // その他のプロパティを設定する
    current = KnightState.walk;
    size = Vector2(_knightSize.x / 2, _knightSize.y / 2);
    anchor = Anchor.center;

    // 攻撃アニメーションが終わったら歩行アニメーションに切り替える
    animationTickers?[KnightState.attack]?.onComplete = () {
      current = KnightState.walk;
      animationTickers?[KnightState.attack]?.reset();
    };
    super.onLoad();
  }
}

/// キャラクターの状態
enum KnightState {walk, attack}
