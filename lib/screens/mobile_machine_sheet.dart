import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../models/machine_indicator.dart';

class MobileMachineSheet extends StatelessWidget {
  final MachineIndicator machine;
  final bool isDark;

  const MobileMachineSheet({
    super.key,
    required this.machine,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final bool isAlert = machine.scrapMonth > machine.scrapTarget;
    final Color scrapColor = isAlert
        ? (isDark ? AppColors.dangerDark : AppColors.dangerLight)
        : (isDark ? AppColors.successDark : AppColors.successLight);

    final Color todayColor = isDark ? const Color(0xFF34D399) : AppColors.successLight;
    final Color speedColor = isDark ? AppColors.infoDark : AppColors.infoLight;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111C33) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
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
                  _buildStatusBadge(machine.status),
                ],
              ),

              const SizedBox(height: 14),
              Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
              const SizedBox(height: 12),

              // Active Order Info
              Container(
                padding: const EdgeInsets.all(12),
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
                      'ORDEM DE PRODUÇÃO (OP)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: isDark ? AppColors.darkTextMuted : const Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      machine.productionOrder,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Operador: ${machine.operatorName}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFFCBD5E1) : AppColors.lightTextSecondary,
                          ),
                        ),
                        Text(
                          '${machine.speedMpm} m/min',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: speedColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // 4 KPI Cards Grid
              Row(
                children: [
                  _buildKpiTile('METROS HOJE', '${Formatters.formatInteger(machine.todayMeters)} m', todayColor),
                  const SizedBox(width: 8),
                  _buildKpiTile('METROS MÊS', '${Formatters.formatInteger(machine.monthMeters)} m', isDark ? Colors.white : AppColors.lightTextPrimary),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildKpiTile(
                    '% APARAS MÊS',
                    Formatters.formatPercent(machine.scrapMonth),
                    scrapColor,
                  ),
                  const SizedBox(width: 8),
                  _buildKpiTile('EFICIÊNCIA OEE', '${machine.oee}%', speedColor),
                ],
              ),

              const SizedBox(height: 16),

              // Scrap reasons breakdown
              Text(
                'DESVIOS DE APARAS (MÊS)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: isDark ? AppColors.darkTextMuted : const Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 8),

              ...machine.scrapReasons.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              r.category,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: isDark ? Colors.white : AppColors.lightTextPrimary,
                              ),
                            ),
                            Text(
                              '${Formatters.formatDecimal(r.percentage)}% (${r.weightKg} kg)',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isDark ? const Color(0xFFCBD5E1) : AppColors.lightTextSecondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(2),
                          child: LinearProgressIndicator(
                            value: r.percentage / 100.0,
                            minHeight: 5,
                            backgroundColor: isDark ? const Color(0xFF1E2D4E) : const Color(0xFFE2E8F0),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isDark ? AppColors.dangerDark : AppColors.dangerLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),

              const SizedBox(height: 16),

              // Bottom Close Button
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPrimary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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

  Widget _buildKpiTile(String label, String value, Color color) {
    return Expanded(
      child: Container(
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
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: isDark ? AppColors.darkTextMuted : const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 2),
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
