import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'providers/indicators_state.dart';
import 'screens/mobile_home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Mobile Portrait Optimization
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Android Navigation Bar & Status Bar Styling
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0F172A),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  runApp(const IndicadoresZaraplastMobileApp());
}

class IndicadoresZaraplastMobileApp extends StatefulWidget {
  const IndicadoresZaraplastMobileApp({super.key});

  @override
  State<IndicadoresZaraplastMobileApp> createState() =>
      _IndicadoresZaraplastMobileAppState();
}

class _IndicadoresZaraplastMobileAppState
    extends State<IndicadoresZaraplastMobileApp> {
  late final IndicatorsState _indicatorsState;

  @override
  void initState() {
    super.initState();
    _indicatorsState = IndicatorsState();
  }

  @override
  void dispose() {
    _indicatorsState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _indicatorsState,
      builder: (context, child) {
        return MaterialApp(
          title: 'Indicadores Zaraplast Mobile',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _indicatorsState.themeMode,
          home: MobileHomeScreen(state: _indicatorsState),
        );
      },
    );
  }
}
