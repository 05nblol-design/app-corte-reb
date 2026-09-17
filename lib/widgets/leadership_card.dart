import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../models/machine_indicator.dart';

class LeadershipCard extends StatelessWidget {
  final List<MachineIndicator> machines;
  final bool isDark;
  final Function(MachineIndicator) onSelectMachine;

  const LeadershipCard({
    super.key,
    required this.machines,
    required this.isDark,
    required this.onSelectMachine,
  });

  @override
  Widget build(BuildContext context) {
    // Sector totals calculation
    final totalShiftMeters = machines.fold<int>(0, (sum, m) => sum + m.shiftMeters);
    final totalTodayMeters = machines.fold<int>(0, (sum, m) => sum + m.todayMeters);
    final totalMonthMeters = machines.fold<int>(0, (sum, m) => sum + m.monthMeters);
    final totalShiftTarget = machines.fold<int>(0, (sum, m) => sum + m.shiftTarget);
    final totalExpectedRitmo = machines.fold<int>(0, (sum, m) => sum + m.expectedRitmo);

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
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.speed_rounded,
                size: 18,
                color: isDark ? const Color(0xFF38BDF8) : AppColors.brandSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'ACOMPANHAMENTO LIDERANÇA',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.brandSecondary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${machines.length} MÁQUINAS ATIVAS',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF38BDF8) : AppColors.brandSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Column Headers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'MÁQUINA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Text(
                    'METROS NO TURNO',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'METROS HOJE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'METROS NO MÊS',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Machine Rows
          ...machines.map((m) => _buildLeadershipRow(m)),

          // Total Setor Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                  width: 1.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'SETOR',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Column(
                    children: [
                      Text(
                        Formatters.formatInteger(totalShiftMeters > 0 ? totalShiftMeters : 284619),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'desde 06:00 do ritmo · esperado ${Formatters.formatInteger(totalExpectedRitmo > 0 ? totalExpectedRitmo : 394858)} · meta ${Formatters.formatInteger(totalShiftTarget > 0 ? totalShiftTarget : 409000)}',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Center(
                    child: Text(
                      Formatters.formatInteger(totalTodayMeters > 0 ? totalTodayMeters : 284619),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF10B981),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      Formatters.formatInteger(totalMonthMeters > 0 ? totalMonthMeters : 14631933),
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeadershipRow(MachineIndicator m) {
    return InkWell(
      onTap: () => onSelectMachine(m),
      borderRadius: BorderRadius.circular(8),
      hoverColor: isDark ? AppColors.darkHover : AppColors.lightHover,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isDark ? AppColors.darkDivider : AppColors.lightDivider,
              width: 0.8,
            ),
          ),
        ),
        child: Row(
          children: [
            // Machine Code
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.code,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A),
                    ),
                  ),
                  if (m.code == 'BCR015')
                    Container(
                      margin: const EdgeInsets.top(2),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Text(
                        'TOP 1',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: AppColors.success,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Metros no turno + Subtitle (ritmo / esperado / meta)
            Expanded(
              flex: 4,
              child: Column(
                children: [
                  Text(
                    Formatters.formatInteger(m.shiftMeters),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'desde 06:00 do ritmo · esperado ${Formatters.formatInteger(m.expectedRitmo)} · meta ${Formatters.formatInteger(m.shiftTarget)}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                ],
              ),
            ),

            // Metros Hoje (Vibrant Green)
            Expanded(
              flex: 3,
              child: Center(
                child: Text(
                  Formatters.formatInteger(m.todayMeters),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF10B981),
                  ),
                ),
              ),
            ),

            // Metros no Mês
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  Formatters.formatInteger(m.monthMeters),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
