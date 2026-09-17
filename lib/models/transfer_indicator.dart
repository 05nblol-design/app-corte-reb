class TransferIndicator {
  final double todayWeighed; // 10.582
  final double monthWeighed; // 67.098
  final double todayTarget;
  final double monthTarget;
  final double trendTodayPercent;
  final double trendMonthPercent;
  final String unit; // 'kg' ou 'ton'

  const TransferIndicator({
    required this.todayWeighed,
    required this.monthWeighed,
    this.todayTarget = 12000,
    this.monthTarget = 300000,
    this.trendTodayPercent = 8.4,
    this.trendMonthPercent = 12.1,
    this.unit = 'kg',
  });

  double get todayProgress => (todayWeighed / todayTarget) * 100;
  double get monthProgress => (monthWeighed / monthTarget) * 100;

  TransferIndicator copyWith({
    double? todayWeighed,
    double? monthWeighed,
    double? todayTarget,
    double? monthTarget,
    double? trendTodayPercent,
    double? trendMonthPercent,
    String? unit,
  }) {
    return TransferIndicator(
      todayWeighed: todayWeighed ?? this.todayWeighed,
      monthWeighed: monthWeighed ?? this.monthWeighed,
      todayTarget: todayTarget ?? this.todayTarget,
      monthTarget: monthTarget ?? this.monthTarget,
      trendTodayPercent: trendTodayPercent ?? this.trendTodayPercent,
      trendMonthPercent: trendMonthPercent ?? this.trendMonthPercent,
      unit: unit ?? this.unit,
    );
  }
}
