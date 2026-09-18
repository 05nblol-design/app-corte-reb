// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:indicadores_zaraplast/models/machine_indicator.dart';
import 'package:indicadores_zaraplast/widgets/machines_rhythm_card.dart';

void main() {
  testWidgets('MachinesRhythmCard smoke test', (WidgetTester tester) async {
    const testMachines = [
      MachineIndicator(
        code: 'BCR006',
        name: 'Cortadeira 06',
        status: 'running',
        operatorName: 'Antônio',
        speedMpm: 380,
        shiftMeters: 36135,
        shiftTarget: 60000,
        rhythmPct: 71.0,
        todayMeters: 36135,
        monthMeters: 1853019,
        scrapMonth: 5.26,
        productionOrder: 'OP-1',
        materialDescription: 'PEBD',
      ),
    ];

    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: MachinesRhythmCard(
          machines: testMachines,
          shiftTitle: '1º TURNO',
          timeLabels: ['06h', '10h', '14h'],
          isDark: false,
        ),
      ),
    ));

    expect(find.byType(MachinesRhythmCard), findsOneWidget);
    expect(find.textContaining('RITMO POR MÁQUINA'), findsOneWidget);
    expect(find.text('BCR006'), findsOneWidget);
  });
}
