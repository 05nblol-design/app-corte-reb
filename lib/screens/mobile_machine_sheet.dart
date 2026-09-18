import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../models/machine_indicator.dart';
import '../widgets/rhythm_line_chart.dart';

class MobileMachineSheet extends StatelessWidget {
  final MachineIndicator machine;
  final bool isDark;
  final List<String> timeLabels;

  const MobileMachineSheet({
    super.key,
    required this.machine,
    required this.isDark,
    this.timeLabels = const ['06h', '10h', '14h'],
  });

  @override
  Widget build(BuildContext context) {
    final bool isScrapAlert = machine.scrapMonth > machine.scrapTarget;
    final Color scrapMonthColor = isScrapAlert
        ? (isDark ? AppColors.dangerDark : AppColors.dangerLight)
        : (isDark ? AppColors.successDark : AppColors.successLight);

    final Color rhythmBadgeColor = machine.rhythmPct >= 100
        ? const Color(0xFF10B981)
        : (machine.rhythmPct >= 80 ? const Color(0xFF3B82F6) : const Color(0xFFEF4444));

    final Color todayColor = isDark ? const Color(0xFF34D399) : AppColors.successLight;
    final Color shiftColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111C33) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        machine.code,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : AppColors.brandPrimary,
                        ),
                      ),
                      Text(
                        machine.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFFCBD5E1) : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                  _buildStatusBadge(machine),
                ],
              ),

              if (machine.productionOrder.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0C1527) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ORDEM DE PRODUÇÃO (OP)',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                          color: isDark ? AppColors.darkTextMuted : const Color(0xFF475569),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        machine.productionOrder,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.lightTextPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // Prominent Real Telemetry Analysis Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    width: 1.2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.insights_rounded,
                              size: 16,
                              color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'ACOMPANHAMENTO DO RITMO',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.6,
                                color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: rhythmBadgeColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: rhythmBadgeColor.withOpacity(0.3)),
                          ),
                          child: Text(
                            'RITMO: ${machine.rhythmPct.toInt()}%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: rhythmBadgeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${machine.shiftAnalysisText.isNotEmpty ? machine.shiftAnalysisText : "desde 06:02"} do ritmo · esperado ${Formatters.formatInteger(machine.expectedRitmo)} · meta ${Formatters.formatInteger(machine.shiftTarget)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              // Mini Rhythm Chart
              if (machine.rhythmSeries.isNotEmpty || machine.rhythmPoints.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF0B1424) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF1E2D4E) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'EVOLUÇÃO DO RITMO NO TURNO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            'Meta: 100%',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              color: isDark ? const Color(0xFF10B981) : const Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      RhythmLineChart(
                        series: machine.rhythmSeries,
                        points: machine.rhythmPoints,
                        timeLabels: timeLabels,
                        targetValue: 100.0,
                        isDark: isDark,
                        height: 100.0,
                        lineColor: machine.statusColor,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14),

              // 6 KPI Grid (Real Telemetry Data)
              Row(
                children: [
                  _buildKpiTile('METROS HOJE', '${Formatters.formatInteger(machine.todayMeters)} m', todayColor),
                  const SizedBox(width: 8),
                  _buildKpiTile('METROS TURNO', '${Formatters.formatInteger(machine.shiftMeters)} m', shiftColor),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildKpiTile('ACUMULADO MÊS', '${Formatters.formatInteger(machine.monthMeters)} m', isDark ? Colors.white : AppColors.lightTextPrimary),
                  const SizedBox(width: 8),
                  _buildKpiTile('META DO TURNO', '${Formatters.formatInteger(machine.shiftTarget)} m', isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildKpiTile(
                    'APARAS TURNO',
                    Formatters.formatPercent(machine.scrapShift ?? 0),
                    (machine.scrapShift ?? 0) > machine.scrapTarget
                        ? (isDark ? AppColors.dangerDark : AppColors.dangerLight)
                        : (isDark ? AppColors.successDark : AppColors.successLight),
                  ),
                  const SizedBox(width: 8),
                  _buildKpiTile(
                    'APARAS MÊS',
                    Formatters.formatPercent(machine.scrapMonth),
                    scrapMonthColor,
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Bottom Close Button
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Fechar Detalhes', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(MachineIndicator m) {
    final color = m.statusColor;
    final label = m.statusDisplay;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.18 : 0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: isDark ? 0.55 : 0.40)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: 0.4,
        ),
      ),
    );
  }


  Widget _buildKpiTile(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0C1527) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: isDark ? AppColors.darkTextMuted : const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: color,
                fontFamily: 'Outfit',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
