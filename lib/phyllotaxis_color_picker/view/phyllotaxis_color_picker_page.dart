import 'dart:math' as math;
import 'dart:ui';

import 'package:animation_playground/core/extensions/extensions.dart';
import 'package:flutter/material.dart';

class PhyllotaxisColorPickerPage extends StatefulWidget {
  const PhyllotaxisColorPickerPage({super.key});

  static PageRoute route() => MaterialPageRoute(
    builder: (context) => const PhyllotaxisColorPickerPage(),
  );

  @override
  State<PhyllotaxisColorPickerPage> createState() =>
      _PhyllotaxisColorPickerPageState();
}

class _PhyllotaxisColorPickerPageState extends State<PhyllotaxisColorPickerPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  bool isOpen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _animate() {
    _animationController
      ..reset()
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text('Color Picker')),
      body: GestureDetector(
        onLongPress: () {
          setState(() {
            isOpen = true;
          });
          _animate();
        },
        onLongPressEnd: (details) {
          setState(() {
            isOpen = false;
          });
          _animate();
        },
        child: CustomPaint(
          painter: _ColorPickerPainter(
            animation: _animationController,
            isOpen: isOpen,
          ),
          size: MediaQuery.sizeOf(context),
        ),
      ),
    );
  }
}

class _ColorPickerPainter extends CustomPainter {
  _ColorPickerPainter({required this.animation, required this.isOpen})
    : super(repaint: animation);
  final Animation<double> animation;
  final bool isOpen;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    const totalPoints = 700;
    const spread = 8;
    const originR = 20;
    const ringDuration = 0.5;

    final goldenAngle = 137.508.radians;
    final t = animation.value;

    final paint = Paint()
      ..shader = const SweepGradient(
        colors: [
          Colors.red,
          Colors.yellow,
          Colors.green,
          Colors.blue,
          Colors.purple,
          Colors.red,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: 200));

    for (int n = 0; n < totalPoints; n++) {
      final r = spread * math.sqrt(n);
      final theta = n * goldenAngle;
      final originX = originR * math.cos(theta);
      final originY = originR * math.sin(theta);
      final targetX = r * math.cos(theta);
      final targetY = r * math.sin(theta);

      final normalized = n / totalPoints;
      final delayStart = isOpen
          ? (1.0 - normalized) * (1.0 - ringDuration)
          : normalized * (1.0 - ringDuration);
      final delayEnd = delayStart + ringDuration;
      final progress = isOpen
          ? ((t - delayStart) / (1 - delayEnd)).clamp(0.0, 1.0)
          : ((t - delayStart) / (delayEnd - delayStart)).clamp(0.0, 1.0);
      final eased = Curves.ease.transform(progress);

      final x = isOpen
          ? lerpDouble(originX, targetX, eased)!
          : lerpDouble(targetX, originX, eased)!;
      final y = isOpen
          ? lerpDouble(originY, targetY, eased)!
          : lerpDouble(targetY, originY, eased)!;

      // final size = n / totalPoints * spread;
      final size = math.pow(normalized, 0.8) * spread;
      canvas.drawCircle(center + Offset(x, y), size / 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ColorPickerPainter oldDelegate) =>
      oldDelegate.animation.value != animation.value ||
      oldDelegate.isOpen != isOpen;
}
