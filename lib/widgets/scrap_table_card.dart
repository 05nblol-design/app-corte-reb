import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../models/machine_indicator.dart';

class ScrapTableCard extends StatelessWidget {
  final List<MachineIndicator> machines;
  final double? sectorShift;
  final double? sectorDay;
  final double sectorMonth;
  final double scrapGoal;
  final bool isDark;
  final Function(MachineIndicator) onSelectMachine;
  final String? shiftLabel;

  const ScrapTableCard({
    super.key,
    required this.machines,
    required this.sectorShift,
    required this.sectorDay,
    required this.sectorMonth,
    required this.scrapGoal,
    required this.isDark,
    required this.onSelectMachine,
    this.shiftLabel,
  });

  @override
  Widget build(BuildContext context) {
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
          // Card Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.pie_chart_outline_rounded,
                size: 18,
                color: isDark ? const Color(0xFF38BDF8) : AppColors.brandSecondary,
              ),
              const SizedBox(width: 8),
              Text(
                'APARAS — % SOBRE A PRODUÇÃO',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                ),
              ),
              const Spacer(),
              // Target Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFFEF4444).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.flag_outlined,
                      size: 12,
                      color: AppColors.danger,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Meta: 3,0%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFFFCA5A5) : AppColors.dangerDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Meta 3,0% · dia industrial das 6h às 6h',
            style: TextStyle(
              fontSize: 12,
              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: 18),

          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    'MÁQUINA',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    shiftLabel ?? '1º TURNO (AGORA)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'DIA',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'MÊS',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),

          // Machine Rows
          ...machines.map((m) => _buildMachineRow(m)),

          const SizedBox(height: 8),
          const Divider(height: 1),
          const SizedBox(height: 8),

          // SETOR Summary Row
          _buildSectorRow(),
        ],
      ),
    );
  }

  Widget _buildMachineRow(MachineIndicator m) {
    return InkWell(
      onTap: () => onSelectMachine(m),
      borderRadius: BorderRadius.circular(8),
      hoverColor: isDark ? AppColors.darkHover : AppColors.lightHover,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Code & Name
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: m.status == 'running'
                          ? AppColors.success
                          : (m.status == 'setup' ? AppColors.warning : AppColors.danger),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    m.code,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                      color: isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ),

            // 1º Turno (Agora)
            Expanded(
              flex: 3,
              child: Center(
                child: _formatScrapValue(m.scrapShift, isMonthly: false),
              ),
            ),

            // Dia
            Expanded(
              flex: 2,
              child: Center(
                child: _formatScrapValue(m.scrapDay, isMonthly: false),
              ),
            ),

            // Mês (Always colored based on goal)
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.centerRight,
                child: _formatScrapValue(m.scrapMonth, isMonthly: true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectorRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: (isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9)).withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              'SETOR',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Center(
              child: _formatScrapValue(sectorShift, isMonthly: false, isBold: true),
            ),
          ),
          Expanded(
            flex: 2,
            child: Center(
              child: _formatScrapValue(sectorDay, isMonthly: false, isBold: true),
            ),
          ),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.centerRight,
              child: _formatScrapValue(sectorMonth, isMonthly: true, isBold: true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formatScrapValue(double? value, {required bool isMonthly, bool isBold = false}) {
    if (value == null) {
      return Text(
        '--',
        style: TextStyle(
          fontSize: 14,
          fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
        ),
      );
    }

    // Logic: Scrap <= 3.0% is Green, > 3.0% is Red
    final bool isAboveGoal = value > scrapGoal;
    final Color textColor = isAboveGoal
        ? const Color(0xFFEF4444) // Red
        : const Color(0xFF10B981); // Green

    return Text(
      Formatters.formatPercent(value),
      style: TextStyle(
        fontSize: 14,
        fontWeight: isBold || isAboveGoal ? FontWeight.w800 : FontWeight.w600,
        color: textColor,
      ),
    );
  }
}
