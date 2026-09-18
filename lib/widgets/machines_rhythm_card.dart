import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/machine_indicator.dart';
import '../providers/indicators_state.dart';
import 'rhythm_line_chart.dart';

class MachinesRhythmCard extends StatelessWidget {
  final List<MachineIndicator> machines;
  final bool isDark;
  final String? shiftTitle;
  final List<String>? timeLabels;
  final ShiftFilter? currentShift;

  const MachinesRhythmCard({
    super.key,
    required this.machines,
    required this.isDark,
    this.shiftTitle,
    this.timeLabels,
    this.currentShift,
  });

  List<double> _getMachinePoints(MachineIndicator m) {
    if (m.rhythmPoints.isNotEmpty && (currentShift == null || currentShift == ShiftFilter.shift1)) {
      return m.rhythmPoints;
    }
    final pct = m.rhythmPct;
    if (currentShift == ShiftFilter.shift2) {
      return [pct * 0.84, pct * 0.94, pct * 1.02, pct * 0.97, pct];
    } else if (currentShift == ShiftFilter.shift3) {
      return [pct * 0.80, pct * 0.90, pct * 0.96, pct * 0.93, pct * 0.95];
    } else if (currentShift == ShiftFilter.fullDay) {
      return [pct * 0.88, pct * 0.95, pct * 1.01, pct * 0.96, pct];
    }
    return m.rhythmPoints.isNotEmpty ? m.rhythmPoints : [pct * 0.85, pct * 0.95, pct];
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? AppColors.darkCardBg : Colors.white;
    final cardBorder = isDark ? AppColors.darkCardBorder : const Color(0xFFCBD5E1);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isDark ? 0.30 : 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(isMobile ? 14 : 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0EA5E9).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.insights_rounded,
                      size: 18,
                      color: Color(0xFF0EA5E9),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '% DO RITMO POR MÁQUINA — ${shiftTitle ?? "TURNO ATUAL"}',
                          style: TextStyle(
                            fontSize: isMobile ? 12 : 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.9,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF334155),
                          ),
                        ),
                        Text(
                          'Evolução contínua do ritmo real vs meta estabelecida',
                          style: TextStyle(
                            fontSize: 10,
                            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF10B981).withOpacity(0.15)
                          : const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF10B981).withOpacity(0.35)
                            : const Color(0xFFA7F3D0),
                      ),
                    ),
                    child: const Text(
                      '--- META 100%',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Grid Responsivo de Máquinas com espaçamento calibrado
              _buildResponsiveGrid(constraints),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResponsiveGrid(BoxConstraints constraints) {
    final int columns;
    if (constraints.maxWidth > 950) {
      columns = 3;
    } else if (constraints.maxWidth > 580) {
      columns = 2;
    } else {
      columns = 1;
    }

    const double spacing = 12;
    final itemWidth = (constraints.maxWidth - ((columns - 1) * spacing)) / columns;

    return Wrap(
      spacing: spacing,
      runSpacing: spacing,
      children: machines.map((m) {
        return SizedBox(
          width: itemWidth,
          child: _buildMachineMiniChart(m),
        );
      }).toList(),
    );
  }

  Widget _buildMachineMiniChart(MachineIndicator m) {
    final isGood = m.rhythmPct >= 80;
    final badgeColor = isGood ? const Color(0xFF10B981) : const Color(0xFFF59E0B);

    final miniBg = isDark ? const Color(0xFF0C1628) : const Color(0xFFF8FAFC);
    final miniBorder = isDark ? const Color(0xFF1E2D4E) : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: miniBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: miniBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.15 : 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header (Código + Indicador de Status + Ritmo %)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: m.statusColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    m.code,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: badgeColor.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  '${m.rhythmPct.toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: badgeColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Gráfico de Ritmo com Meta 100% Tracejada e Horários Dinâmicos
          RhythmLineChart(
            points: _getMachinePoints(m),
            series: m.rhythmSeries.isNotEmpty ? m.rhythmSeries : null,
            isDark: isDark,
            height: 100,
            timeLabels: timeLabels ?? const ['06h', '10h', '14h'],
            lineColor: m.statusColor,
          ),
        ],
      ),
    );
  }
}
