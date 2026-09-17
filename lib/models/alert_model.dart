enum AlertSeverity { info, warning, danger, success }

class PlantAlert {
  final String id;
  final String title;
  final String message;
  final AlertSeverity severity;
  final DateTime timestamp;
  final String? machineCode;
  final bool isRead;

  const PlantAlert({
    required this.id,
    required this.title,
    required this.message,
    required this.severity,
    required this.timestamp,
    this.machineCode,
    this.isRead = false,
  });
}
