class ScrapReason {
  final String category;
  final double weightKg;
  final double percentage;

  const ScrapReason({
    required this.category,
    required this.weightKg,
    required this.percentage,
  });
}

class MachineIndicator {
  final String code;
  final String name;
  final String status; // 'running', 'stopped', 'setup', 'maintenance'
  final String operatorName;
  final int speedMpm; // metros por minuto
  final int shiftMeters; // Metros no turno
  final int shiftTarget; // Meta do turno (ex: 57.000, 67.200, 48.000)
  final double? shiftPacing; // Ritmo (% da meta atingida no tempo decorrido)
  final int todayMeters; // Metros hoje
  final int monthMeters; // Metros no mês
  final double? scrapShift; // Aparas 1º Turno (Agora)
  final double? scrapDay; // Aparas Dia
  final double scrapMonth; // Aparas Mês
  final double scrapTarget; // Meta aparas (padrão 3.0%)
  final double oee; // OEE percentual
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
    this.shiftPacing,
    required this.todayMeters,
    required this.monthMeters,
    this.scrapShift,
    this.scrapDay,
    required this.scrapMonth,
    this.scrapTarget = 3.0,
    required this.oee,
    required this.productionOrder,
    required this.materialDescription,
    this.scrapReasons = const [],
  });

  bool get isScrapAboveTarget => scrapMonth > scrapTarget;
  bool get isScrapCritical => scrapMonth >= (scrapTarget * 2.0); // > 6.0%

  double get monthProgressPercent =>
      shiftTarget > 0 ? (shiftMeters / shiftTarget) * 100 : 0.0;

  MachineIndicator copyWith({
    String? code,
    String? name,
    String? status,
    String? operatorName,
    int? speedMpm,
    int? shiftMeters,
    int? shiftTarget,
    double? shiftPacing,
    int? todayMeters,
    int? monthMeters,
    double? scrapShift,
    double? scrapDay,
    double? scrapMonth,
    double? scrapTarget,
    double? oee,
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
      shiftPacing: shiftPacing ?? this.shiftPacing,
      todayMeters: todayMeters ?? this.todayMeters,
      monthMeters: monthMeters ?? this.monthMeters,
      scrapShift: scrapShift ?? this.scrapShift,
      scrapDay: scrapDay ?? this.scrapDay,
      scrapMonth: scrapMonth ?? this.scrapMonth,
      scrapTarget: scrapTarget ?? this.scrapTarget,
      oee: oee ?? this.oee,
      productionOrder: productionOrder ?? this.productionOrder,
      materialDescription: materialDescription ?? this.materialDescription,
      scrapReasons: scrapReasons ?? this.scrapReasons,
    );
  }
}
