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
  final int todayMeters; // Metros hoje
  final int monthMeters; // Metros no mês
  final double? scrapShift; // Aparas 1º Turno (Agora)
  final double? scrapDay; // Aparas Dia
  final double scrapMonth; // Aparas Mês
  final double scrapTarget; // Meta aparas (padrão 3.0%)
  final String productionOrder; // Número da OP
  final String materialDescription;
  final List<ScrapReason> scrapReasons;

  const MachineIndicator({
    required this.code,
    required this.name,
    required this.status,
    required this.operatorName,
    required this.speedMpm,
    required this.shiftMeters,
    required this.shiftTarget,
    this.expectedRitmo = 0,
    this.rhythmPct = 0.0,
    this.rhythmPoints = const [],
    required this.todayMeters,
    required this.monthMeters,
    this.scrapShift,
    this.scrapDay,
    required this.scrapMonth,
    this.scrapTarget = 3.0,
    required this.productionOrder,
    required this.materialDescription,
    this.scrapReasons = const [],
  });

  bool get isScrapAboveTarget => scrapMonth > scrapTarget;
  bool get isScrapCritical => scrapMonth >= (scrapTarget * 2.0); // > 6.0%

  double get shiftProgressPercent =>
      shiftTarget > 0 ? (shiftMeters / shiftTarget) * 100 : 0.0;

  factory MachineIndicator.fromJson(Map<String, dynamic> json) {
    return MachineIndicator(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      status: json['status'] ?? 'running',
      operatorName: json['operatorName'] ?? '',
      speedMpm: (json['speedMpm'] as num?)?.toInt() ?? 0,
      shiftMeters: (json['shiftMeters'] as num?)?.toInt() ?? 0,
      shiftTarget: (json['shiftTarget'] as num?)?.toInt() ?? 0,
      expectedRitmo: (json['expectedRitmo'] as num?)?.toInt() ?? 0,
      rhythmPct: (json['rhythmPct'] as num?)?.toDouble() ?? 0.0,
      rhythmPoints: (json['rhythmPoints'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          [],
      todayMeters: (json['todayMeters'] as num?)?.toInt() ?? 0,
      monthMeters: (json['monthMeters'] as num?)?.toInt() ?? 0,
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
    );
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
    int? todayMeters,
    int? monthMeters,
    double? scrapShift,
    double? scrapDay,
    double? scrapMonth,
    double? scrapTarget,
    String? productionOrder,
    String? materialDescription,
    List<ScrapReason>? scrapReasons,
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
      todayMeters: todayMeters ?? this.todayMeters,
      monthMeters: monthMeters ?? this.monthMeters,
      scrapShift: scrapShift ?? this.scrapShift,
      scrapDay: scrapDay ?? this.scrapDay,
      scrapMonth: scrapMonth ?? this.scrapMonth,
      scrapTarget: scrapTarget ?? this.scrapTarget,
      productionOrder: productionOrder ?? this.productionOrder,
      materialDescription: materialDescription ?? this.materialDescription,
      scrapReasons: scrapReasons ?? this.scrapReasons,
    );
  }
}
