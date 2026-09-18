import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../core/utils/responsive.dart';
import '../providers/indicators_state.dart';
import '../models/alert_model.dart';
import 'alerts_dialog.dart';

class HeaderNavBar extends StatelessWidget {
  final IndicatorsState state;
  final VoidCallback? onOpenAlerts;

  const HeaderNavBar({
    super.key,
    required this.state,
    this.onOpenAlerts,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = state.isDarkMode;
    final isMobile = Responsive.isMobile(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 24,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : Colors.white,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Logo & Title
          _buildLogoAndTitle(context, isDark, isMobile),

          if (!isMobile) ...[
            const SizedBox(width: 20),
            // Shift Selector Pills
            _buildShiftSelector(isDark),
          ],

          const Spacer(),

          // Right Controls (Live badge, Clock, Refresh, Alerts, TV, Theme)
          _buildActionControls(context, isDark, isMobile),
        ],
      ),
    );
  }

  Widget _buildLogoAndTitle(BuildContext context, bool isDark, bool isMobile) {
    return Row(
      children: [
        // Zaraplast Stylized Icon/Badge
        // Zaraplast Official Logo Emblem
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F1E36) : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? const Color(0xFF1E3A68) : const Color(0xFFCBD5E1),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0284C7).withOpacity(isDark ? 0.30 : 0.12),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(5),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              'assets/zaraplast_logo.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'ZARAPLAST',
                  style: TextStyle(
                    fontSize: isMobile ? 15 : 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: isDark ? Colors.white : AppColors.brandPrimary,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.brandSecondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: AppColors.brandSecondary.withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    'INDICADORES',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: isDark ? const Color(0xFF38BDF8) : AppColors.brandSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              'Painel Operacional • Corte & Rebobinamento',
              style: TextStyle(
                fontSize: isMobile ? 10 : 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShiftSelector(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _shiftPill(
            IndicatorsState.getCurrentShift() == ShiftFilter.shift1
                ? 'Turno A • Agora'
                : 'Turno A',
            ShiftFilter.shift1,
            isDark,
          ),
          _shiftPill(
            IndicatorsState.getCurrentShift() == ShiftFilter.shift2
                ? 'Turno B • Agora'
                : 'Turno B',
            ShiftFilter.shift2,
            isDark,
          ),
          _shiftPill(
            IndicatorsState.getCurrentShift() == ShiftFilter.shift3
                ? 'Turno C • Agora'
                : 'Turno C',
            ShiftFilter.shift3,
            isDark,
          ),
          _shiftPill('Dia 24h', ShiftFilter.fullDay, isDark),
        ],
      ),
    );
  }

  Widget _shiftPill(String title, ShiftFilter shift, bool isDark) {
    final isSelected = state.selectedShift == shift;
    return InkWell(
      onTap: () => state.setShift(shift),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.brandSecondary : AppColors.brandPrimary)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.brandSecondary.withOpacity(0.3),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          ),
        ),
      ),
    );
  }

  Widget _buildActionControls(
      BuildContext context, bool isDark, bool isMobile) {
    return Row(
      children: [
        // Live Pulse Badge
        if (!isMobile) ...[
          InkWell(
            onTap: state.toggleLiveSync,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: state.isLiveActive
                    ? AppColors.success.withOpacity(0.12)
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: state.isLiveActive
                      ? AppColors.success.withOpacity(0.4)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: state.isLiveActive ? AppColors.success : AppColors.neutral,
                      boxShadow: state.isLiveActive
                          ? [
                              BoxShadow(
                                color: AppColors.success.withOpacity(0.6),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    state.isLiveActive ? 'AO VIVO' : 'PAUSADO',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: state.isLiveActive
                          ? (isDark ? const Color(0xFF34D399) : AppColors.successDark)
                          : AppColors.neutral,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Clock & Last Sync
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                Formatters.formatTime(state.lastUpdate),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'monospace',
                  color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                ),
              ),
              Text(
                Formatters.formatDate(state.lastUpdate),
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
        ],

        // Real Telemetry Alerts Bell
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              tooltip: 'Alertas Operacionais (${state.alerts.length})',
              icon: Icon(
                state.alerts.isNotEmpty
                    ? Icons.notifications_active_rounded
                    : Icons.notifications_none_rounded,
                size: 21,
                color: state.alerts.any((a) => a.severity == AlertSeverity.danger)
                    ? AppColors.danger
                    : (state.alerts.isNotEmpty
                        ? const Color(0xFFF59E0B)
                        : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)),
              ),
              onPressed: () {
                if (onOpenAlerts != null) {
                  onOpenAlerts!();
                } else {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertsDialog(
                      alerts: state.alerts,
                      isDark: isDark,
                    ),
                  );
                }
              },
            ),
            if (state.unreadAlertsCount > 0)
              Positioned(
                top: 6,
                right: 6,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppColors.danger,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Center(
                    child: Text(
                      '${state.unreadAlertsCount}',
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),

        // Manual Refresh Button
        IconButton(
          tooltip: 'Atualizar Dados',
          icon: Icon(
            Icons.refresh_rounded,
            size: 20,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
          onPressed: state.manualRefresh,
        ),

        // TV Wallboard Mode Button
        if (!isMobile)
          IconButton(
            tooltip: state.isTVMode ? 'Sair do Modo TV' : 'Modo TV / Wallboard',
            icon: Icon(
              state.isTVMode ? Icons.fullscreen_exit_rounded : Icons.tv_rounded,
              size: 22,
              color: state.isTVMode
                  ? AppColors.brandSecondary
                  : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            ),
            onPressed: state.toggleTVMode,
          ),

        // Theme Toggle (Dark / Light)
        IconButton(
          tooltip: isDark ? 'Modo Claro' : 'Modo Escuro',
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            size: 20,
            color: isDark ? const Color(0xFFFBBF24) : AppColors.brandPrimary,
          ),
          onPressed: state.toggleTheme,
        ),
      ],
    );
  }
}
