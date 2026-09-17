import 'dart:async';
import 'package:flutter/material.dart';
import '../models/machine_indicator.dart';
import '../models/transfer_indicator.dart';
import '../models/alert_model.dart';
import '../services/websocket_service.dart';

enum ShiftFilter { shift1, shift2, shift3, fullDay }

class IndicatorsState extends ChangeNotifier {
  // Theme state
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  // TV Wallboard presentation mode
  bool _isTVMode = false;
  bool get isTVMode => _isTVMode;

  void toggleTVMode() {
    _isTVMode = !_isTVMode;
    notifyListeners();
  }

  // Active Shift Filter
  ShiftFilter _selectedShift = ShiftFilter.shift1;
  ShiftFilter get selectedShift => _selectedShift;

  String get shiftDisplayName {
    switch (_selectedShift) {
      case ShiftFilter.shift1:
        return '1º TURNO (AGORA)';
      case ShiftFilter.shift2:
        return '2º TURNO (14h-22h)';
      case ShiftFilter.shift3:
        return '3º TURNO (22h-06h)';
      case ShiftFilter.fullDay:
        return 'DIA INDUSTRIAL CONSOLIDADO';
    }
  }

  void setShift(ShiftFilter shift) {
    _selectedShift = shift;
    notifyListeners();
  }

  // Search / Filter query
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Selected Machine for Detail Modal
  MachineIndicator? _selectedMachine;
  MachineIndicator? get selectedMachine => _selectedMachine;

  void selectMachine(MachineIndicator? machine) {
    _selectedMachine = machine;
    notifyListeners();
  }

  // Overall Corte & Rebobinamento
  int _corteCurrentMeters = 14631933;
  int _corteTargetMeters = 27500000;

  int get corteCurrentMeters => _corteCurrentMeters;
  int get corteTargetMeters => _corteTargetMeters;

  double get corteConcludedPercent =>
      _corteTargetMeters > 0 ? (_corteCurrentMeters / _corteTargetMeters) * 100 : 0.0; // 53.2%

  double get corteRemainingPercent =>
      100.0 - corteConcludedPercent; // 46.8%

  // Transfer Data
  TransferIndicator _transfer = const TransferIndicator(
    todayWeighed: 31387,
    monthWeighed: 601372,
    todayTarget: 35000,
    monthTarget: 800000,
    trendTodayPercent: 8.4,
    trendMonthPercent: 12.1,
  );
  TransferIndicator get transfer => _transfer;

  // Sector Aparas Summary
  double? _sectorScrapShift = 6.37;
  double? _sectorScrapDay = 0.00;
  double _sectorScrapMonth = 5.76;
  final double _scrapGoal = 3.0;

  double? get sectorScrapShift => _sectorScrapShift;
  double? get sectorScrapDay => _sectorScrapDay;
  double get sectorScrapMonth => _sectorScrapMonth;
  double get scrapGoal => _scrapGoal;

  // Sector Rhythm Points
  List<double> _sectorRhythmPoints = const [58.0, 70.0, 68.0, 72.0, 72.0];
  List<double> get sectorRhythmPoints => _sectorRhythmPoints;

