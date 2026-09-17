import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import 'custom_donut_gauge.dart';
import 'rhythm_line_chart.dart';

class CorteRebobinamentoCard extends StatelessWidget {
  final int currentMeters;
  final int targetMeters;
  final double completedPercent;
  final double remainingPercent;
  final List<double> sectorRhythmPoints;
  final bool isDark;

  const CorteRebobinamentoCard({
    super.key,
    required this.currentMeters,
    required this.targetMeters,
    required this.completedPercent,
    required this.remainingPercent,
    this.sectorRhythmPoints = const [58, 70, 68, 72, 72],
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    const remainingDays = 27;
    final remainingMeters = targetMeters - currentMeters;
    final requiredPerDay = remainingMeters > 0 ? (remainingMeters / remainingDays).round() : 0;

    final Color concludedColor = isDark ? AppColors.successDark : AppColors.successLight;
    final Color remainingColor = isDark ? AppColors.dangerDark : AppColors.dangerLight;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : AppColors.lightCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.35) : const Color(0x0C0F172A),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'CORTE & REBOBINAMENTO',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: isDark ? Colors.white : AppColors.brandPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0D1C38) : const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isDark ? const Color(0xFF0284C7) : const Color(0xFFBAE6FD),
                  ),
                ),
                child: Text(
                  'META DO MÊS',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Target Header Chip
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0B172C) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Atual: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  Formatters.formatInteger(currentMeters),
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Outfit',
                  ),
                ),
                Text(
                  '  /  Meta: ',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${Formatters.formatInteger(targetMeters)} m',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Donut Gauge
          SizedBox(
            width: 190,
            height: 190,
            child: CustomDonutGauge(
              completedPercent: completedPercent,
              remainingPercent: remainingPercent,
              concludedColor: concludedColor,
              remainingColor: remainingColor,
              isDark: isDark,
            ),
          ),
          const SizedBox(height: 14),

          // Legend Tiles
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTelemetryTile(
                label: 'RESTANTE',
                percent: Formatters.formatPercent(remainingPercent),
                dotColor: remainingColor,
                bgColor: isDark ? const Color(0xFF4C0519) : const Color(0xFFFFF1F2),
                borderColor: isDark ? const Color(0xFF9F1239) : const Color(0xFFFECDD3),
                textColor: isDark ? Colors.white : AppColors.lightTextPrimary,
                labelColor: isDark ? const Color(0xFFFDA4AF) : const Color(0xFF9F1239),
              ),
              const SizedBox(width: 14),
              _buildTelemetryTile(
                label: 'FEITO',
                percent: Formatters.formatPercent(completedPercent),
                dotColor: concludedColor,
                bgColor: isDark ? const Color(0xFF064E3B) : const Color(0xFFECFDF5),
                borderColor: isDark ? const Color(0xFF0F766E) : const Color(0xFFA7F3D0),
                textColor: isDark ? Colors.white : AppColors.lightTextPrimary,
                labelColor: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF065F46),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Sector Cadence
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CADÊNCIA DIÁRIA NECESSÁRIA',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                      color: isDark ? AppColors.darkTextMuted : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${Formatters.formatInteger(requiredPerDay)} m/dia',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F1B33) : const Color(0xFFE0F2FE),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark ? AppColors.darkCardBorder : const Color(0xFFBAE6FD),
                  ),
                ),
                child: Text(
                  '$remainingDays dias restantes',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 10),

          // Sector Rhythm Trend Line Chart
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '% DO RITMO DO SETOR — 1º TURNO',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
              ),
            ),
          ),
          const SizedBox(height: 8),

          RhythmLineChart(
            points: sectorRhythmPoints,
            isDark: isDark,
            height: 95,
            timeLabels: const ['06h', '08h', '10h', '12h', '14h'],
          ),
        ],
      ),
    );
  }

  Widget _buildTelemetryTile({
    required String label,
    required String percent,
    required Color dotColor,
    required Color bgColor,
    required Color borderColor,
    required Color textColor,
    required Color labelColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: labelColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            percent,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: textColor,
              fontFamily: 'Outfit',
            ),
          ),
        ],
      ),
    );
  }
}
