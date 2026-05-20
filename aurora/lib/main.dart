import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/aurora_theme.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_dashboard.dart';
import 'screens/signal_fusion_screen.dart';
import 'screens/crisis_detail_screen.dart';
import 'core/locator.dart';
import 'screens/login_screen.dart';
import 'providers/auth_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupLocator();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0A0A1A),
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  runApp(
    const ProviderScope(
      child: AuroraApp(),
    ),
  );
}

class AuroraApp extends ConsumerWidget {
  const AuroraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    return MaterialApp(
      title: 'AURORA — World Crisis Network',
      debugShowCheckedModeBanner: false,
      theme: AuroraTheme.darkTheme,
      home: authState.token == null ? const LoginScreen() : const HomeDashboard(),
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const HomeDashboard(),
        '/signal_fusion': (context) => const SignalFusionScreen(),
        '/crisis_detail': (context) => const CrisisDetailScreen(),
      },
    );
  }
}
