import 'dart:async';
import 'package:flutter/material.dart';
import '../models/machine_indicator.dart';
import '../models/transfer_indicator.dart';
import '../models/alert_model.dart';
import '../services/websocket_service.dart';
import '../services/firebase_http_service.dart';

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

  // Automatic shift detection based on current industrial hours
  static ShiftFilter getCurrentShift() {
    final hour = DateTime.now().hour;
    if (hour >= 6 && hour < 14) {
      return ShiftFilter.shift1; // 06:00 - 14:00 (Turno A • 1º Turno)
    } else if (hour >= 14 && hour < 22) {
      return ShiftFilter.shift2; // 14:00 - 22:00 (Turno B • 2º Turno)
    } else {
      return ShiftFilter.shift3; // 22:00 - 06:00 (Turno C • 3º Turno)
    }
  }

  // Active Shift Filter (Inicia automaticamente no turno atual)
  bool _manualShiftOverride = false;
  ShiftFilter _lastLiveShift = getCurrentShift();
  String? _lastTelemetryShiftName;
  ShiftFilter _selectedShift = getCurrentShift();
  ShiftFilter get selectedShift => _selectedShift;

  String get shiftDisplayName {
    switch (_selectedShift) {
      case ShiftFilter.shift1:
        return 'TURNO A (1º) • 06h–14h';
      case ShiftFilter.shift2:
        return 'TURNO B (2º) • 14h–22h';
      case ShiftFilter.shift3:
        return 'TURNO C (3º) • 22h–06h';
      case ShiftFilter.fullDay:
        return 'DIA INDUSTRIAL CONSOLIDADO (24H)';
    }
  }

  String get shiftShortName {
    switch (_selectedShift) {
      case ShiftFilter.shift1:
        return 'TURNO A';
      case ShiftFilter.shift2:
        return 'TURNO B';
      case ShiftFilter.shift3:
        return 'TURNO C';
      case ShiftFilter.fullDay:
        return 'DIA 24H';
    }
  }

  String get shiftStartTime {
    switch (_selectedShift) {
      case ShiftFilter.shift1:
        return '06:00';
      case ShiftFilter.shift2:
        return '14:00';
      case ShiftFilter.shift3:
        return '22:00';
      case ShiftFilter.fullDay:
        return '06:00';
    }
  }

  List<String> get currentShiftTimeLabels {
    switch (_selectedShift) {
      case ShiftFilter.shift1:
        return const ['06h', '10h', '14h'];
      case ShiftFilter.shift2:
        return const ['14h', '18h', '22h'];
      case ShiftFilter.shift3:
        return const ['22h', '02h', '06h'];
      case ShiftFilter.fullDay:
        return const ['06h', '12h', '18h', '00h', '06h'];
    }
  }

  List<String> get currentSectorTimeLabels {
    switch (_selectedShift) {
      case ShiftFilter.shift1:
        return const ['06h', '08h', '10h', '12h', '14h'];
      case ShiftFilter.shift2:
        return const ['14h', '16h', '18h', '20h', '22h'];
      case ShiftFilter.shift3:
        return const ['22h', '00h', '02h', '04h', '06h'];
      case ShiftFilter.fullDay:
        return const ['06h', '12h', '18h', '00h', '06h'];
    }
  }

  List<Offset> _sectorRhythmSeries = const [];
  List<Offset> get currentSectorRhythmSeries => _sectorRhythmSeries;

  List<double> get currentSectorRhythmPoints => _sectorRhythmPoints;

  void setShift(ShiftFilter shift) {
    _selectedShift = shift;
    // Se o usuário selecionou o turno corrente em tempo real, mantém acompanhamento automático vivo
    _manualShiftOverride = (shift != getCurrentShift());
    notifyListeners();
  }

  void resetToAutoShift() {
    _manualShiftOverride = false;
    _selectedShift = getCurrentShift();
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
  double? _corteConcludedPercentOverride;
  double? _corteRemainingPercentOverride;

  int get corteCurrentMeters => _corteCurrentMeters;
  int get corteTargetMeters => _corteTargetMeters;

  double get corteConcludedPercent =>
      _corteConcludedPercentOverride ??
      (_corteTargetMeters > 0 ? (_corteCurrentMeters / _corteTargetMeters) * 100 : 0.0);

  double get corteRemainingPercent =>
      _corteRemainingPercentOverride ??
      (100.0 - corteConcludedPercent);

  // Totais do Turno e do Dia (vindos do Firebase)
  int? _totalShiftMeters;
  int? _totalDayMeters;
  int? get totalShiftMeters => _totalShiftMeters;
  int? get totalDayMeters => _totalDayMeters;

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

  // Machine List (Initialized with active telemetry, NO MOCKS, NO OEE)
  // Machine List (Initialized with active telemetry, NO MOCKS, NO OEE)
  List<MachineIndicator> _machines = [
    const MachineIndicator(
      code: 'BCR006',
      name: 'Cortadeira Rebobinadeira 06',
      status: 'running',
      operatorName: '',
      shiftMeters: 36348,
      shiftTarget: 50000,
      expectedRitmo: 32880,
      rhythmPct: 111.0,
      todayMeters: 36348,
      monthMeters: 1995929,
      scrapShift: 3.42,
      scrapMonth: 5.19,
      scrapTarget: 3.0,
      productionOrder: '',
      materialDescription: '',
      scrapReasons: [],
      shiftAnalysisText: 'desde 06:02',
      rhythmClass: 'ritmo-ok',
    ),
    const MachineIndicator(
      code: 'BCR007',
      name: 'Cortadeira Rebobinadeira 07',
      status: 'running',
      operatorName: '',
      shiftMeters: 28685,
      shiftTarget: 48400,
      expectedRitmo: 31828,
      rhythmPct: 88.0,
      todayMeters: 28685,
      monthMeters: 2419160,
      scrapShift: 4.15,
      scrapMonth: 7.10,
      scrapTarget: 3.0,
      productionOrder: '',
      materialDescription: '',
      scrapReasons: [],
      shiftAnalysisText: 'desde 06:02',
      rhythmClass: 'ritmo-alerta',
    ),
    const MachineIndicator(
      code: 'BCR012',
      name: 'Cortadeira Rebobinadeira 12',
      status: 'running',
      operatorName: '',
      shiftMeters: 76868,
      shiftTarget: 69000,
      expectedRitmo: 45375,
      rhythmPct: 169.0,
      todayMeters: 76868,
      monthMeters: 2388746,
      scrapShift: 5.70,
      scrapMonth: 3.73,
      scrapTarget: 3.0,
      productionOrder: '',
      materialDescription: '',
      scrapReasons: [],
      shiftAnalysisText: 'desde 06:02',
      rhythmClass: 'ritmo-ok',
    ),
    const MachineIndicator(
      code: 'BCR014',
      name: 'Cortadeira Rebobinadeira 14',
      status: 'running',
      operatorName: '',
      shiftMeters: 49542,
      shiftTarget: 73800,
      expectedRitmo: 48531,
      rhythmPct: 101.0,
      todayMeters: 49542,
      monthMeters: 2677560,
      scrapShift: 5.83,
      scrapMonth: 6.14,
      scrapTarget: 3.0,
      productionOrder: '',
      materialDescription: '',
      scrapReasons: [],
      shiftAnalysisText: 'desde 06:02',
      rhythmClass: 'ritmo-ok',
    ),
    const MachineIndicator(
      code: 'BCR015',
      name: 'Cortadeira Rebobinadeira 15',
      status: 'running',
      operatorName: '',
      shiftMeters: 47423,
      shiftTarget: 95000,
      expectedRitmo: 62473,
      rhythmPct: 77.0,
      todayMeters: 47423,
      monthMeters: 3671742,
      scrapShift: 5.33,
      scrapMonth: 5.55,
      scrapTarget: 3.0,
      productionOrder: '',
      materialDescription: '',
      scrapReasons: [],
      shiftAnalysisText: 'desde 06:02',
      rhythmClass: 'ritmo-ruim',
    ),
    const MachineIndicator(
      code: 'BCR016',
      name: 'Cortadeira Rebobinadeira 16',
      status: 'running',
      operatorName: '',
      shiftMeters: 37909,
      shiftTarget: 63800,
      expectedRitmo: 41955,
      rhythmPct: 91.0,
      todayMeters: 37909,
      monthMeters: 2408541,
      scrapShift: 6.86,
      scrapMonth: 6.52,
      scrapTarget: 3.0,
      productionOrder: '',
      materialDescription: '',
      scrapReasons: [],
      shiftAnalysisText: 'desde 06:02',
      rhythmClass: 'ritmo-alerta',
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

  // Plant Alerts (Calculated dynamically from real telemetry and factory limits)
  List<PlantAlert> _alerts = [];

  List<PlantAlert> get alerts => _alerts;
  int get unreadAlertsCount => _alerts.where((a) => !a.isRead).length;

  void markAlertAsRead(String id) {
    final index = _alerts.indexWhere((a) => a.id == id);
    if (index != -1) {
      final a = _alerts[index];
      _alerts[index] = PlantAlert(
        id: a.id,
        title: a.title,
        message: a.message,
        severity: a.severity,
        timestamp: a.timestamp,
        machineCode: a.machineCode,
        isRead: true,
      );
      notifyListeners();
    }
  }

  void markAllAlertsAsRead() {
    _alerts = _alerts.map((a) => PlantAlert(
      id: a.id,
      title: a.title,
      message: a.message,
      severity: a.severity,
      timestamp: a.timestamp,
      machineCode: a.machineCode,
      isRead: true,
    )).toList();
    notifyListeners();
  }

  void _generateRealAlerts() {
    final list = <PlantAlert>[];
    final now = _lastUpdate;

    // 1. Alertas individuais das máquinas (Aparas e Ritmo)
    for (final m in _machines) {
      // Aparas Mês Crítica (>= 2x meta de 3.0%)
      if (m.scrapMonth >= (m.scrapTarget * 2.0)) {
        list.add(PlantAlert(
          id: 'scrap_crit_${m.code}',
          title: '${m.code} — Aparas Críticas no Mês (${m.scrapMonth.toStringAsFixed(2)}%)',
          message: 'A taxa de aparas acumulada no mês (${m.scrapMonth.toStringAsFixed(2)}%) está em nível crítico, superando o dobro da meta permitida de ${m.scrapTarget.toStringAsFixed(1)}%.',
          severity: AlertSeverity.danger,
          timestamp: now,
          machineCode: m.code,
        ));
      } 
      // Aparas Mês Acima da Meta (> 3.0%)
      else if (m.scrapMonth > m.scrapTarget) {
        list.add(PlantAlert(
          id: 'scrap_month_${m.code}',
          title: '${m.code} — Aparas Acima da Meta (${m.scrapMonth.toStringAsFixed(2)}%)',
          message: 'Aparas acumuladas de ${m.scrapMonth.toStringAsFixed(2)}% ultrapassam o limite tolerado de ${m.scrapTarget.toStringAsFixed(1)}%.',
          severity: AlertSeverity.warning,
          timestamp: now,
          machineCode: m.code,
        ));
      }

      // Aparas Turno Atual Acima da Meta (> 3.0%)
      if (m.scrapShift != null && m.scrapShift! > m.scrapTarget) {
        list.add(PlantAlert(
          id: 'scrap_shift_${m.code}',
          title: '${m.code} — Aparas Elevadas no Turno (${m.scrapShift!.toStringAsFixed(2)}%)',
          message: 'Aparas apuradas no turno atual em ${m.scrapShift!.toStringAsFixed(2)}% (meta: ${m.scrapTarget.toStringAsFixed(1)}%). Necessário verificar refile.',
          severity: AlertSeverity.warning,
          timestamp: now,
          machineCode: m.code,
        ));
      }

      // Máquina Parada no Turno
      if (m.shiftMeters == 0) {
        list.add(PlantAlert(
          id: 'stopped_${m.code}',
          title: '${m.code} — Máquina Sem Produção no Turno',
          message: 'Nenhum metro registrado no turno atual (0 m).',
          severity: AlertSeverity.danger,
          timestamp: now,
          machineCode: m.code,
        ));
      }
      // Ritmo Ruim (< 80%)
      else if (m.rhythmClass == 'ritmo-ruim' || (m.rhythmPct > 0 && m.rhythmPct < 80)) {
        list.add(PlantAlert(
          id: 'rhythm_low_${m.code}',
          title: '${m.code} — Ritmo Crítico de Produção (${m.rhythmPct.toInt()}%)',
          message: 'Produção realizada (${m.shiftMeters} m) abaixo do ritmo esperado de ${m.expectedRitmo} m (${m.rhythmPct.toInt()}%). Meta: ${m.shiftTarget} m.',
          severity: AlertSeverity.danger,
          timestamp: now,
          machineCode: m.code,
        ));
      }
      // Ritmo Alerta (80% - 99%)
      else if (m.rhythmClass == 'ritmo-alerta' || (m.rhythmPct >= 80 && m.rhythmPct < 100)) {
        list.add(PlantAlert(
          id: 'rhythm_alert_${m.code}',
          title: '${m.code} — Ritmo Abaixo do Esperado (${m.rhythmPct.toInt()}%)',
          message: 'Ritmo em ${m.rhythmPct.toInt()}%. Produzido ${m.shiftMeters} m de ${m.expectedRitmo} m esperados até o momento.',
          severity: AlertSeverity.warning,
          timestamp: now,
          machineCode: m.code,
        ));
      }
      // Ritmo Excelente (>= 110%)
      else if (m.rhythmPct >= 110) {
        list.add(PlantAlert(
          id: 'rhythm_ok_${m.code}',
          title: '${m.code} — Ritmo Acima da Meta (${m.rhythmPct.toInt()}%)',
          message: 'Produção superando o ritmo esperado com ${m.shiftMeters} m produzidos (${m.rhythmPct.toInt()}%).',
          severity: AlertSeverity.success,
          timestamp: now,
          machineCode: m.code,
        ));
      }
    }

    // 2. Alertas Globais do Setor
    if (_sectorScrapMonth > _scrapGoal) {
      list.add(PlantAlert(
        id: 'sector_scrap_month',
        title: 'Setor Corte & Reb. — Aparas no Mês (${_sectorScrapMonth.toStringAsFixed(2)}%)',
        message: 'Média de aparas do setor (${_sectorScrapMonth.toStringAsFixed(2)}%) está acima da meta geral de ${_scrapGoal.toStringAsFixed(1)}%.',
        severity: AlertSeverity.warning,
        timestamp: now,
      ));
    }

    // Ordenar alertas por gravidade: danger primeiro, depois warning, info, success
    list.sort((a, b) {
      final order = {
        AlertSeverity.danger: 0,
        AlertSeverity.warning: 1,
        AlertSeverity.info: 2,
        AlertSeverity.success: 3,
      };
      return (order[a.severity] ?? 4).compareTo(order[b.severity] ?? 4);
    });

    _alerts = list;
  }

  // WebSocket Service (Node-RED Integration)
  late final WebSocketService _wsService;
  WebSocketStatus get wsStatus => _wsService.status;
  String get wsUrl => _wsService.serverUrl;

  // Firebase HTTPS Service (Realtime Database Sync)
  late final FirebaseHttpService _firebaseService;
  FirebaseSyncStatus get firebaseStatus => _firebaseService.status;
  String get firebaseUrl => _firebaseService.firebaseUrl;

  DateTime _lastUpdate = DateTime.now();
  DateTime get lastUpdate => _lastUpdate;

  bool get isLiveActive =>
      firebaseStatus == FirebaseSyncStatus.connected ||
      wsStatus == WebSocketStatus.connected;

  IndicatorsState({
    String wsServerUrl = 'ws://localhost:1880/ws/telemetria',
    String defaultFirebaseUrl = 'https://pp-corte-reb-default-rtdb.firebaseio.com/zaraplast/corte/dashboard.json',
  }) {
    _wsService = WebSocketService(
      serverUrl: wsServerUrl,
      onTelemetryReceived: _handleTelemetry,
      onStatusChanged: (status) {
        notifyListeners();
      },
    );
    _wsService.connect();

    _firebaseService = FirebaseHttpService(
      firebaseUrl: defaultFirebaseUrl,
      onDataReceived: _handleTelemetry,
      onStatusChanged: (status) {
        notifyListeners();
      },
    );
    _firebaseService.start();
    _generateRealAlerts();
  }

  void updateWebSocketUrl(String newUrl) {
    _wsService.disconnect();
    _wsService = WebSocketService(
      serverUrl: newUrl,
      onTelemetryReceived: _handleTelemetry,
      onStatusChanged: (status) {
        notifyListeners();
      },
    );
    _wsService.connect();
    notifyListeners();
  }

  void updateFirebaseUrl(String newUrl) {
    _firebaseService.updateUrl(newUrl);
    notifyListeners();
  }

  void toggleLiveSync() {
    manualRefresh();
  }

  Future<void> manualRefresh() async {
    await _firebaseService.fetchNow();
    _lastUpdate = DateTime.now();
    notifyListeners();
  }

  static double? _parsePctString(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    final str = value.toString().replaceAll('%', '').replaceAll(',', '.').trim();
    return double.tryParse(str);
  }

  static List<Offset> _parseSvgPolylineCoordinates(String? linha) {
    if (linha == null || linha.trim().isEmpty) return const [];
    try {
      final pairs = linha.trim().split(RegExp(r'\s+'));
      final points = <Offset>[];
      for (final pair in pairs) {
        final coords = pair.split(',');
        if (coords.length >= 2) {
          final x = double.tryParse(coords[0].trim());
          final y = double.tryParse(coords[1].trim());
          if (x != null && y != null) {
            // Node-RED mini charts:
            // M = { larg: 240, alt: 104, esq: 26, dir: 8, topo: 8, base: 18, pctMax: 150 };
            // mx(h) = 26 + (h / 8) * (240 - 26 - 8) = 26 + (h / 8) * 206
            // => xRatio = (x - 26) / 206 (normalized 0.0 to 1.0 across the 8h shift)
            final xRatio = ((x - 26.0) / 206.0).clamp(0.0, 1.0);

            // Node-RED: my(p) = 8 + (1 - p / 150) * 78 => p = ((86 - y) / 78) * 150
            final pct = (((86.0 - y) / 78.0) * 150.0).clamp(0.0, 300.0);
            points.add(Offset(
              double.parse(xRatio.toStringAsFixed(4)),
              double.parse(pct.toStringAsFixed(1)),
            ));
          }
        }
      }
      return points;
    } catch (_) {
      return const [];
    }
  }

  static List<double> _parseSvgPolylinePoints(String? linha) {
    final coords = _parseSvgPolylineCoordinates(linha);
    return coords.map((c) => c.dy).toList();
  }

  void _handleTelemetry(Map<String, dynamic> data) {
    _lastUpdate = DateTime.now();

    // 0. Sincronização Automática de Turno em Tempo Real
    final activeShift = getCurrentShift();
    if (activeShift != _lastLiveShift) {
      _lastLiveShift = activeShift;
      _manualShiftOverride = false; // Virada de turno detectada no relógio
      _selectedShift = activeShift;
    }

    if (data.containsKey('nomeTurno')) {
      final nt = data['nomeTurno'].toString().toLowerCase().trim();
      ShiftFilter? telemetryShift;
      if (nt.contains('1') || nt.contains('a') || nt.contains('1o') || nt.contains('1º')) {
        telemetryShift = ShiftFilter.shift1;
      } else if (nt.contains('2') || nt.contains('b') || nt.contains('2o') || nt.contains('2º')) {
        telemetryShift = ShiftFilter.shift2;
      } else if (nt.contains('3') || nt.contains('c') || nt.contains('3o') || nt.contains('3º')) {
        telemetryShift = ShiftFilter.shift3;
      }

      if (telemetryShift != null) {
        if (_lastTelemetryShiftName != null && _lastTelemetryShiftName != nt) {
          // Virada autoritativa de turno no Firebase / Node-RED
          _manualShiftOverride = false;
        }
        _lastTelemetryShiftName = nt;
        if (!_manualShiftOverride) {
          _selectedShift = telemetryShift;
        }
      }
    } else if (!_manualShiftOverride) {
      _selectedShift = activeShift;
    }

    // 0.1 Totais do Turno e do Dia
    if (data.containsKey('totalTurno') && data['totalTurno'] != null) {
      _totalShiftMeters = (data['totalTurno'] as num).toInt();
    }
    if (data.containsKey('totalDia') && data['totalDia'] != null) {
      _totalDayMeters = (data['totalDia'] as num).toInt();
    }

    // 1. Transferência (formato customizado ou direto do Node-RED)
    if (data.containsKey('transferenciaHoje') || data.containsKey('transferenciaMensal')) {
      final hoje = (data['transferenciaHoje'] as num?)?.toDouble() ?? _transfer.todayWeighed;
      final mensal = (data['transferenciaMensal'] as num?)?.toDouble() ?? _transfer.monthWeighed;
      _transfer = _transfer.copyWith(
        todayWeighed: hoje,
        monthWeighed: mensal,
      );
    } else if (data.containsKey('transferencia')) {
      final t = data['transferencia'] as Map<String, dynamic>;
      _transfer = _transfer.copyWith(
        todayWeighed: (t['pesadoHoje'] as num?)?.toDouble() ?? _transfer.todayWeighed,
        monthWeighed: (t['mensal'] as num?)?.toDouble() ?? _transfer.monthWeighed,
        trendTodayPercent: (t['tendenciaHoje'] as num?)?.toDouble() ?? _transfer.trendTodayPercent,
        trendMonthPercent: (t['tendenciaMes'] as num?)?.toDouble() ?? _transfer.trendMonthPercent,
      );
    }

    // 2. Corte Geral / Metas & Percentuais Visuais do Dashboard Real
    if (data.containsKey('totalGeral')) {
      _corteCurrentMeters = (data['totalGeral'] as num).toInt();
    }
    if (data.containsKey('meta')) {
      _corteTargetMeters = (data['meta'] as num).toInt();
    }
    if (data.containsKey('corteGeral')) {
      final c = data['corteGeral'] as Map<String, dynamic>;
      if (c['atual'] != null) _corteCurrentMeters = (c['atual'] as num).toInt();
      if (c['meta'] != null) _corteTargetMeters = (c['meta'] as num).toInt();
    }
    if (data.containsKey('feitoPctVisual')) {
      _corteConcludedPercentOverride = _parsePctString(data['feitoPctVisual']);
    } else if (data.containsKey('concluidoPctVisual')) {
      _corteConcludedPercentOverride = _parsePctString(data['concluidoPctVisual']);
    }
    if (data.containsKey('restantePctVisual')) {
      _corteRemainingPercentOverride = _parsePctString(data['restantePctVisual']);
    }

    // 3. Setor Aparas & Ritmo
    if (data.containsKey('aparasSetor')) {
      final asMap = data['aparasSetor'] as Map<String, dynamic>;
      if (asMap['turnoTexto'] != null) {
        final rawAsShift = asMap['turnoTexto'].toString().trim();
        if (rawAsShift == '--') {
          _sectorScrapShift = null;
        } else {
          _sectorScrapShift = _parsePctString(rawAsShift) ?? _sectorScrapShift;
        }
      }
      if (asMap['mesTexto'] != null) {
        _sectorScrapMonth = _parsePctString(asMap['mesTexto']) ?? _sectorScrapMonth;
      }
    }
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
    if (data.containsKey('graficoSetorLinha')) {
      final sectorPoints = _parseSvgPolylinePoints(data['graficoSetorLinha']?.toString());
      if (sectorPoints.isNotEmpty) {
        _sectorRhythmPoints = sectorPoints;
      }
    }

    // 4. Máquinas (compatível com Node-RED listaMaquinas + listaAparas + graficosRitmo)
    if (data.containsKey('listaMaquinas') && data['listaMaquinas'] is List) {
      final rawList = data['listaMaquinas'] as List;
      final aparasMap = <String, Map<String, dynamic>>{};
      if (data['listaAparas'] is List) {
        for (var item in data['listaAparas'] as List) {
          if (item is Map<String, dynamic> && item['maquina'] != null) {
            aparasMap[item['maquina'].toString()] = item;
          }
        }
      }

      final graficosMap = <String, Map<String, dynamic>>{};
      final rawGraficos = data['graficosRitmo'] ?? data['graficosMaquinas'];
      if (rawGraficos is List) {
        for (var item in rawGraficos) {
          if (item is Map<String, dynamic> && item['maquina'] != null) {
            graficosMap[item['maquina'].toString()] = item;
          }
        }
      }

      _machines = _machines.map((existing) {
        final match = rawList.firstWhere(
          (m) => m is Map<String, dynamic> &&
              (m['maquina'] == existing.code || m['code'] == existing.code),
          orElse: () => null,
        );
        if (match == null) return existing;
        final m = match as Map<String, dynamic>;
        final ap = aparasMap[existing.code];
        final gr = graficosMap[existing.code];

        final metrosTurno = (m['metrosTurno'] as num?)?.toInt() ??
            (m['shiftMeters'] as num?)?.toInt() ??
            0;
        final metaTurno = (m['metaTurno'] as num?)?.toInt() ??
            (m['shiftTarget'] as num?)?.toInt() ??
            existing.shiftTarget;
        final esperadoTurno = (m['esperadoTurno'] as num?)?.toInt() ??
            (m['expectedRitmo'] as num?)?.toInt() ??
            0;
        final metragemHoje = (m['MetragemHoje'] as num?)?.toInt() ??
            (m['todayMeters'] as num?)?.toInt() ??
            existing.todayMeters;
        final metragemMes = (m['Metragem'] as num?)?.toInt() ??
            (m['monthMeters'] as num?)?.toInt() ??
            existing.monthMeters;

        // 1. Curva do Gráfico (se linha estiver vazia ou temSerie for false, zera a curva anterior!)
        List<Offset> series = const [];
        final rawLinha = gr?['linha']?.toString();
        final bool temSerie = gr?['temSerie'] == true || (rawLinha != null && rawLinha.trim().isNotEmpty);

        if (temSerie && rawLinha != null && rawLinha.trim().isNotEmpty) {
          series = _parseSvgPolylineCoordinates(rawLinha);
        }

        List<double> pts = const [];
        if (series.isNotEmpty) {
          pts = series.map((e) => e.dy).toList();
        } else if (gr?['pontos'] is List && (gr!['pontos'] as List).isNotEmpty) {
          pts = (gr['pontos'] as List).map((e) => (e as num).toDouble()).toList();
        }

        // 2. Percentual do Ritmo (calculado dinamicamente quando pctAtual for '--')
        double rPct = 0.0;
        final rawPctAtual = gr?['pctAtual'] ?? m['pctAtual'];
        final parsedPct = _parsePctString(rawPctAtual);
        if (parsedPct != null) {
          rPct = parsedPct;
        } else if (esperadoTurno > 0 && metrosTurno > 0) {
          rPct = (metrosTurno / esperadoTurno) * 100.0;
        } else if (metrosTurno == 0) {
          rPct = 0.0;
        }

        // 3. Aparas no Turno (quando turnoTexto for '--', zera e limpa o turno anterior)
        double? sShift;
        bool clearScrap = false;
        final rawTurnoTexto = ap?['turnoTexto']?.toString().trim();
        if (rawTurnoTexto != null && (rawTurnoTexto == '--' || rawTurnoTexto.isEmpty)) {
          sShift = null;
          clearScrap = true;
        } else if (rawTurnoTexto != null) {
          sShift = _parsePctString(rawTurnoTexto);
        } else {
          sShift = existing.scrapShift;
        }

        // 4. Aparas no Mês
        double sMes = existing.scrapMonth;
        if (ap?['mesTexto'] != null) {
          sMes = _parsePctString(ap!['mesTexto']) ?? sMes;
        }

        // 5. Subtítulo da análise de turno (ex: "desde 14:02")
        final shiftAnalysis = m['pctTurno']?.toString() ??
            m['shiftAnalysisText']?.toString() ??
            data['pctSetorTexto']?.toString() ??
            'desde $shiftStartTime';

        final rClass = gr?['classe']?.toString() ??
            m['statusClasse']?.toString() ??
            m['classe']?.toString() ??
            (rPct >= 100 ? 'ritmo-ok' : (rPct >= 80 ? 'ritmo-alerta' : (rPct > 0 ? 'ritmo-ruim' : 'ritmo-neutro')));

        return existing.copyWith(
          status: metrosTurno > 0 ? 'running' : 'stopped',
          rhythmClass: rClass,
          operatorName: m['operador']?.toString() ?? m['operatorName']?.toString() ?? '',
          shiftMeters: metrosTurno,
          shiftTarget: metaTurno,
          expectedRitmo: esperadoTurno,
          rhythmPct: rPct,
          rhythmPoints: pts,
          rhythmSeries: series,
          todayMeters: metragemHoje,
          monthMeters: metragemMes,
          scrapShift: sShift,
          clearScrapShift: clearScrap,
          scrapMonth: sMes,
          shiftAnalysisText: shiftAnalysis,
        );
      }).toList();

      // Curva consolidada do setor (calculada a partir das séries temporais reais das máquinas)
      final allSeries = _machines.map((m) => m.rhythmSeries).where((s) => s.isNotEmpty).toList();
      if (allSeries.isNotEmpty) {
        allSeries.sort((a, b) => b.length.compareTo(a.length));
        final ref = allSeries.first;
        final sectorSeries = <Offset>[];
        for (int i = 0; i < ref.length; i++) {
          final x = ref[i].dx;
          double sumY = 0;
          int count = 0;
          for (final s in allSeries) {
            if (i < s.length) {
              sumY += s[i].dy;
              count++;
            }
          }
          if (count > 0) {
            sectorSeries.add(Offset(x, double.parse((sumY / count).toStringAsFixed(1))));
          }
        }
        _sectorRhythmSeries = sectorSeries;
        _sectorRhythmPoints = sectorSeries.map((p) => p.dy).toList();
      } else {
        _sectorRhythmSeries = const [];
        _sectorRhythmPoints = const [];
      }
    } else if (data.containsKey('maquinas') && data['maquinas'] is List) {
      final list = data['maquinas'] as List;
      _machines = list.map((item) {
        final map = item as Map<String, dynamic>;
        return MachineIndicator.fromJson(map);
      }).toList();
    }

    _generateRealAlerts();

    notifyListeners();
  }

  @override
  void dispose() {
    _wsService.disconnect();
    _firebaseService.dispose();
    super.dispose();
  }
}
