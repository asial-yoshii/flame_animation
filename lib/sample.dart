import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/parallax.dart';
import 'package:flame/sprite.dart';

/// サンプルゲーム
class Sample extends FlameGame with TapCallbacks {
  // 背景の定義
  final background = Background();
  // キャラクターの定義
  final knight = Knight();

  @override
  void onLoad() async {
    // 背景を配置する
    await add(background);
    // キャラクターを配置する
    await add(
      PositionComponent(
        children: [knight],
        position: Vector2(size.x * 0.5, size.y * 0.5 + 20.0),
        anchor: Anchor.center,
      ),
    );
    super.onLoad();
  }

  @override
  void onTapDown(TapDownEvent event) {
    // 攻撃する
    knight.attackStart();
    super.onTapDown(event);
  }
}

/// 背景
class Background extends ParallaxComponent with HasGameRef {
  // スピード
  final _velocity = Vector2(140, 0);

  @override
  Future<void> onLoad() async {
    parallax = await gameRef.loadParallax(
      [ParallaxImageData('background.jpg')],
      baseVelocity: _velocity
    );
    super.onLoad();
  }

  /// 背景を止める
  void pause() {
    parallax?.baseVelocity = Vector2.zero();
  }

  /// 背景を動かす
  void resume() {
    parallax?.baseVelocity = _velocity;
  }
}

/// キャラクター
class Knight extends SpriteAnimationGroupComponent with HasGameRef<Sample> {
  // サイズの定義
  final _knightSize = Vector2(587.0, 707.0);

  @override
  Future<void> onLoad() async {
    // スプライトシートを定義する
    final spriteSheet = SpriteSheet(
      image: await gameRef.images.load('knight.png'),
      srcSize: _knightSize,
    );

    // スプライトシートから作成したアニメーションを設定する
    animations = {
      KnightState.walk: spriteSheet.createAnimation(row: 0, to: 10, stepTime: 0.1),
      KnightState.attack: spriteSheet.createAnimation(row: 1, to: 10, stepTime: 0.05, loop: false),
    };

    // その他のプロパティを設定する
    current = KnightState.walk;
    size = Vector2(_knightSize.x / 2, _knightSize.y / 2);
    anchor = Anchor.center;

    // 攻撃アニメーション終了イベントを設定する
    animationTickers?[KnightState.attack]?.onComplete = attackEnd;
    super.onLoad();
  }

  /// 攻撃開始
  void attackStart() {
    gameRef.background.pause();
    current = KnightState.attack;
  }

  /// 攻撃終了
  void attackEnd() async {
    await Future.delayed(const Duration(milliseconds: 100));
    animationTickers?[KnightState.attack]?.reset();
    current = KnightState.walk;
    gameRef.background.resume();
  }
}

/// キャラクターの状態
enum KnightState {walk, attack}
