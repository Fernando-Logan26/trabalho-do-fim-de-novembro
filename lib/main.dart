import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/app_store.dart';
import 'widgets/common.dart';
import 'screens/home_screen.dart';
import 'screens/map_screen.dart';
import 'screens/routes_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/report_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = AppStore(await SharedPreferences.getInstance());
  runApp(MobilityApp(store: store));
}

class MobilityApp extends StatelessWidget {
  final AppStore store;
  const MobilityApp({required this.store, super.key});
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: store,
    builder: (context, _) => MaterialApp(
      title: 'Mobilidade PVH',
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: store.highContrast ? Colors.black : brand,
          contrastLevel: store.highContrast ? 1 : 0,
        ),
        scaffoldBackgroundColor: const Color(0xFFFAFAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFFAFAFC),
          foregroundColor: ink,
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          filled: true,
          fillColor: Colors.white,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: Color(0xFFE8E7ED)),
          ),
        ),
      ),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: MediaQuery.textScalerOf(
            context,
          ).clamp(minScaleFactor: store.largeText ? 1.2 : 1),
        ),
        child: child!,
      ),
      home: store.welcomed
          ? AppShell(store: store)
          : WelcomeScreen(onStart: store.setWelcome),
    ),
  );
}

class AppShell extends StatefulWidget {
  final AppStore store;
  const AppShell({required this.store, super.key});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int tab = 0;
  void select(int value) => setState(() => tab = value);
  Future<void> report() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => ReportScreen(store: widget.store)),
    );
    if (saved == true && mounted) {
      message(
        context,
        'Ocorrência salva neste celular. Veja em Preferências → Minhas ocorrências.',
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: switch (tab) {
        0 => HomeScreen(store: widget.store, onMap: () => select(1), onReport: report),
        1 => MapScreen(onReport: report),
        2 => RoutesScreen(
          store: widget.store,
          onMap: () => select(1),
          onSettings: () => select(3),
        ),
        _ => SettingsScreen(store: widget.store),
      },
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: tab,
      onDestinationSelected: select,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Início',
        ),
        NavigationDestination(
          icon: Icon(Icons.map_outlined),
          selectedIcon: Icon(Icons.map),
          label: 'Mapa',
        ),
        NavigationDestination(icon: Icon(Icons.alt_route), label: 'Caminhos'),
        NavigationDestination(icon: Icon(Icons.tune), label: 'Preferências'),
      ],
    ),
  );
}
