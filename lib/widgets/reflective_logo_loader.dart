import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class ReflectiveLogoLoader extends StatefulWidget {
  final String? message;
  final double logoSize;
  final bool showText;
  final bool isDark;

  const ReflectiveLogoLoader({
    super.key,
    this.message,
    this.logoSize = 80,
    this.showText = true,
    this.isDark = true,
  });

  @override
  State<ReflectiveLogoLoader> createState() => _ReflectiveLogoLoaderState();
}

class _ReflectiveLogoLoaderState extends State<ReflectiveLogoLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _sheenController;
  late Animation<double> _sheenAnimation;

  @override
  void initState() {
    super.initState();
    _sheenController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();

    _sheenAnimation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(
        parent: _sheenController,
        curve: Curves.easeInOutSine,
      ),
    );
  }

  @override
  void dispose() {
    _sheenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Logo com Brilho Refletivo (Shimmer / Light Sheen Sweep)
        Stack(
          alignment: Alignment.center,
          children: [
            // Aura de luz sutil azul de fundo
            Container(
              width: widget.logoSize + 28,
              height: widget.logoSize + 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF0284C7).withOpacity(widget.isDark ? 0.35 : 0.20),
                    const Color(0xFF0F2B5C).withOpacity(0.0),
                  ],
                ),
              ),
            ),

            // Card container da logo
            Container(
              width: widget.logoSize + 16,
              height: widget.logoSize + 16,
              decoration: BoxDecoration(
                color: widget.isDark ? const Color(0xFF0B172B) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: widget.isDark ? const Color(0xFF1E3A68) : const Color(0xFFCBD5E1),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0284C7).withOpacity(widget.isDark ? 0.25 : 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(12),
              child: AnimatedBuilder(
                animation: _sheenAnimation,
                builder: (context, child) {
                  return ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        stops: [
                          0.0,
                          0.35,
                          0.5,
                          0.65,
                          1.0,
                        ],
                        colors: [
                          Colors.white.withOpacity(0.85),
                          Colors.white.withOpacity(0.92),
                          Colors.white,
                          const Color(0xFF93C5FD), // Reflexo azul elétrico
                          Colors.white.withOpacity(0.85),
                        ],
                        transform: _SlideGradientTransform(
                          percent: _sheenAnimation.value,
                        ),
                      ).createShader(bounds);
                    },
                    blendMode: BlendMode.srcATop,
                    child: Image.asset(
                      'assets/zaraplast_logo.png',
                      width: widget.logoSize,
                      height: widget.logoSize,
                      fit: BoxFit.contain,
                    ),
                  );
                },
              ),
            ),
          ],
        ),

        if (widget.showText) ...[
          const SizedBox(height: 18),

          // Título Zaraplast
          Text(
            'ZARAPLAST',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 2.0,
              fontFamily: 'Outfit',
              color: widget.isDark ? Colors.white : AppColors.brandPrimary,
            ),
          ),
          const SizedBox(height: 4),

          // Subtítulo
          Text(
            'CORTE & REBOBINAMENTO',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: widget.isDark ? const Color(0xFF38BDF8) : AppColors.brandSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // Status de sincronização
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: widget.isDark ? const Color(0xFF38BDF8) : AppColors.brandSecondary,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.message ?? 'Sincronizando telemetria em tempo real...',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: widget.isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SlideGradientTransform extends GradientTransform {
  final double percent;

  const _SlideGradientTransform({required this.percent});

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * percent, 0, 0);
  }
}
