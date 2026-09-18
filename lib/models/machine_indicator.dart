import 'dart:ui';

class ScrapReason {
  final String category;
  final double weightKg;
  final double percentage;

  const ScrapReason({
    required this.category,
    required this.weightKg,
    required this.percentage,
  });

  factory ScrapReason.fromJson(Map<String, dynamic> json) {
    return ScrapReason(
      category: json['category'] ?? '',
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 0.0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'category': category,
    'weightKg': weightKg,
    'percentage': percentage,
  };
}

class MachineIndicator {
  final String code;
  final String name;
  final String status; // 'running', 'stopped', 'setup', 'maintenance'
  final String operatorName;
  final int speedMpm; // metros por minuto
  final int shiftMeters; // Metros no turno
  final int shiftTarget; // Meta do turno (ex: 60.000, 48.800)
  final int expectedRitmo; // Metros esperados pelo ritmo (ex: 49.927)
  final double rhythmPct; // Ritmo percentual (ex: 71%)
  final List<double> rhythmPoints; // Pontos horários da curva de ritmo
  final List<Offset> rhythmSeries; // Pontos (xRatio 0..1, pct) mapeados com exatidão temporal
  final int todayMeters; // Metros hoje
  final int monthMeters; // Metros no mês
  final double? scrapShift; // Aparas 1º Turno (Agora)
  final double? scrapDay; // Aparas Dia
  final double scrapMonth; // Aparas Mês
  final double scrapTarget; // Meta aparas (padrão 3.0%)
  final String productionOrder; // Número da OP
  final String materialDescription;
  final List<ScrapReason> scrapReasons;
  final String shiftAnalysisText; // ex: "desde 06:02"
  final String rhythmClass; // 'ritmo-ok', 'ritmo-alerta', 'ritmo-ruim'

  const MachineIndicator({
    required this.code,
    required this.name,
    required this.status,
    this.operatorName = '',
    this.speedMpm = 0,
    required this.shiftMeters,
    required this.shiftTarget,
    this.expectedRitmo = 0,
    this.rhythmPct = 0.0,
    this.rhythmPoints = const [],
    this.rhythmSeries = const [],
    required this.todayMeters,
    required this.monthMeters,
    this.scrapShift,
    this.scrapDay,
    required this.scrapMonth,
    this.scrapTarget = 3.0,
    required this.productionOrder,
    required this.materialDescription,
    this.scrapReasons = const [],
    this.shiftAnalysisText = 'desde 06:02',
    this.rhythmClass = '',
  });

  bool get isScrapAboveTarget => scrapMonth > scrapTarget;
  bool get isScrapCritical => scrapMonth >= (scrapTarget * 2.0); // > 6.0%

  bool get isRunning => shiftMeters > 0;

  String get statusDisplay {
    if (shiftMeters == 0) return 'PARADA';
    if (rhythmClass == 'ritmo-ok' || rhythmPct >= 100) return 'RITMO OK';
    if (rhythmClass == 'ritmo-alerta' || (rhythmPct >= 80 && rhythmPct < 100)) return 'ATENÇÃO';
    if (rhythmClass == 'ritmo-ruim' || (rhythmPct > 0 && rhythmPct < 80)) return 'RITMO BAIXO';
    return 'EM OPERAÇÃO';
  }

  Color get statusColor {
    if (shiftMeters == 0) return const Color(0xFFEF4444);
    if (rhythmClass == 'ritmo-ok' || rhythmPct >= 100) return const Color(0xFF10B981);
    if (rhythmClass == 'ritmo-alerta' || (rhythmPct >= 80 && rhythmPct < 100)) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }

  double get shiftProgressPercent =>
      shiftTarget > 0 ? (shiftMeters / shiftTarget) * 100 : 0.0;

