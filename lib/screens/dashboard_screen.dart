import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/responsive.dart';
import '../models/machine_indicator.dart';
import '../providers/indicators_state.dart';
import '../widgets/header_nav_bar.dart';
import '../widgets/transfer_card.dart';
import '../widgets/scrap_table_card.dart';
import '../widgets/leadership_card.dart';
import '../widgets/corte_rebobinamento_card.dart';
import '../widgets/machines_rhythm_card.dart';
import '../widgets/machine_detail_dialog.dart';

class DashboardScreen extends StatefulWidget {
  final IndicatorsState state;

  const DashboardScreen({
    super.key,
    required this.state,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  void _openMachineDetail(MachineIndicator machine) {
    showDialog(
      context: context,
      builder: (context) => MachineDetailDialog(
        machine: machine,
        isDark: widget.state.isDarkMode,
        timeLabels: widget.state.currentShiftTimeLabels,
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.state.isDarkMode;
    final isMobile = Responsive.isMobile(context);
    final isTablet = Responsive.isTablet(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      body: SafeArea(
        child: Column(
          children: [
            // Header Top Bar
            HeaderNavBar(
              state: widget.state,
            ),

            // Main Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(isMobile ? 12 : 20),
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: widget.state.isTVMode ? double.infinity : 1580,
                    ),
                    child: isMobile
                        ? _buildMobileLayout(isDark)
                        : (isTablet
                            ? _buildTabletLayout(isDark)
                            : _buildDesktopLayout(isDark)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Desktop Layout (Exact Reference Layout)
  Widget _buildDesktopLayout(bool isDark) {
    return Column(
      children: [
        // Top Row: [TRANSFERÊNCIA] | [APARAS - % SOBRE A PRODUÇÃO]
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 5,
              child: TransferCard(
                transfer: widget.state.transfer,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 7,
              child: ScrapTableCard(
                machines: widget.state.machines,
                sectorShift: widget.state.sectorScrapShift,
                sectorDay: widget.state.sectorScrapDay,
                sectorMonth: widget.state.sectorScrapMonth,
                scrapGoal: widget.state.scrapGoal,
                isDark: isDark,
                onSelectMachine: _openMachineDetail,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Middle Row: [ACOMPANHAMENTO LIDERANÇA] | [CORTE & REBOBINAMENTO]
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 7,
              child: LeadershipCard(
                machines: widget.state.machines,
                isDark: isDark,
                onSelectMachine: _openMachineDetail,
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              flex: 5,
              child: CorteRebobinamentoCard(
                currentMeters: widget.state.corteCurrentMeters,
                targetMeters: widget.state.corteTargetMeters,
                completedPercent: widget.state.corteConcludedPercent,
                remainingPercent: widget.state.corteRemainingPercent,
                sectorRhythmPoints: widget.state.currentSectorRhythmPoints,
                sectorRhythmSeries: widget.state.currentSectorRhythmSeries,
                shiftTitle: widget.state.shiftShortName,
                timeLabels: widget.state.currentSectorTimeLabels,
                isDark: isDark,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Bottom Row: [% DO RITMO POR MÁQUINA — CONFORME TURNO]
        MachinesRhythmCard(
          machines: widget.state.machines,
          isDark: isDark,
          shiftTitle: widget.state.shiftShortName,
          timeLabels: widget.state.currentShiftTimeLabels,
          currentShift: widget.state.selectedShift,
        ),
      ],
    );
  }

  /// Tablet Layout
  Widget _buildTabletLayout(bool isDark) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TransferCard(
                transfer: widget.state.transfer,
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CorteRebobinamentoCard(
                currentMeters: widget.state.corteCurrentMeters,
                targetMeters: widget.state.corteTargetMeters,
                completedPercent: widget.state.corteConcludedPercent,
                remainingPercent: widget.state.corteRemainingPercent,
                sectorRhythmPoints: widget.state.currentSectorRhythmPoints,
                sectorRhythmSeries: widget.state.currentSectorRhythmSeries,
                shiftTitle: widget.state.shiftShortName,
                timeLabels: widget.state.currentSectorTimeLabels,
                isDark: isDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ScrapTableCard(
          machines: widget.state.machines,
          sectorShift: widget.state.sectorScrapShift,
          sectorDay: widget.state.sectorScrapDay,
          sectorMonth: widget.state.sectorScrapMonth,
          scrapGoal: widget.state.scrapGoal,
          shiftLabel: widget.state.shiftDisplayName,
          isDark: isDark,
          onSelectMachine: _openMachineDetail,
        ),
        const SizedBox(height: 16),
        LeadershipCard(
          machines: widget.state.machines,
          shiftStartTime: widget.state.shiftStartTime,
          isDark: isDark,
          onSelectMachine: _openMachineDetail,
        ),
        const SizedBox(height: 16),
        MachinesRhythmCard(
          machines: widget.state.machines,
          shiftTitle: widget.state.shiftShortName,
          timeLabels: widget.state.currentShiftTimeLabels,
          currentShift: widget.state.selectedShift,
          isDark: isDark,
        ),
      ],
    );
  }

  /// Mobile Layout (Stacked Vertically)
  Widget _buildMobileLayout(bool isDark) {
    return Column(
      children: [
        TransferCard(
          transfer: widget.state.transfer,
          isDark: isDark,
        ),
        const SizedBox(height: 14),
        CorteRebobinamentoCard(
          currentMeters: widget.state.corteCurrentMeters,
          targetMeters: widget.state.corteTargetMeters,
          completedPercent: widget.state.corteConcludedPercent,
          remainingPercent: widget.state.corteRemainingPercent,
          sectorRhythmPoints: widget.state.currentSectorRhythmPoints,
          sectorRhythmSeries: widget.state.currentSectorRhythmSeries,
          shiftTitle: widget.state.shiftShortName,
          timeLabels: widget.state.currentSectorTimeLabels,
          isDark: isDark,
        ),
        const SizedBox(height: 14),
        ScrapTableCard(
          machines: widget.state.machines,
          sectorShift: widget.state.sectorScrapShift,
          sectorDay: widget.state.sectorScrapDay,
          sectorMonth: widget.state.sectorScrapMonth,
          scrapGoal: widget.state.scrapGoal,
          shiftLabel: widget.state.shiftDisplayName,
          isDark: isDark,
          onSelectMachine: _openMachineDetail,
        ),
        const SizedBox(height: 14),
        LeadershipCard(
          machines: widget.state.machines,
          shiftStartTime: widget.state.shiftStartTime,
          isDark: isDark,
          onSelectMachine: _openMachineDetail,
        ),
        const SizedBox(height: 14),
        MachinesRhythmCard(
          machines: widget.state.machines,
          shiftTitle: widget.state.shiftShortName,
          timeLabels: widget.state.currentShiftTimeLabels,
          currentShift: widget.state.selectedShift,
          isDark: isDark,
        ),
      ],
    );
  }
}
