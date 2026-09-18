import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class CustomDonutGauge extends StatelessWidget {
  final double completedPercent; // e.g. 4.3
  final double remainingPercent; // e.g. 95.7
  final double size;
  final double strokeWidth;
  final String? centerTitle;
  final String centerSubtitle;
  final bool isDark;
  final Color? concludedColor;
  final Color? remainingColor;

  const CustomDonutGauge({
    super.key,
    required this.completedPercent,
    required this.remainingPercent,
    this.size = 210,
    this.strokeWidth = 20,
    this.centerTitle,
    this.centerSubtitle = 'CONCLUÍDO',
    this.isDark = true,
    this.concludedColor,
    this.remainingColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _ExecutiveGaugePainter(
              completedPercent: completedPercent,
              remainingPercent: remainingPercent,
              strokeWidth: strokeWidth,
              isDark: isDark,
              concludedColor: concludedColor,
              remainingColor: remainingColor,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0B172C) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1E2F52) : const Color(0xFFCBD5E1),
                  ),
                ),
                child: Text(
                  centerSubtitle,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.8,
                    color: isDark ? const Color(0xFF38BDF8) : AppColors.brandSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                centerTitle ?? '${completedPercent.toStringAsFixed(1).replaceAll('.', ',')}%',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  letterSpacing: -1.0,
                  fontFamily: 'Outfit',
                ),
              ),
              Text(
                'DA META MENSAL',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: isDark ? AppColors.darkTextMuted : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExecutiveGaugePainter extends CustomPainter {
  final double completedPercent;
  final double remainingPercent;
  final double strokeWidth;
  final bool isDark;
  final Color? concludedColor;
  final Color? remainingColor;

  _ExecutiveGaugePainter({
    required this.completedPercent,
    required this.remainingPercent,
    required this.strokeWidth,
    required this.isDark,
    this.concludedColor,
    this.remainingColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 1. Subtle Outer Telemetry Ring
    final outerRingPaint = Paint()
      ..color = isDark ? const Color(0xFF162544) : const Color(0xFFE2E8F0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius + (strokeWidth / 2) + 4, outerRingPaint);

    // 2. Base Background Track
    final trackPaint = Paint()
      ..color = isDark ? AppColors.darkChartTrack : AppColors.lightChartTrack
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    canvas.drawCircle(center, radius, trackPaint);

    // Starting at 12 o'clock (-PI / 2)
    const startAngle = -math.pi / 2;
    final completedSweep = (completedPercent / 100.0) * 2 * math.pi;
    final remainingSweep = (remainingPercent / 100.0) * 2 * math.pi;

    // 3. Draw Completed Arc (Green)
    final resolvedCompletedColor = concludedColor ??
        (isDark ? AppColors.successDark : AppColors.successLight);

    final completedPaint = Paint()
      ..color = resolvedCompletedColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    canvas.drawArc(rect, startAngle, completedSweep, false, completedPaint);

    // 4. Draw Remaining Arc (Crimson)
    final resolvedRemainingColor = remainingColor ??
        (isDark ? AppColors.dangerDark : AppColors.dangerLight);

    final remainingPaint = Paint()
      ..color = resolvedRemainingColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    const gap = 0.06;
    final safeRemainingStart = startAngle + completedSweep + gap;
    final safeRemainingSweep = remainingSweep - (gap * 2);

    if (safeRemainingSweep > 0) {
      canvas.drawArc(rect, safeRemainingStart, safeRemainingSweep, false, remainingPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ExecutiveGaugePainter oldDelegate) {
    return oldDelegate.completedPercent != completedPercent ||
        oldDelegate.remainingPercent != remainingPercent ||
        oldDelegate.isDark != isDark;
  }
}