  // Machine List (Matches approved reference, NO OEE)
  List<MachineIndicator> _machines = [
    const MachineIndicator(
      code: 'BCR006',
      name: 'Cortadeira Rebobinadeira 06',
      status: 'running',
      operatorName: 'Antônio Ferreira',
      speedMpm: 380,
      shiftMeters: 36135,
      shiftTarget: 60000,
      expectedRitmo: 49927,
      rhythmPct: 71.0,
      rhythmPoints: [52.0, 74.0, 69.0, 73.0, 71.0],
      todayMeters: 36135,
      monthMeters: 1853019,
      scrapShift: 5.96,
      scrapMonth: 5.26,
      scrapTarget: 3.0,
      productionOrder: 'OP-45091 — Filme Shrink Polietileno',
      materialDescription: 'PEBD Termoencolhível 65 micras',
      scrapReasons: [
        ScrapReason(category: 'Refugo de Acerto / Setup', weightKg: 85.0, percentage: 42.0),
        ScrapReason(category: 'Refugo Lateral (Refile)', weightKg: 78.0, percentage: 38.5),
      ],
    ),
    const MachineIndicator(
      code: 'BCR007',
      name: 'Cortadeira Rebobinadeira 07',
      status: 'setup',
      operatorName: 'Marcos Vinícius',
      speedMpm: 220,
      shiftMeters: 32713,
      shiftTarget: 48800,
      expectedRitmo: 48928,
      rhythmPct: 69.0,
      rhythmPoints: [58.0, 62.0, 59.0, 66.0, 69.0],
      todayMeters: 32713,
      monthMeters: 2318155,
      scrapShift: 6.48,
      scrapMonth: 7.27,
      scrapTarget: 3.0,
      productionOrder: 'OP-45102 — Laminado Stand-up Pouch',
      materialDescription: 'BOPP Mate + PE 110 micras',
      scrapReasons: [
        ScrapReason(category: 'Ajuste de Tensão e Rugas', weightKg: 340.0, percentage: 55.0),
        ScrapReason(category: 'Desalinhamento de Eixo', weightKg: 180.0, percentage: 29.0),
      ],
    ),
    const MachineIndicator(
      code: 'BCR012',
      name: 'Cortadeira Rebobinadeira 12',
      status: 'running',
      operatorName: 'Rafael Santos',
      speedMpm: 450,
      shiftMeters: 56813,
      shiftTarget: 69500,
      expectedRitmo: 64969,
      rhythmPct: 84.0,
      rhythmPoints: [60.0, 88.0, 86.0, 83.0, 84.0],
      todayMeters: 56813,
      monthMeters: 2187627,
      scrapShift: 5.82,
      scrapMonth: 3.80,
      scrapTarget: 3.0,
      productionOrder: 'OP-45118 — Bobina Impressa Pão de Forma',
      materialDescription: 'PEBD Cristal 32 micras',
      scrapReasons: [
        ScrapReason(category: 'Refile Lateral', weightKg: 110.0, percentage: 60.0),
      ],
    ),
    const MachineIndicator(
      code: 'BCR014',
      name: 'Cortadeira Rebobinadeira 14',
      status: 'running',
      operatorName: 'Lucas Almeida',
      speedMpm: 420,
      shiftMeters: 60759,
      shiftTarget: 73800,
      expectedRitmo: 71744,
      rhythmPct: 82.0,
      rhythmPoints: [72.0, 70.0, 78.0, 81.0, 82.0],
      todayMeters: 60759,
      monthMeters: 2510002,
      scrapShift: 10.07,
      scrapMonth: 6.30,
      scrapTarget: 3.0,
      productionOrder: 'OP-45125 — Filme Barreira Alimentos',
      materialDescription: 'PA/PE 70 micras',
      scrapReasons: [
        ScrapReason(category: 'Refile Lateral', weightKg: 145.0, percentage: 65.0),
      ],
    ),
    const MachineIndicator(
      code: 'BCR015',
      name: 'Cortadeira Rebobinadeira 15',
      status: 'running',
      operatorName: 'Thiago Oliveira',
      speedMpm: 490,
      shiftMeters: 60371,
      shiftTarget: 94000,
      expectedRitmo: 96942,
      rhythmPct: 65.0,
      rhythmPoints: [55.0, 63.0, 61.0, 64.0, 65.0],
      todayMeters: 60371,
      monthMeters: 3498104,
      scrapShift: 3.08,
      scrapMonth: 5.68,
      scrapTarget: 3.0,
      productionOrder: 'OP-45130 — Filme Higiênico Fraldas',
      materialDescription: 'PEBD Microperfurado 22 micras',
      scrapReasons: [
        ScrapReason(category: 'Refile Lateral Alta Velocidade', weightKg: 210.0, percentage: 70.0),
      ],
    ),
    const MachineIndicator(
      code: 'BCR016',
      name: 'Cortadeira Rebobinadeira 16',
      status: 'running',
      operatorName: 'Rodrigo Gomes',
      speedMpm: 360,
      shiftMeters: 37828,
      shiftTarget: 63800,
      expectedRitmo: 61777,
      rhythmPct: 60.0,
      rhythmPoints: [45.0, 60.0, 58.0, 62.0, 60.0],
      todayMeters: 37828,
      monthMeters: 2265026,
      scrapShift: 7.16,
      scrapMonth: 6.69,
      scrapTarget: 3.0,
      productionOrder: 'OP-45142 — Embalagem Ração Pet',
      materialDescription: 'PET Met + PE 95 micras',
      scrapReasons: [
        ScrapReason(category: 'Acerto de Alinhamento Fotocélula', weightKg: 130.0, percentage: 52.0),
      ],
    ),
  ];

