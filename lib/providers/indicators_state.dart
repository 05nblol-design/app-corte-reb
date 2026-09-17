import 'dart:async';
import 'package:flutter/material.dart';
import '../models/machine_indicator.dart';
import '../models/transfer_indicator.dart';
import '../models/alert_model.dart';

enum ShiftFilter { shift1, shift2, shift3, fullDay }

class IndicatorsState extends ChangeNotifier {
  // Theme state
  ThemeMode _themeMode = ThemeMode.dark; // Default to sleek industrial dark mode
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

  // Live Auto-Refresh State
  bool _isLiveActive = true;
  bool get isLiveActive => _isLiveActive;
  DateTime _lastUpdate = DateTime.now();
  DateTime get lastUpdate => _lastUpdate;

  Timer? _liveTimer;

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
  int _corteCurrentMeters = 1188756;
  final int _corteTargetMeters = 27500000;

  int get corteCurrentMeters => _corteCurrentMeters;
  int get corteTargetMeters => _corteTargetMeters;

  double get corteConcludedPercent =>
      (_corteCurrentMeters / _corteTargetMeters) * 100; // 4.3%

  double get corteRemainingPercent =>
      100.0 - corteConcludedPercent; // 95.7%

  // Transfer Data
  TransferIndicator _transfer = const TransferIndicator(
    todayWeighed: 10582,
    monthWeighed: 67098,
    todayTarget: 12000,
    monthTarget: 300000,
    trendTodayPercent: 8.4,
    trendMonthPercent: 12.1,
  );
  TransferIndicator get transfer => _transfer;

  // Sector Aparas Summary
  double? _sectorScrapShift = 0.00;
  double? _sectorScrapDay = 0.00;
  final double _sectorScrapMonth = 7.16;
  final double _scrapGoal = 3.0;

  double? get sectorScrapShift => _sectorScrapShift;
  double? get sectorScrapDay => _sectorScrapDay;
  double get sectorScrapMonth => _sectorScrapMonth;
  double get scrapGoal => _scrapGoal;

