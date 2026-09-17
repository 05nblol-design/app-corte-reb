import 'package:flutter/material.dart';
import '../models/machine_indicator.dart';
import 'rhythm_line_chart.dart';

class MachinesRhythmCard extends StatelessWidget {
  final List<MachineIndicator> machines;
  final bool isDark;

  const MachinesRhythmCard({
    super.key,
    required this.machines,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = isDark ? const Color(0xFF101B30) : Colors.white;
    final cardBorder = isDark ? const Color(0xFF1E2E4E) : const Color(0xFFCBD5E1);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.35 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '% DO RITMO POR MÁQUINA — 1º TURNO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF10B981).withOpacity(0.15)
                      : const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF10B981).withOpacity(0.3)
                        : const Color(0xFFA7F3D0),
                  ),
                ),
                child: const Text(
                  '--- META 100%',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Layout Builder for Responsive Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final int columns;
              if (constraints.maxWidth > 900) {
                columns = 3;
              } else if (constraints.maxWidth > 550) {
                columns = 2;
              } else {
                columns = 1;
              }

              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: machines.map((m) {
                  final itemWidth = (constraints.maxWidth - ((columns - 1) * 12)) / columns;
                  return SizedBox(
                    width: itemWidth,
                    child: _buildMachineMiniChart(m),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMachineMiniChart(MachineIndicator m) {
    final isGood = m.rhythmPct >= 80;
    final badgeColor = isGood ? const Color(0xFF059669) : const Color(0xFFDC2626);
    final badgeBg = isDark
        ? badgeColor.withOpacity(0.15)
        : (isGood ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2));

    final miniBg = isDark ? const Color(0xFF0C1628) : const Color(0xFFF8FAFC);
    final miniBorder = isDark ? const Color(0xFF1E2D4E) : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: miniBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: miniBorder),
      ),
      child: Column(
        children: [
          // Header (Code + %)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                m.code,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: badgeBg,
                  borderRadius: BorderRadius.circular(4),
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
          const SizedBox(height: 6),

          // Chart
          RhythmLineChart(
            points: m.rhythmPoints,
            isDark: isDark,
            height: 90,
            timeLabels: const ['06h', '10h', '14h'],
          ),
        ],
      ),
    );
  }
}
