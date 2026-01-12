import 'package:flutter/material.dart';

class DiagonalLine extends StatelessWidget {
  final Color color;
  final double strokeWidth;

  const DiagonalLine({
    super.key,
    this.color = const Color(0xffcdcdcd),
    this.strokeWidth = 1,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DiagonalLinePainter(color: color, strokeWidth: strokeWidth),
    );
  }
}

class _DiagonalLinePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;

  _DiagonalLinePainter({required this.color, required this.strokeWidth});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(Offset(0, 0), Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _DiagonalLinePainter oldDelegate) {
    return oldDelegate.color != color || oldDelegate.strokeWidth != strokeWidth;
  }
}
