import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../models/machine_indicator.dart';
import '../models/alert_model.dart';
import '../providers/indicators_state.dart';
import '../widgets/transfer_card.dart';
import '../widgets/scrap_table_card.dart';
import '../widgets/leadership_card.dart';
import '../widgets/corte_rebobinamento_card.dart';
import '../widgets/mobile/machine_list_item.dart';
import 'mobile_machine_sheet.dart';

class MobileHomeScreen extends StatefulWidget {
  final IndicatorsState state;

  const MobileHomeScreen({
    super.key,
    required this.state,
  });

  @override
  State<MobileHomeScreen> createState() => _MobileHomeScreenState();
}

class _MobileHomeScreenState extends State<MobileHomeScreen>
    with TickerProviderStateMixin {
  int _currentTabIndex = 0;
  String _activeFilter = 'all'; // 'all', 'running', 'setup', 'critical'
  final TextEditingController _searchController = TextEditingController();

  // Speed Dial Animation (+)
  late AnimationController _speedDialController;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;
  bool _isSpeedDialOpen = false;

  // Shift Dropdown Animation (Topo)
  late AnimationController _shiftDropdownController;
  late Animation<double> _shiftExpandAnimation;
  bool _isShiftDropdownOpen = false;

  @override
  void initState() {
    super.initState();
    _speedDialController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _expandAnimation = CurvedAnimation(
      parent: _speedDialController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(
        parent: _speedDialController,
        curve: Curves.easeOutCubic,
      ),
    );

    _shiftDropdownController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
    );
    _shiftExpandAnimation = CurvedAnimation(
      parent: _shiftDropdownController,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _speedDialController.dispose();
    _shiftDropdownController.dispose();
    super.dispose();
  }

  void _toggleSpeedDial() {
    _closeShiftDropdown();
    setState(() {
      _isSpeedDialOpen = !_isSpeedDialOpen;
      if (_isSpeedDialOpen) {
        _speedDialController.forward();
      } else {
        _speedDialController.reverse();
      }
    });
  }

  void _closeSpeedDial() {
    if (_isSpeedDialOpen) {
      setState(() {
        _isSpeedDialOpen = false;
        _speedDialController.reverse();
      });
    }
  }

  void _toggleShiftDropdown() {
    _closeSpeedDial();
    setState(() {
      _isShiftDropdownOpen = !_isShiftDropdownOpen;
      if (_isShiftDropdownOpen) {
        _shiftDropdownController.forward();
      } else {
        _shiftDropdownController.reverse();
      }
    });
  }

  void _closeShiftDropdown() {
    if (_isShiftDropdownOpen) {
      setState(() {
        _isShiftDropdownOpen = false;
        _shiftDropdownController.reverse();
      });
    }
  }

  void _closeAllOverlays() {
    _closeSpeedDial();
    _closeShiftDropdown();
  }

  void _selectTab(int index) {
    setState(() {
      _currentTabIndex = index;
    });
    _closeSpeedDial();
  }

  void _selectShift(ShiftFilter shift) {
    widget.state.setShift(shift);
    _closeShiftDropdown();
  }

  void _openMachineBottomSheet(MachineIndicator machine) {
    _closeAllOverlays();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MobileMachineSheet(
        machine: machine,
        isDark: widget.state.isDarkMode,
      ),
    );
  }

  List<MachineIndicator> _getFilteredMachines() {
    var list = widget.state.machines;
    final query = _searchController.text.toLowerCase().trim();

    if (query.isNotEmpty) {
      list = list
          .where((m) =>
              m.code.toLowerCase().contains(query) ||
              m.name.toLowerCase().contains(query) ||
              m.operatorName.toLowerCase().contains(query))
          .toList();
    }

    switch (_activeFilter) {
      case 'running':
        return list.where((m) => m.status == 'running').toList();
      case 'setup':
        return list.where((m) => m.status == 'setup').toList();
      case 'critical':
        return list.where((m) => m.scrapMonth > m.scrapTarget).toList();
      default:
        return list;
    }
  }

  String _getShiftLabel(ShiftFilter shift) {
    switch (shift) {
      case ShiftFilter.shift1:
        return '1º Turno';
      case ShiftFilter.shift2:
        return '2º Turno';
      case ShiftFilter.shift3:
        return '3º Turno';
      case ShiftFilter.fullDay:
        return 'Dia 24h';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.state.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: _buildCleanAppBar(isDark),
      body: Stack(
        children: [
          // Conteúdo Principal
          RefreshIndicator(
            onRefresh: () async {
              widget.state.manualRefresh();
            },
            color: AppColors.brandSecondary,
            backgroundColor: isDark ? AppColors.darkCardBg : Colors.white,
            child: _buildCurrentTab(isDark),
          ),

          // Capturador de toque transparente (SEM ESCURECER E SEM DESFOCAR A TELA)
          if (_isSpeedDialOpen || _isShiftDropdownOpen)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _closeAllOverlays,
                child: const SizedBox.expand(),
              ),
            ),

          // Menu Dropdown de Turnos Nítido e Limpo (Abre diretamente abaixo do botão de turno)
          Positioned(
            top: 4,
            right: 50,
            child: SizeTransition(
              sizeFactor: _shiftExpandAnimation,
              axisAlignment: -1.0,
              child: FadeTransition(
                opacity: _shiftExpandAnimation,
                child: Container(
                  width: 220,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF111D35) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? const Color(0xFF1E2F52) : const Color(0xFFCBD5E1),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.4 : 0.12),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildShiftDropdownItem(
                        title: '1º Turno',
                        subtitle: '06h às 14h (Agora)',
                        shift: ShiftFilter.shift1,
                        isDark: isDark,
                      ),
                      _buildShiftDropdownItem(
                        title: '2º Turno',
                        subtitle: '14h às 22h',
                        shift: ShiftFilter.shift2,
                        isDark: isDark,
                      ),
                      _buildShiftDropdownItem(
                        title: '3º Turno',
                        subtitle: '22h às 06h',
                        shift: ShiftFilter.shift3,
                        isDark: isDark,
                      ),
                      _buildShiftDropdownItem(
                        title: 'Dia Industrial',
                        subtitle: 'Consolidado 24h',
                        shift: ShiftFilter.fullDay,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Menu Flutuante Expansível (+) Nítido e Claro
          Positioned(
            right: 20,
            bottom: 24,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Itens que expandem para cima do botão +
                SizeTransition(
                  sizeFactor: _expandAnimation,
                  axisAlignment: 1.0,
                  child: FadeTransition(
                    opacity: _expandAnimation,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _buildSpeedDialItem(
                          index: 3,
                          label: 'Alertas (${widget.state.alerts.length})',
                          icon: Icons.notifications_active_rounded,
                          color: AppColors.dangerLight,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 10),
                        _buildSpeedDialItem(
                          index: 2,
                          label: 'Aparas %',
                          icon: Icons.pie_chart_rounded,
                          color: const Color(0xFFD97706),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 10),
                        _buildSpeedDialItem(
                          index: 1,
                          label: 'Máquinas',
                          icon: Icons.precision_manufacturing_rounded,
                          color: AppColors.brandSecondary,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 10),
                        _buildSpeedDialItem(
                          index: 0,
                          label: 'Geral (Dashboard)',
                          icon: Icons.dashboard_rounded,
                          color: AppColors.brandPrimary,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ),
                ),

                // Botão Circular Flutuante com ícone +
                GestureDetector(
                  onTap: _toggleSpeedDial,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.brandPrimary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: isDark ? const Color(0xFF0284C7) : Colors.white24,
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: RotationTransition(
                        turns: _rotateAnimation,
                        child: const Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShiftDropdownItem({
    required String title,
    required String subtitle,
    required ShiftFilter shift,
    required bool isDark,
  }) {
    final bool isSelected = widget.state.selectedShift == shift;

    return InkWell(
      onTap: () => _selectShift(shift),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? const Color(0xFF1E3A68) : const Color(0xFFE0F2FE))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
              size: 16,
              color: isSelected
                  ? AppColors.brandSecondary
                  : (isDark ? AppColors.darkTextMuted : const Color(0xFF94A3B8)),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                      color: isSelected
                          ? (isDark ? Colors.white : AppColors.brandPrimary)
                          : (isDark ? Colors.white : AppColors.lightTextPrimary),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeedDialItem({
    required int index,
    required String label,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    final bool isSelected = _currentTabIndex == index;

    return GestureDetector(
      onTap: () => _selectTab(index),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF111D35) : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected ? AppColors.brandSecondary : (isDark ? const Color(0xFF1E2F52) : const Color(0xFFCBD5E1)),
                width: isSelected ? 1.5 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w800,
                color: isSelected
                    ? (isDark ? const Color(0xFF38BDF8) : AppColors.brandPrimary)
                    : (isDark ? Colors.white : AppColors.lightTextPrimary),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.brandSecondary : (isDark ? const Color(0xFF132342) : Colors.white),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.brandSecondary : (isDark ? const Color(0xFF1E2F52) : const Color(0xFFCBD5E1)),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                icon,
                size: 19,
                color: isSelected
                    ? Colors.white
                    : (isDark ? const Color(0xFF38BDF8) : AppColors.brandPrimary),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Cabeçalho com Botão de Turno Expansível no Local
  PreferredSizeWidget _buildCleanAppBar(bool isDark) {
    return AppBar(
      elevation: 0,
      scrolledUnderElevation: 1,
      backgroundColor: isDark ? AppColors.darkNavBg : Colors.white,
      titleSpacing: 16,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.brandPrimary,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isDark ? AppColors.brandSecondary : Colors.transparent,
                width: 1,
              ),
            ),
            child: const Center(
              child: Text(
                'Z',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 20,
                  fontFamily: 'Outfit',
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'ZARAPLAST',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
              color: isDark ? Colors.white : AppColors.brandPrimary,
              fontFamily: 'Outfit',
            ),
          ),
        ],
      ),
      actions: [
        InkWell(
          onTap: _toggleShiftDropdown,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _isShiftDropdownOpen
                  ? (isDark ? AppColors.brandSecondary : const Color(0xFFE0F2FE))
                  : (isDark ? AppColors.darkCardBg : const Color(0xFFF1F5F9)),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isShiftDropdownOpen
                    ? AppColors.brandSecondary
                    : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
              ),
            ),
            child: Row(
              children: [
                Text(
                  _getShiftLabel(widget.state.selectedShift),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: _isShiftDropdownOpen
                        ? (isDark ? Colors.white : AppColors.brandPrimary)
                        : (isDark ? Colors.white : AppColors.lightTextPrimary),
                  ),
                ),
                const SizedBox(width: 4),
                AnimatedRotation(
                  turns: _isShiftDropdownOpen ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 180),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 16,
                    color: _isShiftDropdownOpen
                        ? (isDark ? Colors.white : AppColors.brandPrimary)
                        : (isDark ? Colors.white : AppColors.lightTextPrimary),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 6),
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            color: isDark ? const Color(0xFFFCD34D) : AppColors.brandPrimary,
            size: 20,
          ),
          onPressed: widget.state.toggleTheme,
        ),
        const SizedBox(width: 6),
      ],
    );
  }

  Widget _buildCurrentTab(bool isDark) {
    switch (_currentTabIndex) {
      case 0:
        return _buildExecutiveDashboardTab(isDark);
      case 1:
        return _buildMachinesHubTab(isDark);
      case 2:
        return _buildQualityScrapTab(isDark);
      case 3:
        return _buildAlertsTab(isDark);
      default:
        return _buildExecutiveDashboardTab(isDark);
    }
  }

  /// ABA 1: Visão Geral / Dashboard
  Widget _buildExecutiveDashboardTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      children: [
        // 1. Transferência (Pesagem Diária e Mensal)
        TransferCard(
          transfer: widget.state.transfer,
          isDark: isDark,
        ),
        const SizedBox(height: 12),

        // 2. Corte & Rebobinamento Card (Gauge de Precisão)
        CorteRebobinamentoCard(
          currentMeters: widget.state.corteCurrentMeters,
          targetMeters: widget.state.corteTargetMeters,
          completedPercent: widget.state.corteConcludedPercent,
          remainingPercent: widget.state.corteRemainingPercent,
          isDark: isDark,
        ),
        const SizedBox(height: 12),

        // 3. Resumo de Aparas do Setor
        _buildSectorSummaryCard(isDark),
        const SizedBox(height: 16),

        // 4. Seção Acompanhamento de Máquinas
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ACOMPANHAMENTO DE MÁQUINAS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: isDark ? AppColors.darkTextSecondary : AppColors.brandPrimary,
              ),
            ),
            InkWell(
              onTap: () => setState(() => _currentTabIndex = 1),
              child: Text(
                'Ver Todas (6) →',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  color: isDark ? const Color(0xFF38BDF8) : AppColors.brandSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        ...widget.state.machines.take(3).map((m) => MachineListItem(
              machine: m,
              isDark: isDark,
              onTap: () => _openMachineBottomSheet(m),
            )),

        const SizedBox(height: 80),
      ],
    );
  }

  /// ABA 2: Hub de Máquinas BCR
  Widget _buildMachinesHubTab(bool isDark) {
    final filtered = _getFilteredMachines();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          color: isDark ? AppColors.darkBg : AppColors.lightBg,
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: (val) => setState(() {}),
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
                decoration: InputDecoration(
                  hintText: 'Filtrar por código (BCR006), OP ou operador...',
                  hintStyle: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                  ),
                  prefixIcon: Icon(Icons.search_rounded, size: 18, color: isDark ? AppColors.darkTextMuted : const Color(0xFF64748B)),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 16),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: isDark ? AppColors.darkCardBg : Colors.white,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _filterChip('Todas (6)', 'all', isDark),
                    const SizedBox(width: 8),
                    _filterChip('Em Operação (5)', 'running', isDark),
                    const SizedBox(width: 8),
                    _filterChip('Em Setup (1)', 'setup', isDark),
                    const SizedBox(width: 8),
                    _filterChip('Aparas > 3% (4)', 'critical', isDark),
                  ],
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: filtered.isEmpty
              ? Center(
                  child: Text(
                    'Nenhuma máquina encontrada.',
                    style: TextStyle(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final m = filtered[index];
                    return MachineListItem(
                      machine: m,
                      isDark: isDark,
                      onTap: () => _openMachineBottomSheet(m),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _filterChip(String label, String key, bool isDark) {
    final isSelected = _activeFilter == key;
    return InkWell(
      onTap: () => setState(() => _activeFilter = key),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark ? AppColors.brandSecondary : AppColors.brandPrimary)
              : (isDark ? AppColors.darkCardBg : Colors.white),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? (isDark ? AppColors.brandSecondary : AppColors.brandPrimary)
                : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
          ),
        ),
      ),
    );
  }

  /// ABA 3: Qualidade & Aparas
  Widget _buildQualityScrapTab(bool isDark) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      children: [
        ScrapTableCard(
          machines: widget.state.machines,
          sectorShift: widget.state.sectorScrapShift,
          sectorDay: widget.state.sectorScrapDay,
          sectorMonth: widget.state.sectorScrapMonth,
          scrapGoal: widget.state.scrapGoal,
          isDark: isDark,
          onSelectMachine: _openMachineBottomSheet,
        ),
        const SizedBox(height: 14),
        LeadershipCard(
          machines: widget.state.machines,
          isDark: isDark,
          onSelectMachine: _openMachineBottomSheet,
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  /// ABA 4: Alertas
  Widget _buildAlertsTab(bool isDark) {
    final alerts = widget.state.alerts;
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'OCORRÊNCIAS & ALERTAS INDUSTRIAIS',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
                color: isDark ? AppColors.darkTextSecondary : AppColors.brandPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.brandSecondary.withOpacity(0.15)
                    : const Color(0xFFE0F2FE),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isDark ? const Color(0xFF0369A1) : const Color(0xFFBAE6FD),
                ),
              ),
              child: Text(
                '${alerts.length} ATIVOS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: isDark ? const Color(0xFF38BDF8) : AppColors.brandSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ...alerts.map((alert) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCardBg : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: alert.severity == AlertSeverity.danger
                      ? (isDark ? AppColors.dangerBorderDark : AppColors.dangerBorderLight)
                      : (isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        alert.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                          color: alert.severity == AlertSeverity.danger
                              ? (isDark ? AppColors.dangerTextDark : AppColors.dangerLight)
                              : (isDark ? Colors.white : AppColors.lightTextPrimary),
                        ),
                      ),
                      Text(
                        Formatters.formatTime(alert.timestamp),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.message,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildSectorSummaryCard(bool isDark) {
    final Color scrapValueColor = isDark ? AppColors.dangerDark : AppColors.dangerLight;
    final Color okValColor = isDark ? const Color(0xFF34D399) : AppColors.successLight;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardBg : AppColors.lightCardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkCardBorder : AppColors.lightCardBorder,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.35) : const Color(0x0C0F172A),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'APARAS DO SETOR (ACUMULADO)',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: isDark ? AppColors.darkTextSecondary : const Color(0xFF475569),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.dangerBgDark : AppColors.dangerBgLight,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: isDark ? AppColors.dangerBorderDark : AppColors.dangerBorderLight,
                  ),
                ),
                child: Text(
                  'META: 3,0%',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: isDark ? AppColors.dangerTextDark : AppColors.dangerTextLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${Formatters.formatDecimal(widget.state.sectorScrapMonth)}%',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: scrapValueColor,
                  fontFamily: 'Outfit',
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      Text(
                        '1º Turno: ',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      Text(
                        '0,00%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: okValColor,
                        ),
                      ),
                      Text(
                        ' (Dentro)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextMuted : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        'Dia: ',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      Text(
                        '0,00%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: okValColor,
                        ),
                      ),
                      Text(
                        ' (Dentro)',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkTextMuted : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
