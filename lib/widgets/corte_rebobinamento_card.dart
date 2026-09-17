import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import 'custom_donut_gauge.dart';

class CorteRebobinamentoCard extends StatelessWidget {
  final int currentMeters;
  final int targetMeters;
  final double completedPercent;
  final double remainingPercent;
  final bool isDark;

  const CorteRebobinamentoCard({
    super.key,
    required this.currentMeters,
    required this.targetMeters,
    required this.completedPercent,
    required this.remainingPercent,
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

          // Target Header Chip (Telemetry Console)
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
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFCBD5E1) : AppColors.lightTextSecondary,
                  ),
                ),
                Text(
                  Formatters.formatInteger(currentMeters),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    fontFamily: 'Outfit',
                  ),
                ),
                Text(
                  '  /  Meta: ',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFCBD5E1) : AppColors.lightTextSecondary,
                  ),
                ),
                Text(
                  Formatters.formatInteger(targetMeters),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    fontFamily: 'Outfit',
                  ),
                ),
                Text(
                  ' m',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Donut Gauge (High-Density SCADA)
          CustomDonutGauge(
            completedPercent: completedPercent,
            remainingPercent: remainingPercent,
            size: 205,
            strokeWidth: 20,
            centerTitle: '${Formatters.formatDecimal(completedPercent)}%',
            centerSubtitle: 'PROGRESSO',
            isDark: isDark,
          ),

          const SizedBox(height: 18),

          // Legend (Feito vs Restante - High-Precision Badges)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Restante
              _buildTelemetryTile(
                label: 'RESTANTE',
                percent: '${Formatters.formatDecimal(remainingPercent)}%',
                dotColor: remainingColor,
                bgColor: isDark ? AppColors.dangerBgDark : AppColors.dangerBgLight,
                borderColor: isDark ? AppColors.dangerBorderDark : AppColors.dangerBorderLight,
                textColor: isDark ? Colors.white : AppColors.lightTextPrimary,
                labelColor: isDark ? AppColors.dangerTextDark : AppColors.dangerTextLight,
              ),
              const SizedBox(width: 14),
              // Feito
              _buildTelemetryTile(
                label: 'FEITO',
                percent: '${Formatters.formatDecimal(completedPercent)}%',
                dotColor: concludedColor,
                bgColor: isDark ? AppColors.successBgDark : AppColors.successBgLight,
                borderColor: isDark ? AppColors.successBorderDark : AppColors.successBorderLight,
                textColor: isDark ? Colors.white : AppColors.lightTextPrimary,
                labelColor: isDark ? AppColors.successTextDark : AppColors.successTextLight,
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
          const SizedBox(height: 12),

          // Cadence Helper
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
