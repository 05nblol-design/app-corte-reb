import 'package:flutter/material.dart';

class RhythmLineChart extends StatelessWidget {
  final List<double> points;
  final List<Offset>? series;
  final double targetValue; // usually 100.0
  final double maxValue; // usually 150.0
  final double minValue; // usually 0.0
  final bool isDark;
  final double height;
  final List<String> timeLabels;
  final Color? lineColor;

  const RhythmLineChart({
    super.key,
    this.points = const [],
    this.series,
    this.targetValue = 100.0,
    this.maxValue = 150.0,
    this.minValue = 0.0,
    required this.isDark,
    this.height = 100.0,
    this.timeLabels = const ['06h', '10h', '14h'],
    this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _RhythmChartPainter(
          points: points,
          series: series,
          targetValue: targetValue,
          maxValue: maxValue,
          minValue: minValue,
          isDark: isDark,
          timeLabels: timeLabels,
          lineColor: lineColor,
        ),
      ),
    );
  }
}

class _RhythmChartPainter extends CustomPainter {
  final List<double> points;
  final List<Offset>? series;
  final double targetValue;
  final double maxValue;
  final double minValue;
  final bool isDark;
  final List<String> timeLabels;
  final Color? lineColor;

  _RhythmChartPainter({
    required this.points,
    this.series,
    required this.targetValue,
    required this.maxValue,
    required this.minValue,
    required this.isDark,
    required this.timeLabels,
    this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    const leftPadding = 32.0;
    const rightPadding = 8.0;
    const topPadding = 12.0;
    const bottomPadding = 18.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    if (chartWidth <= 0 || chartHeight <= 0) return;

    final textStyle = TextStyle(
      fontSize: 8.5,
      fontWeight: FontWeight.w600,
      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
    );

    final targetTextStyle = TextStyle(
      fontSize: 8.5,
      fontWeight: FontWeight.w800,
      color: isDark ? const Color(0xFF34D399) : const Color(0xFF10B981),
    );

    double getY(double val) {
      final clamped = val.clamp(minValue, maxValue);
      final ratio = (clamped - minValue) / (maxValue - minValue);
      return topPadding + chartHeight * (1.0 - ratio);
    }

    final gridPaint = Paint()
      ..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)
      ..strokeWidth = 0.8;

    final targetPaint = Paint()
      ..color = isDark ? const Color(0xFF34D399) : const Color(0xFF10B981)
      ..strokeWidth = 1.2;

    // 1. Draw Grid Lines for 150%, 100%, 50%
    final levels = [150.0, 100.0, 50.0];
    for (final lvl in levels) {
      final y = getY(lvl);

      if (lvl == targetValue) {
        // Dashed target line
        _drawDashedLine(
          canvas,
          Offset(leftPadding, y),
          Offset(size.width - rightPadding, y),
          targetPaint,
          dashWidth: 4,
          dashSpace: 3,
        );
        _drawText(canvas, '100%', Offset(leftPadding - 4, y - 5), targetTextStyle, align: TextAlign.right);
      } else {
        canvas.drawLine(
          Offset(leftPadding, y),
          Offset(size.width - rightPadding, y),
          gridPaint,
        );
        _drawText(canvas, '${lvl.toInt()}%', Offset(leftPadding - 4, y - 5), textStyle, align: TextAlign.right);
      }
    }

    // Baseline (0%)
    final baseY = topPadding + chartHeight;
    canvas.drawLine(
      Offset(leftPadding, baseY),
      Offset(size.width - rightPadding, baseY),
      gridPaint,
    );

    // 2. Compute Data Offsets
    final offsets = <Offset>[];
    if (series != null && series!.isNotEmpty) {
      for (final pt in series!) {
        final x = leftPadding + (pt.dx.clamp(0.0, 1.0) * chartWidth);
        final y = getY(pt.dy);
        offsets.add(Offset(x, y));
      }
    } else if (points.isNotEmpty) {
      final stepX = points.length > 1 ? chartWidth / (points.length - 1) : chartWidth;
      for (int i = 0; i < points.length; i++) {
        final x = leftPadding + (i * stepX);
        final y = getY(points[i]);
        offsets.add(Offset(x, y));
      }
    }

    if (offsets.isNotEmpty) {
      final effectiveLineColor = lineColor ??
          (isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7));

      // Build smooth cubic Bezier curve
      final curvePath = Path();
      curvePath.moveTo(offsets.first.dx, offsets.first.dy);

      if (offsets.length == 1) {
        curvePath.lineTo(offsets.first.dx + 1, offsets.first.dy);
      } else {
        for (int i = 0; i < offsets.length - 1; i++) {
          final p0 = offsets[i];
          final p1 = offsets[i + 1];
          final cpX = (p0.dx + p1.dx) / 2;
          curvePath.cubicTo(cpX, p0.dy, cpX, p1.dy, p1.dx, p1.dy);
        }
      }

      // Fill Path (Smooth gradient down to baseline)
      final fillPath = Path.from(curvePath);
      fillPath.lineTo(offsets.last.dx, baseY);
      fillPath.lineTo(offsets.first.dx, baseY);
      fillPath.close();

      final gradientPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            effectiveLineColor.withValues(alpha: isDark ? 0.28 : 0.18),
            effectiveLineColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(leftPadding, topPadding, chartWidth, chartHeight));

