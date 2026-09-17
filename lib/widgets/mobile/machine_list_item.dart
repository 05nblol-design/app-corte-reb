import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/formatters.dart';
import '../../models/machine_indicator.dart';

class MachineListItem extends StatelessWidget {
  final MachineIndicator machine;
  final bool isDark;
  final VoidCallback onTap;

  const MachineListItem({
    super.key,
    required this.machine,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isScrapExceeded = machine.scrapMonth > machine.scrapTarget;
    final double targetProgress = machine.shiftTarget > 0
        ? (machine.todayMeters / machine.shiftTarget).clamp(0.0, 1.0)
        : 0.0;

    // Theme-calibrated colors for high contrast
    final Color metersTodayColor = isDark ? const Color(0xFF34D399) : AppColors.successLight;
    final Color monthMetersColor = isDark ? Colors.white : AppColors.lightTextPrimary;
    final Color speedColor = isDark ? AppColors.infoDark : AppColors.infoLight;
    final Color labelColor = isDark ? AppColors.darkTextMuted : const Color(0xFF475569);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : AppColors.lightCardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.3) : const Color(0x0A0F172A),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Code + Status Tag + Aparas Badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          machine.code,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.4,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildStatusBadge(machine.status),
                        if (machine.code == 'BCR015') ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.brandSecondary.withOpacity(0.2)
                                  : const Color(0xFFE0F2FE),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: isDark ? const Color(0xFF0369A1) : const Color(0xFFBAE6FD),
                              ),
                            ),
                            child: Text(
                              'LÍDER',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0369A1),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Aparas Badge (Theme-calibrated, high contrast)
                    _buildScrapBadge(isScrapExceeded, machine.scrapMonth),
                  ],
                ),

                const SizedBox(height: 6),

                // Order Description (Crisp, High Contrast)
                Text(
                  machine.productionOrder,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),

                const SizedBox(height: 12),
                Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
                const SizedBox(height: 10),

                // Data Metrics (Clean 3-column row with high contrast)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Metros Hoje
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'METROS HOJE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: labelColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${Formatters.formatInteger(machine.todayMeters)} m',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: metersTodayColor,
                          ),
                        ),
                      ],
                    ),

                    // Metros Mês
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ACUMULADO MÊS',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: labelColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${Formatters.formatInteger(machine.monthMeters)} m',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: monthMetersColor,
                          ),
                        ),
                      ],
                    ),

                    // Velocidade & OEE
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'VELOCIDADE / OEE',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                            color: labelColor,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${machine.speedMpm} m/min • ${machine.oee}%',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: speedColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Clean Progress Line
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: targetProgress,
                    minHeight: 4,
                    backgroundColor: isDark ? const Color(0xFF1E2D4E) : const Color(0xFFE2E8F0),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      machine.status == 'running'
                          ? (isDark ? AppColors.brandSecondary : const Color(0xFF0284C7))
                          : (isDark ? AppColors.warningDark : AppColors.warningLight),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bg;
    Color border;
    Color fg;
    String label;

    switch (status) {
      case 'running':
        bg = isDark ? AppColors.successBgDark : AppColors.successBgLight;
        border = isDark ? AppColors.successBorderDark : AppColors.successBorderLight;
        fg = isDark ? AppColors.successTextDark : AppColors.successTextLight;
        label = 'EM OPERAÇÃO';
        break;
      case 'setup':
        bg = isDark ? AppColors.warningBgDark : AppColors.warningBgLight;
        border = isDark ? AppColors.warningBorderDark : AppColors.warningBorderLight;
        fg = isDark ? AppColors.warningTextDark : AppColors.warningTextLight;
        label = 'SETUP';
        break;
      default:
        bg = isDark ? AppColors.dangerBgDark : AppColors.dangerBgLight;
        border = isDark ? AppColors.dangerBorderDark : AppColors.dangerBorderLight;
        fg = isDark ? AppColors.dangerTextDark : AppColors.dangerTextLight;
        label = 'PARADA';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: border),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: fg,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildScrapBadge(bool isExceeded, double scrapValue) {
    final Color bg = isExceeded
        ? (isDark ? AppColors.dangerBgDark : AppColors.dangerBgLight)
        : (isDark ? AppColors.successBgDark : AppColors.successBgLight);

    final Color border = isExceeded
        ? (isDark ? AppColors.dangerBorderDark : AppColors.dangerBorderLight)
        : (isDark ? AppColors.successBorderDark : AppColors.successBorderLight);

    final Color fg = isExceeded
        ? (isDark ? AppColors.dangerTextDark : AppColors.dangerTextLight)
        : (isDark ? AppColors.successTextDark : AppColors.successTextLight);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: border, width: 1),
      ),
      child: Text(
        'Aparas: ${Formatters.formatPercent(scrapValue)}',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: fg,
        ),
      ),
    );
  }
}
