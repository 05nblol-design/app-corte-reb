import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../models/machine_indicator.dart';
import 'rhythm_line_chart.dart';

class MachineDetailDialog extends StatelessWidget {
  final MachineIndicator machine;
  final bool isDark;
  final List<String> timeLabels;

  const MachineDetailDialog({
    super.key,
    required this.machine,
    required this.isDark,
    this.timeLabels = const ['06h', '10h', '14h'],
  });

  @override
  Widget build(BuildContext context) {
    final Color rhythmBadgeColor = machine.rhythmPct >= 100
        ? const Color(0xFF10B981)
        : (machine.rhythmPct >= 80 ? const Color(0xFF3B82F6) : const Color(0xFFEF4444));

    final Color todayColor = isDark ? const Color(0xFF34D399) : AppColors.successLight;
    final Color shiftColor = isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: isDark ? const Color(0xFF131D33) : Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 680),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.brandSecondary.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.precision_manufacturing_rounded,
                      color: AppColors.brandSecondary,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              machine.code,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: isDark ? Colors.white : const Color(0xFF0F172A),
                              ),
                            ),
                            const SizedBox(width: 10),
                            _buildStatusTag(machine),
                          ],
                        ),
                        Text(
                          machine.name,
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const SizedBox(height: 18),
              const Divider(),
              const SizedBox(height: 16),

              // Prominent Real Telemetry Analysis Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0B1120) : const Color(0xFFF1F5F9),
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
                              'ACOMPANHAMENTO DO RITMO DA MÁQUINA',
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
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF334155),
                      ),
                    ),
                  ],
                ),
              ),

              // Mini Rhythm Chart
              if (machine.rhythmSeries.isNotEmpty || machine.rhythmPoints.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
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
                            'EVOLUÇÃO DO RITMO AO LONGO DO TURNO',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: isDark ? AppColors.darkTextSecondary : const Color(0xFF64748B),
                            ),
                          ),
                          Text(
                            'Meta: 100%',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isDark ? const Color(0xFF10B981) : const Color(0xFF059669),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      RhythmLineChart(
                        series: machine.rhythmSeries,
                        points: machine.rhythmPoints,
                        timeLabels: timeLabels,
                        targetValue: 100.0,
                        isDark: isDark,
                        height: 110.0,
                        lineColor: machine.statusColor,
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 18),

              // Key Metrics Grid (6 Real Telemetry Values)
              Row(
                children: [
                  _buildStatTile(
                    label: 'Metros Hoje',
                    value: Formatters.formatInteger(machine.todayMeters),
                    accentColor: todayColor,
                  ),
                  const SizedBox(width: 10),
                  _buildStatTile(
                    label: 'Metros Turno',
                    value: Formatters.formatInteger(machine.shiftMeters),
                    accentColor: shiftColor,
                  ),
                  const SizedBox(width: 10),
                  _buildStatTile(
                    label: 'Acumulado no Mês',
                    value: Formatters.formatInteger(machine.monthMeters),
                    accentColor: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildStatTile(
                    label: 'Meta do Turno',
                    value: Formatters.formatInteger(machine.shiftTarget),
                    accentColor: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF475569),
                  ),
                  const SizedBox(width: 10),
                  _buildStatTile(
                    label: 'Aparas no Turno',
                    value: Formatters.formatPercent(machine.scrapShift ?? 0),
                    accentColor: (machine.scrapShift ?? 0) > machine.scrapTarget
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF10B981),
                  ),
                  const SizedBox(width: 10),
                  _buildStatTile(
                    label: 'Aparas Acumuladas Mês',
                    value: Formatters.formatPercent(machine.scrapMonth),
                    accentColor: machine.scrapMonth > machine.scrapTarget
                        ? const Color(0xFFEF4444)
                        : const Color(0xFF10B981),
                    badge: machine.scrapMonth > machine.scrapTarget ? 'Acima da Meta' : 'Dentro da Meta',
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Actions Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandPrimary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Fechar Detalhes', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTag(MachineIndicator m) {
    final color = m.statusColor;
    final label = m.statusDisplay;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.40)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Widget _buildStatTile({
    required String label,
    required String value,
    required Color accentColor,
    String? badge,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0B1120) : const Color(0xFFF8FAFC),
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
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: accentColor,
                fontFamily: 'Outfit',
              ),
            ),
            if (badge != null) ...[
              const SizedBox(height: 2),
              Text(
                badge,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
