import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mobilidade_flutter/main.dart';
import 'package:mobilidade_flutter/models/occurrence.dart';
import 'package:mobilidade_flutter/services/app_store.dart';
import 'package:mobilidade_flutter/screens/report_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test(
    'Ocorrência persiste após recriar o estado e pode ser excluída',
    () async {
      final prefs = await SharedPreferences.getInstance();
      final store = AppStore(prefs);
      final item = Occurrence(
        id: 'one',
        type: 'Rampa ausente',
        address: 'Rua de teste 123',
        description: 'Barreira de teste na esquina.',
        createdAt: DateTime(2026, 1, 1),
      );
      await store.add(item);
      final restored = AppStore(prefs);
      expect(restored.reports.single.description, item.description);
      await restored.remove(restored.reports.single);
      expect(AppStore(prefs).reports, isEmpty);
    },
  );
  test('Cadastro local pode ser criado e atualizado', () async {
    final prefs = await SharedPreferences.getInstance();
    final store = AppStore(prefs);
    expect(store.profile, isEmpty);
    await store.saveProfile({'name': 'Perfil de teste'});
    final restored = AppStore(prefs);
    expect(restored.profile['name'], 'Perfil de teste');
    await restored.saveProfile({...restored.profile, 'name': 'Nome atualizado'});
    expect(AppStore(prefs).profile['name'], 'Nome atualizado');
  });
  test('Preferências de acessibilidade persistem', () async {
    final prefs = await SharedPreferences.getInstance();
    final store = AppStore(prefs);
    await store.setAccessibility(
      large: true,
      contrast: true,
      profile: 'Pessoa cadeirante',
    );
    await store.setWelcome();
    final restored = AppStore(prefs);
    expect(restored.largeText, isTrue);
    expect(restored.highContrast, isTrue);
    expect(restored.welcomed, isTrue);
    expect(restored.mobility, 'Pessoa cadeirante');
  });
  testWidgets('Boas-vindas explicam o app e abrem o início', (tester) async {
    tester.view.physicalSize = const Size(430, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = AppStore(await SharedPreferences.getInstance());
    await tester.pumpWidget(MobilityApp(store: store));
    expect(find.text('Início'), findsNothing);
    await tester.scrollUntilVisible(
      find.byType(FilledButton),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.text('Início'), findsOneWidget);
    expect(find.text('Ocorrências registradas: 0'), findsOneWidget);
    expect(find.text('Meu cadastro'), findsOneWidget);
    expect(store.welcomed, isTrue);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Formulário impede salvar ocorrência sem endereço e descrição', (
    tester,
  ) async {
    final store = AppStore(await SharedPreferences.getInstance());
    await tester.pumpWidget(MaterialApp(home: ReportScreen(store: store)));
    await tester.scrollUntilVisible(
      find.text('Salvar ocorrência'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salvar ocorrência'));
    await tester.pump();
    expect(store.reports, isEmpty);
    expect(
      find.text('Informe a rua e um ponto de referência.'),
      findsOneWidget,
    );
    expect(
      find.text('Descreva a situação com pelo menos 10 caracteres.'),
      findsOneWidget,
    );
  });
}