  factory MachineIndicator.fromJson(Map<String, dynamic> json) {
    return MachineIndicator(
      code: json['code'] ?? json['maquina'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? 'running',
      operatorName: json['operatorName'] ?? '',
      speedMpm: (json['speedMpm'] as num?)?.toInt() ?? 0,
      shiftMeters: (json['shiftMeters'] as num?)?.toInt() ?? (json['metrosTurno'] as num?)?.toInt() ?? 0,
      shiftTarget: (json['shiftTarget'] as num?)?.toInt() ?? (json['metaTurno'] as num?)?.toInt() ?? 0,
      expectedRitmo: (json['expectedRitmo'] as num?)?.toInt() ?? (json['esperadoTurno'] as num?)?.toInt() ?? 0,
      rhythmPct: _parsePct(json['rhythmPct'] ?? json['pctTurno']),
      rhythmPoints: (json['rhythmPoints'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      rhythmSeries: (json['rhythmSeries'] as List<dynamic>?)
              ?.map((e) {
                if (e is List && e.length >= 2) {
                  return Offset((e[0] as num).toDouble(), (e[1] as num).toDouble());
                }
                return null;
              })
              .whereType<Offset>()
              .toList() ??
          const [],
      todayMeters: (json['todayMeters'] as num?)?.toInt() ?? (json['MetragemHoje'] as num?)?.toInt() ?? 0,
      monthMeters: (json['monthMeters'] as num?)?.toInt() ?? (json['Metragem'] as num?)?.toInt() ?? 0,
      scrapShift: (json['scrapShift'] as num?)?.toDouble(),
      scrapDay: (json['scrapDay'] as num?)?.toDouble(),
      scrapMonth: (json['scrapMonth'] as num?)?.toDouble() ?? 0.0,
      scrapTarget: (json['scrapTarget'] as num?)?.toDouble() ?? 3.0,
      productionOrder: json['productionOrder'] ?? '',
      materialDescription: json['materialDescription'] ?? '',
      scrapReasons: (json['scrapReasons'] as List<dynamic>?)
              ?.map((e) => ScrapReason.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      shiftAnalysisText: json['pctTurno']?.toString() ?? json['shiftAnalysisText']?.toString() ?? 'desde 06:02',
    );
  }

  static double _parsePct(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    final str = value.toString().replaceAll('%', '').replaceAll(',', '.').trim();
    return double.tryParse(str) ?? 0.0;
  }

  Map<String, dynamic> toJson() => {
    'code': code,
    'name': name,
    'status': status,
    'operatorName': operatorName,
    'speedMpm': speedMpm,
    'shiftMeters': shiftMeters,
    'shiftTarget': shiftTarget,
    'expectedRitmo': expectedRitmo,
    'rhythmPct': rhythmPct,
    'rhythmPoints': rhythmPoints,
    'todayMeters': todayMeters,
    'monthMeters': monthMeters,
    'scrapShift': scrapShift,
    'scrapDay': scrapDay,
    'scrapMonth': scrapMonth,
    'scrapTarget': scrapTarget,
    'productionOrder': productionOrder,
    'materialDescription': materialDescription,
    'scrapReasons': scrapReasons.map((r) => r.toJson()).toList(),
    'shiftAnalysisText': shiftAnalysisText,
    'rhythmSeries': rhythmSeries.map((p) => [p.dx, p.dy]).toList(),
  };

  MachineIndicator copyWith({
    String? code,
    String? name,
    String? status,
    String? operatorName,
    int? speedMpm,
    int? shiftMeters,
    int? shiftTarget,
    int? expectedRitmo,
    double? rhythmPct,
    List<double>? rhythmPoints,
    List<Offset>? rhythmSeries,
    int? todayMeters,
    int? monthMeters,
    double? scrapShift,
    double? scrapDay,
    double? scrapMonth,
    double? scrapTarget,
    String? productionOrder,
    String? materialDescription,
    List<ScrapReason>? scrapReasons,
    String? shiftAnalysisText,
    String? rhythmClass,
  }) {
    return MachineIndicator(
      code: code ?? this.code,
      name: name ?? this.name,
      status: status ?? this.status,
      operatorName: operatorName ?? this.operatorName,
      speedMpm: speedMpm ?? this.speedMpm,
      shiftMeters: shiftMeters ?? this.shiftMeters,
      shiftTarget: shiftTarget ?? this.shiftTarget,
      expectedRitmo: expectedRitmo ?? this.expectedRitmo,
      rhythmPct: rhythmPct ?? this.rhythmPct,
      rhythmPoints: rhythmPoints ?? this.rhythmPoints,
      rhythmSeries: rhythmSeries ?? this.rhythmSeries,
      todayMeters: todayMeters ?? this.todayMeters,
      monthMeters: monthMeters ?? this.monthMeters,
      scrapShift: scrapShift ?? this.scrapShift,
      scrapDay: scrapDay ?? this.scrapDay,
      scrapMonth: scrapMonth ?? this.scrapMonth,
      scrapTarget: scrapTarget ?? this.scrapTarget,
      productionOrder: productionOrder ?? this.productionOrder,
      materialDescription: materialDescription ?? this.materialDescription,
      scrapReasons: scrapReasons ?? this.scrapReasons,
      shiftAnalysisText: shiftAnalysisText ?? this.shiftAnalysisText,
      rhythmClass: rhythmClass ?? this.rhythmClass,
    );
  }
}