  // Machine List (All exact data from the screen)
  List<MachineIndicator> _machines = [
    const MachineIndicator(
      code: 'BCR006',
      name: 'Cortadeira Rebobinadeira 06',
      status: 'running',
      operatorName: 'Antônio Ferreira',
      speedMpm: 380,
      shiftMeters: 0,
      shiftTarget: 57000,
      shiftPacing: null,
      todayMeters: 3111,
      monthMeters: 111608,
      scrapShift: null,
      scrapDay: null,
      scrapMonth: 4.52,
      scrapTarget: 3.0,
      oee: 82.4,
      productionOrder: 'OP-45091 — Filme Shrink Polietileno',
      materialDescription: 'PEBD Termoencolhível 65 micras',
      scrapReasons: [
        ScrapReason(category: 'Refugo de Acerto / Setup', weightKg: 85.0, percentage: 42.0),
        ScrapReason(category: 'Refugo Lateral (Refile)', weightKg: 78.0, percentage: 38.5),
        ScrapReason(category: 'Defeito de Bobinamento', weightKg: 39.5, percentage: 19.5),
      ],
    ),
    const MachineIndicator(
      code: 'BCR007',
      name: 'Cortadeira Rebobinadeira 07',
      status: 'setup',
      operatorName: 'Marcos Vinícius',
      speedMpm: 220,
      shiftMeters: 0,
      shiftTarget: 67200,
      shiftPacing: null,
      todayMeters: 2719,
      monthMeters: 110151,
      scrapShift: null,
      scrapDay: null,
      scrapMonth: 16.32, // CRITICAL
      scrapTarget: 3.0,
      oee: 64.1,
      productionOrder: 'OP-45102 — Laminado Stand-up Pouch',
      materialDescription: 'BOPP Mate + PE 110 micras',
      scrapReasons: [
        ScrapReason(category: 'Ajuste de Tensão e Rugas', weightKg: 340.0, percentage: 55.0),
        ScrapReason(category: 'Desalinhamento de Eixo', weightKg: 180.0, percentage: 29.0),
        ScrapReason(category: 'Acerto de Guilhotina', weightKg: 99.0, percentage: 16.0),
      ],
    ),
    const MachineIndicator(
      code: 'BCR012',
      name: 'Cortadeira Rebobinadeira 12',
      status: 'running',
      operatorName: 'Rafael Santos',
      speedMpm: 450,
      shiftMeters: 0,
      shiftTarget: 67200,
      shiftPacing: null,
      todayMeters: 6813,
      monthMeters: 154323,
      scrapShift: 0.00,
      scrapDay: 0.00,
      scrapMonth: 5.08,
      scrapTarget: 3.0,
      oee: 89.2,
      productionOrder: 'OP-45118 — Bobina Impressa Pão de Forma',
      materialDescription: 'PEBD Cristal 32 micras',
      scrapReasons: [
        ScrapReason(category: 'Refile Lateral', weightKg: 110.0, percentage: 60.0),
        ScrapReason(category: 'Troca de Rolo Principal', weightKg: 73.0, percentage: 40.0),
      ],
    ),
    const MachineIndicator(
      code: 'BCR014',
      name: 'Cortadeira Rebobinadeira 14',
      status: 'running',
      operatorName: 'Lucas Almeida',
      speedMpm: 420,
      shiftMeters: 0,
      shiftTarget: 48000,
      shiftPacing: null,
      todayMeters: 6907,
      monthMeters: 229759,
      scrapShift: 0.00,
      scrapDay: 0.00,
      scrapMonth: 5.59,
      scrapTarget: 3.0,
      oee: 91.5,
      productionOrder: 'OP-45125 — Filme Barreira Alimentos',
      materialDescription: 'PA/PE 70 micras',
      scrapReasons: [
        ScrapReason(category: 'Refile Lateral', weightKg: 145.0, percentage: 65.0),
        ScrapReason(category: 'Acerto de Largura das Facas', weightKg: 78.0, percentage: 35.0),
      ],
    ),
    const MachineIndicator(
      code: 'BCR015',
      name: 'Cortadeira Rebobinadeira 15',
      status: 'running',
      operatorName: 'Thiago Oliveira',
      speedMpm: 490,
      shiftMeters: 0,
      shiftTarget: 57000,
      shiftPacing: null,
      todayMeters: 13113, // Top Producer Today!
      monthMeters: 375610, // Top Producer Month!
      scrapShift: 0.00,
      scrapDay: 0.00,
      scrapMonth: 7.05,
      scrapTarget: 3.0,
      oee: 95.8,
      productionOrder: 'OP-45130 — Filme Higiênico Fraldas',
      materialDescription: 'PEBD Microperfurado 22 micras',
      scrapReasons: [
        ScrapReason(category: 'Refile Lateral Alta Velocidade', weightKg: 210.0, percentage: 70.0),
        ScrapReason(category: 'Emenda de Bobinas Mãe', weightKg: 90.0, percentage: 30.0),
      ],
    ),
    const MachineIndicator(
      code: 'BCR016',
      name: 'Cortadeira Rebobinadeira 16',
      status: 'running',
      operatorName: 'Rodrigo Gomes',
      speedMpm: 360,
      shiftMeters: 0,
      shiftTarget: 57000,
      shiftPacing: null,
      todayMeters: 4786,
      monthMeters: 207305,
      scrapShift: 0.00,
      scrapDay: 0.00,
      scrapMonth: 9.05,
      scrapTarget: 3.0,
      oee: 84.0,
      productionOrder: 'OP-45142 — Embalagem Ração Pet',
      materialDescription: 'PET Met + PE 95 micras',
      scrapReasons: [
        ScrapReason(category: 'Acerto de Alinhamento Fotocélula', weightKg: 130.0, percentage: 52.0),
        ScrapReason(category: 'Refile Lateral', weightKg: 120.0, percentage: 48.0),
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
      title: 'Atenção: Aparas BCR007 em 16,32%',
      message: 'A máquina BCR007 ultrapassou o limite crítico de aparas (Meta: 3,0%). Verificar setup de guilhotina e tensão.',
      severity: AlertSeverity.danger,
      timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
      machineCode: 'BCR007',
    ),
    PlantAlert(
      id: 'ALT-2',
      title: 'Destaque Produtivo: BCR015 lidera o mês',
      message: 'BCR015 atingiu 375.610 metros acumulados no mês e 13.113 metros hoje.',
      severity: AlertSeverity.success,
      timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
      machineCode: 'BCR015',
    ),
    PlantAlert(
      id: 'ALT-3',
      title: 'Ajuste de Ritmo BCR016',
      message: 'Aparas acumuladas no mês em 9,05% exigem verificação de alinhamento de fotocélula.',
      severity: AlertSeverity.warning,
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      machineCode: 'BCR016',
    ),
  ];

  List<PlantAlert> get alerts => _alerts;
  int get unreadAlertsCount => _alerts.where((a) => !a.isRead).length;

  IndicatorsState() {
    _startLiveSync();
  }

  void toggleLiveSync() {
    _isLiveActive = !_isLiveActive;
    if (_isLiveActive) {
      _startLiveSync();
    } else {
      _liveTimer?.cancel();
    }
    notifyListeners();
  }

  void _startLiveSync() {
    _liveTimer?.cancel();
    _liveTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (!_isLiveActive) return;
      _simulateRealtimeTick();
    });
  }

  void manualRefresh() {
    _simulateRealtimeTick();
    _lastUpdate = DateTime.now();
    notifyListeners();
  }

  void _simulateRealtimeTick() {
    _lastUpdate = DateTime.now();

    // Increment slight production meters for running machines to give live feel
    _machines = _machines.map((m) {
      if (m.status == 'running') {
        final added = (m.speedMpm / 60 * 4).round(); // 4 seconds of run
        return m.copyWith(
          shiftMeters: m.shiftMeters + added,
          todayMeters: m.todayMeters + added,
          monthMeters: m.monthMeters + added,
        );
      }
      return m;
    }).toList();

    _corteCurrentMeters += 24; // Overall meters increment
    notifyListeners();
  }

  @override
  void dispose() {
    _liveTimer?.cancel();
    super.dispose();
  }
}
