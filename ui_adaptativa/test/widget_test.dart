import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ui_adaptativa/main.dart';

void main() {
  testWidgets('shows general settings and updates preferences', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SettingsApp());

    expect(find.text('Ajustes'), findsOneWidget);
    expect(find.text('Preferencias generales'), findsOneWidget);
    expect(find.text('Apariencia'), findsOneWidget);

    final startupSwitch = tester.widget<Switch>(find.byType(Switch).first);
    expect(startupSwitch.value, isFalse);

    await tester.tap(find.text('Notificaciones').first);
    await tester.pumpAndSettle();

    expect(find.text('Resumen semanal'), findsOneWidget);
    final weeklySummarySwitch = tester.widget<Switch>(
      find.byType(Switch).at(1),
    );
    expect(weeklySummarySwitch.value, isFalse);
    await tester.tap(find.byType(Switch).at(1));
    await tester.pumpAndSettle();
    expect(tester.widget<Switch>(find.byType(Switch).at(1)).value, isTrue);
  });

  testWidgets('uses a sidebar on wide layouts', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SettingsApp());

    expect(find.text('PREFERENCIAS'), findsOneWidget);
    expect(find.text('Todo está al día'), findsOneWidget);
    expect(find.text('Ajustes'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wide layout scrolls when the window is short', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(1000, 420);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SettingsApp());

    expect(tester.takeException(), isNull);
    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -350),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Reducir animaciones'), findsOneWidget);
  });

  testWidgets('search navigates to a section and account fields are editable', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const SettingsApp());

    await tester.tap(find.byTooltip('Buscar ajustes'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'privacidad');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Privacidad').last);
    await tester.pumpAndSettle();
    expect(find.text('Privacidad y datos'), findsOneWidget);

    await tester.tap(find.byTooltip('Buscar ajustes'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'cuenta');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cuenta').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nombre').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Ada Lovelace');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('Ada Lovelace'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile settings scroll without overflow', (
    WidgetTester tester,
  ) async {
    tester.view.physicalSize = const Size(320, 420);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const SettingsApp());

    final layoutException = tester.takeException();
    expect(layoutException, isNull, reason: '$layoutException');
    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
