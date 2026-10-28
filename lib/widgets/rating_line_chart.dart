import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Simple hand-drawn line chart for "Session Rating Over Time" — no
/// external charting package, so it has no extra pub dependency to resolve.
class RatingLineChart extends StatelessWidget {
  final List<double> values; // e.g. star ratings, 0-5 scale
  final List<String> xLabels;
  final double minY;
  final double maxY;

  const RatingLineChart({
    super.key,
    required this.values,
    required this.xLabels,
    this.minY = 1,
    this.maxY = 5,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 160,
      child: Column(
        children: [
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _LineChartPainter(values: values, minY: minY, maxY: maxY),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: xLabels
                .map((l) => Text(l, style: const TextStyle(color: AppColors.textMuted, fontSize: 10.5)))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  final double minY;
  final double maxY;

  _LineChartPainter({required this.values, required this.minY, required this.maxY});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    final gridPaint = Paint()
      ..color = AppColors.border
      ..strokeWidth = 1;

    // Horizontal gridlines for each integer rating step.
    final steps = (maxY - minY).round();
    for (int i = 0; i <= steps; i++) {
      final y = size.height - (i / steps) * size.height;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    double xFor(int index) => values.length == 1
        ? size.width / 2
        : size.width * index / (values.length - 1);

    double yFor(double value) {
      final clamped = value.clamp(minY, maxY);
      final t = (clamped - minY) / (maxY - minY);
      return size.height - t * size.height;
    }

    final path = Path();
    for (int i = 0; i < values.length; i++) {
      final point = Offset(xFor(i), yFor(values[i]));
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    final linePaint = Paint()
      ..color = AppColors.accentGold
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, linePaint);

    // Fill under the line for a subtle area effect.
    final fillPath = Path.from(path)
      ..lineTo(xFor(values.length - 1), size.height)
      ..lineTo(xFor(0), size.height)
      ..close();
    final fillPaint = Paint()
      ..color = AppColors.accentGold.withOpacity(0.12)
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);

    final dotPaint = Paint()..color = AppColors.accentGold;
    final dotBorder = Paint()
      ..color = AppColors.background
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    for (int i = 0; i < values.length; i++) {
      final point = Offset(xFor(i), yFor(values[i]));
      canvas.drawCircle(point, 4.5, dotPaint);
      canvas.drawCircle(point, 4.5, dotBorder);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.minY != minY || oldDelegate.maxY != maxY;
  }
}
