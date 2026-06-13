import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

class FeedbackService {
  static bool _canVibrate = false;
  static bool _inited = false;
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> init() async {
    if (_inited) return;
    _inited = true;
    try {
      _canVibrate = await Vibration.hasVibrator();
    } catch (_) {
      _canVibrate = false;
    }
    await _player.setReleaseMode(ReleaseMode.stop);
  }

  static Future<void> _play(String asset) async {
    try {
      await _player.stop();
      await _player.play(AssetSource(asset));
    } catch (_) {}
  }

  /// 下锅时轻触反馈 + 上升音效
  static void tapFeedback() {
    HapticFeedback.lightImpact();
    if (_canVibrate) Vibration.vibrate(duration: 30);
    _play('sounds/start.wav');
  }

  /// 煮熟瞬间：叮咚提示音 + 间歇震动
  static void perfectAlarm() {
    HapticFeedback.mediumImpact();
    if (_canVibrate) Vibration.vibrate(pattern: [0, 300, 200, 300]);
    _play('sounds/ready.wav');
  }

  /// 超时报警：急促三连音 + 连续震动
  static void urgentAlarm() {
    HapticFeedback.heavyImpact();
    if (_canVibrate) Vibration.vibrate(pattern: [0, 200, 100, 200, 100, 200]);
    _play('sounds/overcooked.wav');
  }

  static void stop() {
    if (_canVibrate) Vibration.cancel();
    _player.stop();
  }
}