  List<MachineIndicator> get machines {
    if (_searchQuery.isEmpty) return _machines;
    final q = _searchQuery.toLowerCase();
    return _machines.where((m) =>
      m.code.toLowerCase().contains(q) ||
      m.name.toLowerCase().contains(q) ||
      m.operatorName.toLowerCase().contains(q)
    ).toList();
  }

  // Plant Alerts
  final List<PlantAlert> _alerts = [
    PlantAlert(
      id: 'ALT-1',
      title: 'Atenção: Aparas BCR014 em 10,07%',
      message: 'A máquina BCR014 ultrapassou o limite de aparas no turno. Verificar refile e guilhotina.',
      severity: AlertSeverity.danger,
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      machineCode: 'BCR014',
    ),
    PlantAlert(
      id: 'ALT-2',
      title: 'Destaque Produtivo: BCR015 lidera o mês',
      message: 'BCR015 atingiu 3.498.104 metros acumulados no mês e 60.371 metros hoje.',
      severity: AlertSeverity.success,
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      machineCode: 'BCR015',
    ),
  ];

  List<PlantAlert> get alerts => _alerts;
  int get unreadAlertsCount => _alerts.where((a) => !a.isRead).length;

  // WebSocket Service (Node-RED Integration)
  late final WebSocketService _wsService;
  WebSocketStatus get wsStatus => _wsService.status;
  String get wsUrl => _wsService.serverUrl;

  DateTime _lastUpdate = DateTime.now();
  DateTime get lastUpdate => _lastUpdate;

  IndicatorsState({String wsServerUrl = 'ws://localhost:1880/ws/telemetria'}) {
    _wsService = WebSocketService(
      serverUrl: wsServerUrl,
      onTelemetryReceived: _handleWebSocketTelemetry,
      onStatusChanged: (status) {
        notifyListeners();
      },
    );
    _wsService.connect();
  }

  void updateWebSocketUrl(String newUrl) {
    _wsService.disconnect();
    _wsService = WebSocketService(
      serverUrl: newUrl,
      onTelemetryReceived: _handleWebSocketTelemetry,
      onStatusChanged: (status) {
        notifyListeners();
      },
    );
    _wsService.connect();
    notifyListeners();
  }

  void _handleWebSocketTelemetry(Map<String, dynamic> data) {
    _lastUpdate = DateTime.now();

    // 1. Transferência
    if (data.containsKey('transferencia')) {
      final t = data['transferencia'] as Map<String, dynamic>;
      _transfer = TransferIndicator(
        todayWeighed: (t['pesadoHoje'] as num?)?.toInt() ?? _transfer.todayWeighed,
        monthWeighed: (t['mensal'] as num?)?.toInt() ?? _transfer.monthWeighed,
        todayTarget: _transfer.todayTarget,
        monthTarget: _transfer.monthTarget,
        trendTodayPercent: (t['tendenciaHoje'] as num?)?.toDouble() ?? _transfer.trendTodayPercent,
        trendMonthPercent: (t['tendenciaMes'] as num?)?.toDouble() ?? _transfer.trendMonthPercent,
      );
    }

    // 2. Corte Geral
    if (data.containsKey('corteGeral')) {
      final c = data['corteGeral'] as Map<String, dynamic>;
      if (c['atual'] != null) _corteCurrentMeters = (c['atual'] as num).toInt();
      if (c['meta'] != null) _corteTargetMeters = (c['meta'] as num).toInt();
    }

    // 3. Setor
    if (data.containsKey('setor')) {
      final s = data['setor'] as Map<String, dynamic>;
      if (s['scrapShift'] != null) _sectorScrapShift = (s['scrapShift'] as num).toDouble();
      if (s['scrapMonth'] != null) _sectorScrapMonth = (s['scrapMonth'] as num).toDouble();
      if (s['rhythmPoints'] is List) {
        _sectorRhythmPoints = (s['rhythmPoints'] as List)
            .map((e) => (e as num).toDouble())
            .toList();
      }
    }

    // 4. Máquinas
    if (data.containsKey('maquinas') && data['maquinas'] is List) {
      final list = data['maquinas'] as List;
      _machines = list.map((item) {
        final map = item as Map<String, dynamic>;
        return MachineIndicator.fromJson(map);
      }).toList();
    }

    notifyListeners();
  }

  @override
  void dispose() {
    _wsService.disconnect();
    super.dispose();
  }
}
