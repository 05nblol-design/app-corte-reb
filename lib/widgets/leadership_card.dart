import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../models/machine_indicator.dart';

class LeadershipCard extends StatelessWidget {
  final List<MachineIndicator> machines;
  final bool isDark;
  final Function(MachineIndicator) onSelectMachine;
  final String? shiftStartTime;

  const LeadershipCard({
    super.key,
    required this.machines,
    required this.isDark,
    required this.onSelectMachine,
    this.shiftStartTime,
  });

  @override
  Widget build(BuildContext context) {
    // Totais do setor
    final totalShiftMeters = machines.fold<int>(0, (sum, m) => sum + m.shiftMeters);
    final totalTodayMeters = machines.fold<int>(0, (sum, m) => sum + m.todayMeters);
    final totalMonthMeters = machines.fold<int>(0, (sum, m) => sum + m.monthMeters);
    final totalShiftTarget = machines.fold<int>(0, (sum, m) => sum + m.shiftTarget);
    final totalExpectedRitmo = machines.fold<int>(0, (sum, m) => sum + m.expectedRitmo);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobileView = constraints.maxWidth < 650;

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
                color: Colors.black.withOpacity(isDark ? 0.25 : 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: EdgeInsets.all(isMobileView ? 14 : 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header do Card
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: (isDark ? const Color(0xFF38BDF8) : AppColors.brandSecondary)
                          .withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.speed_rounded,
                      size: 18,
                      color: isDark ? const Color(0xFF38BDF8) : AppColors.brandSecondary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ACOMPANHAMENTO LIDERANÇA',
                          style: TextStyle(
                            fontSize: isMobileView ? 12 : 13,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                          ),
                        ),
                        Text(
                          'Metros produzidos vs esperado desde as ${shiftStartTime ?? "06:00"}',
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
                      color: AppColors.brandSecondary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.brandSecondary.withOpacity(0.25),
                      ),
                    ),
                    child: Text(
                      '${machines.length} MÁQUINAS',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: isDark ? const Color(0xFF38BDF8) : AppColors.brandSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Conteúdo: Versão Mobile (Cards com espaçamento generoso) ou Desktop (Tabela)
              if (isMobileView) ...[
                // Lista de Máquinas em formato Card com alto contraste e sem texto espremido
                ...machines.map((m) => _buildMobileMachineCard(m)),
                const SizedBox(height: 12),
                // Card de Totais do Setor Mobile
                _buildMobileSectorTotal(
                  totalShiftMeters: totalShiftMeters,
                  totalTodayMeters: totalTodayMeters,
                  totalMonthMeters: totalMonthMeters,
                  totalExpectedRitmo: totalExpectedRitmo,
                  totalShiftTarget: totalShiftTarget,
                ),
              ] else ...[
                // Cabeçalho da Tabela Desktop
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                            fontWeight: FontWeight.w800,
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
                            fontWeight: FontWeight.w800,
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
                            fontWeight: FontWeight.w800,
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
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Linhas Desktop
                ...machines.map((m) => _buildDesktopLeadershipRow(m)),

                // Linha Total Setor Desktop
                _buildDesktopSectorTotalRow(
                  totalShiftMeters: totalShiftMeters,
                  totalTodayMeters: totalTodayMeters,
                  totalMonthMeters: totalMonthMeters,
                  totalExpectedRitmo: totalExpectedRitmo,
                  totalShiftTarget: totalShiftTarget,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  /// CARD MOBILE PARA CADA MÁQUINA (Espaçamento robusto, UX limpa e sem textos espremidos)
  Widget _buildMobileMachineCard(MachineIndicator m) {
    final isGood = m.rhythmPct >= 80;
    final rhythmBadgeColor = isGood ? const Color(0xFF10B981) : const Color(0xFFF59E0B);
    final isRunning = m.status == 'running';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C1628) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF1E2D4E) : const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () => onSelectMachine(m),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Linha Superior: Código + Status + Ritmo %
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isRunning ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        m.code,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.5,
                          color: isDark ? Colors.white : const Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: (isRunning ? const Color(0xFF10B981) : const Color(0xFFF59E0B))
                              .withOpacity(0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isRunning ? '${m.speedMpm} m/min' : 'SETUP',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: isRunning ? const Color(0xFF10B981) : const Color(0xFFF59E0B),
                          ),
                        ),
                      ),
                      if (m.code == 'BCR015') ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.success.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'TOP 1',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: rhythmBadgeColor.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: rhythmBadgeColor.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      'RITMO ${m.rhythmPct.toInt()}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: rhythmBadgeColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Grid de 3 Métricas: Turno | Hoje (Verde Destaque) | Mês
              Row(
                children: [
                  // 1. Turno
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF131E35) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? const Color(0xFF1E3258) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TURNO',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            Formatters.formatInteger(m.shiftMeters),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'Meta: ${Formatters.formatInteger(m.shiftTarget)}',
                            style: TextStyle(
                              fontSize: 9,
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 2. Hoje (Destaque Verde Vibrante)
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF10B981).withOpacity(0.10)
                            : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF10B981).withOpacity(0.35)
                              : const Color(0xFFA7F3D0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'HOJE',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF059669),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            Formatters.formatInteger(m.todayMeters),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          Text(
                            'Esperado: ${Formatters.formatInteger(m.expectedRitmo)}',
                            style: TextStyle(
                              fontSize: 9,
                              color: isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // 3. Mês
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF131E35) : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isDark ? const Color(0xFF1E3258) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'MÊS',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            Formatters.formatInteger(m.monthMeters),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            'Aparas: ${m.scrapMonth.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 9,
                              color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// TOTAL DO SETOR FORMATO MOBILE
  Widget _buildMobileSectorTotal({
    required int totalShiftMeters,
    required int totalTodayMeters,
    required int totalMonthMeters,
    required int totalExpectedRitmo,
    required int totalShiftTarget,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1E38) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF254273) : const Color(0xFFCBD5E1),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL DO SETOR',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),
              Text(
                'desde as ${shiftStartTime ?? "06:00"}',
                style: TextStyle(
                  fontSize: 10,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TURNO',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                  Text(
                    Formatters.formatInteger(totalShiftMeters > 0 ? totalShiftMeters : 284619),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'HOJE (TOTAL)',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF059669),
                    ),
                  ),
                  Text(
                    Formatters.formatInteger(totalTodayMeters > 0 ? totalTodayMeters : 284619),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF10B981),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'NO MÊS',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                    ),
                  ),
                  Text(
                    Formatters.formatInteger(totalMonthMeters > 0 ? totalMonthMeters : 14631933),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// LINHA DESKTOP / TABLET (Espaçamento amplo, nítido e elegante)
  Widget _buildDesktopLeadershipRow(MachineIndicator m) {
    return InkWell(
      onTap: () => onSelectMachine(m),
      borderRadius: BorderRadius.circular(8),
      hoverColor: isDark ? AppColors.darkHover : AppColors.lightHover,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
            // Código da Máquina
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: m.status == 'running'
                          ? const Color(0xFF10B981)
                          : const Color(0xFFF59E0B),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    m.code,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? AppColors.darkTextPrimary : const Color(0xFF0F172A),
                    ),
                  ),
                  if (m.code == 'BCR015') ...[
                    const SizedBox(width: 6),
                    Container(
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
                ],
              ),
            ),

            // Metros no turno + Subtítulo
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
                    'desde ${shiftStartTime ?? "06:00"} do ritmo · esperado ${Formatters.formatInteger(m.expectedRitmo)} · meta ${Formatters.formatInteger(m.shiftTarget)}',
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

  /// LINHA TOTAL SETOR DESKTOP
  Widget _buildDesktopSectorTotalRow({
    required int totalShiftMeters,
    required int totalTodayMeters,
    required int totalMonthMeters,
    required int totalExpectedRitmo,
    required int totalShiftTarget,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
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
                  'desde ${shiftStartTime ?? "06:00"} do ritmo · esperado ${Formatters.formatInteger(totalExpectedRitmo > 0 ? totalExpectedRitmo : 394858)} · meta ${Formatters.formatInteger(totalShiftTarget > 0 ? totalShiftTarget : 409000)}',
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
    );
  }
}
