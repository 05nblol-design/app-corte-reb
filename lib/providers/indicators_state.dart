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

  String get shiftShortName {
    switch (_selectedShift) {
      case ShiftFilter.shift1:
        return '1º TURNO';
      case ShiftFilter.shift2:
        return '2º TURNO';
      case ShiftFilter.shift3:
        return '3º TURNO';
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

  List<double> get currentSectorRhythmPoints {
    switch (_selectedShift) {
      case ShiftFilter.shift1:
        return _sectorRhythmPoints;
      case ShiftFilter.shift2:
        return const [65.0, 72.0, 75.0, 78.0, 76.0];
      case ShiftFilter.shift3:
        return const [60.0, 64.0, 68.0, 70.0, 69.0];
      case ShiftFilter.fullDay:
        return const [62.0, 69.0, 74.0, 72.0, 71.0];
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
      productionOrder: '',
      materialDescription: '',
      scrapReasons: [],
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
      productionOrder: '',
      materialDescription: '',
      scrapReasons: [],
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
      productionOrder: '',
      materialDescription: '',
      scrapReasons: [],
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
      productionOrder: '',
      materialDescription: '',
      scrapReasons: [],
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
      productionOrder: '',
      materialDescription: '',
      scrapReasons: [],
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
      productionOrder: '',
      materialDescription: '',
      scrapReasons: [],
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

  static List<double> _parseSvgPolylinePoints(String? linha) {
    if (linha == null || linha.trim().isEmpty) return const [];
    try {
      final pairs = linha.trim().split(RegExp(r'\s+'));
      final points = <double>[];
      for (final pair in pairs) {
        final coords = pair.split(',');
        if (coords.length >= 2) {
          final y = double.tryParse(coords[1].trim());
          if (y != null) {
            // No web/Node-RED: y = 74 - (pct / 150) * 65  =>  pct = ((74 - y) / 65) * 150
            final pct = ((74.0 - y) / 65.0) * 150.0;
            points.add(double.parse(pct.clamp(0.0, 300.0).toStringAsFixed(1)));
          }
        }
      }
      return points;
    } catch (_) {
      return const [];
    }
  }

  void _handleTelemetry(Map<String, dynamic> data) {
    _lastUpdate = DateTime.now();

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
    if (data.containsKey('concluidoPctVisual')) {
      _corteConcludedPercentOverride = _parsePctString(data['concluidoPctVisual']);
    }
    if (data.containsKey('restantePctVisual')) {
      _corteRemainingPercentOverride = _parsePctString(data['restantePctVisual']);
    }

    // 3. Setor Aparas & Ritmo
    if (data.containsKey('aparasSetor')) {
      final asMap = data['aparasSetor'] as Map<String, dynamic>;
      if (asMap['turnoTexto'] != null) {
        _sectorScrapShift = _parsePctString(asMap['turnoTexto']) ?? _sectorScrapShift;
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
            existing.shiftMeters;
        final metaTurno = (m['metaTurno'] as num?)?.toInt() ??
            (m['shiftTarget'] as num?)?.toInt() ??
            existing.shiftTarget;
        final esperadoTurno = (m['esperadoTurno'] as num?)?.toInt() ??
            (m['expectedRitmo'] as num?)?.toInt() ??
            existing.expectedRitmo;
        final metragemHoje = (m['MetragemHoje'] as num?)?.toInt() ??
            (m['todayMeters'] as num?)?.toInt() ??
            existing.todayMeters;
        final metragemMes = (m['Metragem'] as num?)?.toInt() ??
            (m['monthMeters'] as num?)?.toInt() ??
            existing.monthMeters;

        double rPct = existing.rhythmPct;
        if (gr?['pctAtual'] != null) {
          rPct = _parsePctString(gr!['pctAtual']) ?? rPct;
        } else if (m['pctAtual'] != null) {
          rPct = _parsePctString(m['pctAtual']) ?? rPct;
        } else if (esperadoTurno > 0 && metrosTurno > 0) {
          rPct = (metrosTurno / esperadoTurno) * 100.0;
        }

        double? sShift = existing.scrapShift;
        if (ap?['turnoTexto'] != null) {
          sShift = _parsePctString(ap!['turnoTexto']) ?? sShift;
        }

        double sMes = existing.scrapMonth;
        if (ap?['mesTexto'] != null) {
          sMes = _parsePctString(ap!['mesTexto']) ?? sMes;
        }

        List<double>? pts;
        if (gr?['linha'] != null) {
          final parsed = _parseSvgPolylinePoints(gr!['linha']?.toString());
          if (parsed.isNotEmpty) {
            pts = parsed;
          }
        }
        if (pts == null) {
          if (gr?['pontos'] is List) {
            pts = (gr!['pontos'] as List).map((e) => (e as num).toDouble()).toList();
          } else if (gr?['rhythmPoints'] is List) {
            pts = (gr!['rhythmPoints'] as List).map((e) => (e as num).toDouble()).toList();
          } else if (m['rhythmPoints'] is List) {
            pts = (m['rhythmPoints'] as List).map((e) => (e as num).toDouble()).toList();
          } else if (m['pontos'] is List) {
            pts = (m['pontos'] as List).map((e) => (e as num).toDouble()).toList();
          }
        }

        // Subtítulo da análise de turno (ex: "desde 06:02")
        final shiftAnalysis = m['pctTurno']?.toString() ??
            m['shiftAnalysisText']?.toString() ??
            data['pctSetorTexto']?.toString() ??
            existing.shiftAnalysisText;

        return existing.copyWith(
          shiftMeters: metrosTurno,
          shiftTarget: metaTurno,
          expectedRitmo: esperadoTurno,
          rhythmPct: rPct,
          rhythmPoints: pts ?? existing.rhythmPoints,
          todayMeters: metragemHoje,
          monthMeters: metragemMes,
          scrapShift: sShift,
          scrapMonth: sMes,
          shiftAnalysisText: shiftAnalysis,
        );
      }).toList();
    } else if (data.containsKey('maquinas') && data['maquinas'] is List) {
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
    _firebaseService.dispose();
    super.dispose();
  }
}