      canvas.drawPath(fillPath, gradientPaint);

      // Stroke Path (Smooth continuous curve, NO intermediate dots!)
      final linePaint = Paint()
        ..color = effectiveLineColor
        ..strokeWidth = 2.4
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      canvas.drawPath(curvePath, linePaint);

      // Highlight Only Last Point (Live beacon on current time, single point)
      final lastPt = offsets.last;
      final outerPulsePaint = Paint()
        ..color = effectiveLineColor.withValues(alpha: 0.22)
        ..style = PaintingStyle.fill;
      final beaconHaloPaint = Paint()
        ..color = effectiveLineColor.withValues(alpha: 0.55)
        ..style = PaintingStyle.fill;
      final beaconInnerPaint = Paint()
        ..color = effectiveLineColor
        ..style = PaintingStyle.fill;
      final beaconCorePaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawCircle(lastPt, 6.5, outerPulsePaint);
      canvas.drawCircle(lastPt, 4.0, beaconHaloPaint);
      canvas.drawCircle(lastPt, 2.5, beaconInnerPaint);
      canvas.drawCircle(lastPt, 1.2, beaconCorePaint);
    }

    // 3. Draw X-Axis Time Labels
    if (timeLabels.isNotEmpty) {
      for (int i = 0; i < timeLabels.length; i++) {
        final ratio = timeLabels.length > 1 ? i / (timeLabels.length - 1) : 0.5;
        final x = leftPadding + (ratio * chartWidth);
        final textAlign = i == 0
            ? TextAlign.left
            : (i == timeLabels.length - 1 ? TextAlign.right : TextAlign.center);
        _drawText(
          canvas,
          timeLabels[i],
          Offset(x, baseY + 4),
          textStyle,
          align: textAlign,
        );
      }
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset p1,
    Offset p2,
    Paint paint, {
    required double dashWidth,
    required double dashSpace,
  }) {
    double currentX = p1.dx;
    while (currentX < p2.dx) {
      final endX = (currentX + dashWidth).clamp(p1.dx, p2.dx);
      canvas.drawLine(Offset(currentX, p1.dy), Offset(endX, p2.dy), paint);
      currentX += dashWidth + dashSpace;
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style, {
    TextAlign align = TextAlign.left,
  }) {
    final span = TextSpan(text: text, style: style);
    final tp = TextPainter(
      text: span,
      textAlign: align,
      textDirection: TextDirection.ltr,
    );
    tp.layout();
    double dx = offset.dx;
    if (align == TextAlign.right) {
      dx -= tp.width;
    } else if (align == TextAlign.center) {
      dx -= tp.width / 2;
    }
    tp.paint(canvas, Offset(dx, offset.dy));
  }

  @override
  bool shouldRepaint(covariant _RhythmChartPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.series != series ||
        oldDelegate.isDark != isDark ||
        oldDelegate.targetValue != targetValue ||
        oldDelegate.timeLabels != timeLabels ||
        oldDelegate.lineColor != lineColor;
  }
}
