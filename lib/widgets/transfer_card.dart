import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/utils/formatters.dart';
import '../models/transfer_indicator.dart';

class TransferCard extends StatelessWidget {
  final TransferIndicator transfer;
  final bool isDark;

  const TransferCard({
    super.key,
    required this.transfer,
    required this.isDark,
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
            color: isDark ? Colors.black.withOpacity(0.35) : const Color(0x0C0F172A),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Section Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TRANSFERÊNCIA & PESAGEM',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                  color: isDark ? const Color(0xFFCBD5E1) : AppColors.brandPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0F1B33) : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: isDark ? AppColors.darkCardBorder : const Color(0xFFE2E8F0),
                  ),
                ),
                child: Text(
                  'UNIDADE: KG',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Row 1: Pesado Hoje
          _buildTransferRow(
            title: 'Pesado Hoje',
            subtitle: 'Total diário',
            value: transfer.todayWeighed,
            target: transfer.todayTarget,
            growth: '+8,4% diário',
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Divider(height: 1, color: isDark ? AppColors.darkDivider : AppColors.lightDivider),
          ),

          // Row 2: Transferência Mensal
          _buildTransferRow(
            title: 'Transferência Mensal',
            subtitle: 'Acumulado do mês',
            value: transfer.monthWeighed,
            target: transfer.monthTarget,
            growth: '+12,1% vs meta',
          ),
        ],
      ),
    );
  }

  Widget _buildTransferRow({
    required String title,
    required String subtitle,
    required double value,
    required double target,
    required String growth,
  }) {
    final progress = target > 0 ? (value / target).clamp(0.0, 1.0) : 0.0;
    final Color growthColor = isDark ? const Color(0xFF34D399) : AppColors.successLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  growth,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: growthColor,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.darkTextMuted : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  Formatters.formatInteger(value),
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    letterSpacing: -0.5,
                    fontFamily: 'Outfit',
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 5,
            backgroundColor: isDark ? const Color(0xFF1E2D4E) : const Color(0xFFE2E8F0),
            valueColor: AlwaysStoppedAnimation<Color>(
              isDark ? AppColors.brandSecondary : const Color(0xFF0284C7),
            ),
          ),
        ),
      ],
    );
  }
}
