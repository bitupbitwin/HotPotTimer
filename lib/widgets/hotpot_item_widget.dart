import 'dart:async';
import 'package:flutter/material.dart';
import '../models/hotpot_item.dart';
import '../services/feedback_service.dart';

class HotpotItemWidget extends StatefulWidget {
  final HotpotItem item;
  final double diameter;

  const HotpotItemWidget({
    super.key,
    required this.item,
    this.diameter = 130,
  });

  @override
  State<HotpotItemWidget> createState() => _HotpotItemWidgetState();
}

class _HotpotItemWidgetState extends State<HotpotItemWidget>
    with SingleTickerProviderStateMixin {
  HotpotState _state = HotpotState.idle;
  int _remaining = 0; // 剩余秒数
  int _overtime = 0; // 超时秒数
  Timer? _timer;
  late final AnimationController _blink;

  static const Color kYellow = Color(0xFFFFCC00);
  static const Color kYellowDim = Color(0xFF7A6300);
  static const Color kGreen = Color(0xFF4CD964);
  static const Color kRed = Color(0xFFFF3B30);

  @override
  void initState() {
    super.initState();
    _blink = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void didUpdateWidget(covariant HotpotItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.id != widget.item.id) {
      _reset();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _blink.dispose();
    super.dispose();
  }

  // ---------- 状态机 ----------

  void _onTap() {
    if (_state == HotpotState.idle) {
      _start();
    } else {
      _reset(); // 煮制中/熟透/超时 时再次点击 = 捞出重置
    }
  }

  void _start() {
    FeedbackService.tapFeedback();
    setState(() {
      _state = HotpotState.counting;
      _remaining = widget.item.targetSeconds;
      _overtime = 0;
    });
    _applyAnimationForState();

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_state == HotpotState.counting) {
          _remaining--;
          if (_remaining <= 0) {
            _remaining = 0;
            _state = HotpotState.ready;
            _applyAnimationForState();
            FeedbackService.perfectAlarm();
          }
        } else if (_state == HotpotState.ready) {
          _overtime++;
          if (_overtime >= 60) {
            _state = HotpotState.overcooked;
            _applyAnimationForState();
            FeedbackService.urgentAlarm();
          }
        } else if (_state == HotpotState.overcooked) {
          _overtime++;
          if (_overtime % 15 == 0) {
            FeedbackService.urgentAlarm(); // 持续超时，周期性催促
          }
        }
      });
    });
  }

  void _reset() {
    _timer?.cancel();
    FeedbackService.stop();
    setState(() {
      _state = HotpotState.idle;
      _remaining = 0;
      _overtime = 0;
    });
    _applyAnimationForState();
  }

  /// 根据状态设置闪烁频率与循环方式
  void _applyAnimationForState() {
    _blink.stop();
    switch (_state) {
      case HotpotState.idle:
        _blink.value = 0;
        break;
      case HotpotState.counting:
        _blink.duration = const Duration(milliseconds: 500);
        _blink.repeat(reverse: true);
        break;
      case HotpotState.ready:
        _blink.duration = const Duration(milliseconds: 1400);
        _blink.repeat(reverse: true); // 柔和呼吸
        break;
      case HotpotState.overcooked:
        _blink.duration = const Duration(milliseconds: 200);
        _blink.repeat(reverse: true); // 高频疯狂闪烁
        break;
    }
  }

  // ---------- 颜色 / 文本计算 ----------

  Color _ringColor(double t) {
    switch (_state) {
      case HotpotState.idle:
        return Colors.black;
      case HotpotState.counting:
        return Color.lerp(kYellowDim, kYellow, t)!;
      case HotpotState.ready:
        return Color.lerp(kGreen.withValues(alpha: 0.55), kGreen, t)!;
      case HotpotState.overcooked:
        return Color.lerp(Colors.transparent, kRed, t)!;
    }
  }

  String _fmt(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    if (m > 0) {
      return '$m:${s.toString().padLeft(2, '0')}';
    }
    return '${s}s';
  }

  /// 中央叠加层文本（null 表示不显示）
  Widget? _centerOverlay() {
    switch (_state) {
      case HotpotState.idle:
        return null;
      case HotpotState.counting:
        return Text(
          _fmt(_remaining),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 30,
            fontWeight: FontWeight.w900,
          ),
        );
      case HotpotState.ready:
        return AnimatedBuilder(
          animation: _blink,
          builder: (context, child) => Opacity(
            opacity: 0.4 + 0.6 * _blink.value,
            child: const Text(
              '可吃!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        );
      case HotpotState.overcooked:
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '太老了!',
              style: TextStyle(
                color: kRed,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              '-${_fmt(_overtime)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        );
    }
  }

  // ---------- 食材图片 / emoji ----------

  Widget _avatar() {
    final d = widget.diameter;
    if (widget.item.imagePath != null && widget.item.imagePath!.isNotEmpty) {
      return Image.asset(
        widget.item.imagePath!,
        width: d,
        height: d,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => _emojiAvatar(d),
      );
    }
    return _emojiAvatar(d);
  }

  Widget _emojiAvatar(double d) {
    return Container(
      width: d,
      height: d,
      color: const Color(0xFF2A2A2A),
      alignment: Alignment.center,
      child: Text(widget.item.emoji, style: TextStyle(fontSize: d * 0.42)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.diameter;
    final overlay = _centerOverlay();

    return GestureDetector(
      onTap: _onTap,
      onLongPress: _reset,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _blink,
            builder: (context, _) {
              final color = _ringColor(_blink.value);
              return Container(
                width: d + 22,
                height: d + 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: _state == HotpotState.idle
                      ? null
                      : [
                          BoxShadow(
                            color: color.withValues(alpha: 0.6),
                            blurRadius: 16,
                            spreadRadius: 1,
                          ),
                        ],
                ),
                child: CustomPaint(
                  painter: _RingPainter(color: color, strokeWidth: 9),
                  child: Center(
                    child: ClipOval(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          _avatar(),
                          if (overlay != null)
                            Container(
                              width: d,
                              height: d,
                              color: Colors.black.withValues(alpha: 0.45),
                              alignment: Alignment.center,
                              child: overlay,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Text(
            widget.item.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '推荐 ${_fmt(widget.item.targetSeconds)}',
            style: TextStyle(color: Colors.grey[400], fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _RingPainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = color
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.color != color || old.strokeWidth != strokeWidth;
}
