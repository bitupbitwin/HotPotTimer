import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// 统一管理震动与提示音的硬件联动。
class FeedbackService {
  static bool _canVibrate = false;
  static bool _inited = false;

  static Future<void> init() async {
    if (_inited) return;
    _inited = true;
    try {
      _canVibrate = await Vibration.hasVibrator();
    } catch (_) {
      _canVibrate = false;
    }
  }

  /// 下锅时的轻微按键反馈
  static void tapFeedback() {
    HapticFeedback.lightImpact();
    if (_canVibrate) {
      Vibration.vibrate(duration: 30);
    }
  }

  /// 煮熟瞬间：叮咚提示音 + 一段提醒震动
  static void perfectAlarm() {
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.mediumImpact();
    if (_canVibrate) {
      // 间歇性提醒：等-震-等-震
      Vibration.vibrate(pattern: [0, 300, 200, 300]);
    }
  }

  /// 超时报警：更急促的连续震动 + 提示音
  static void urgentAlarm() {
    SystemSound.play(SystemSoundType.alert);
    HapticFeedback.heavyImpact();
    if (_canVibrate) {
      Vibration.vibrate(pattern: [0, 200, 100, 200, 100, 200]);
    }
  }

  /// 重置时停止震动
  static void stop() {
    if (_canVibrate) {
      Vibration.cancel();
    }
  }
}
