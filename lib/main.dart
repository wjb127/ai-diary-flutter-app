import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/main_screen.dart';
import 'screens/home_screen.dart';
import 'screens/diary_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/subscription_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/auth_screen.dart';
import 'services/auth_service.dart';
import 'services/localization_service.dart';
import 'widgets/responsive_wrapper.dart';

const String kSupabaseUrl = String.fromEnvironment(
  'SUPABASE_URL',
  defaultValue: 'https://example.supabase.co',
);
const String kSupabaseAnonKey = String.fromEnvironment(
  'SUPABASE_ANON_KEY',
  defaultValue: 'public-anon-key-placeholder',
);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 한국어 날짜 포맷 초기화
  await initializeDateFormatting('ko_KR', null);
  
  // Supabase 초기화 (dart-define 값이 없으면 플레이스홀더로 초기화)
  try {
    await Supabase.initialize(
      url: kSupabaseUrl,
      anonKey: kSupabaseAnonKey,
    );
  } catch (e) {
    debugPrint('Supabase 초기화 실패: $e');
  }
  
  // 게스트 모드로 자동 시작
  _authService.signInAsGuest();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocalizationService()),
      ],
      child: MyApp(),
    ),
  );
}

final _authService = AuthService();

final _router = GoRouter(
  initialLocation: '/',  // 바로 홈으로 시작
  refreshListenable: _authService,
  routes: [
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/auth',
      name: 'auth',
      builder: (context, state) => const ResponsiveWrapper(
        child: AuthScreen(),
      ),
    ),
    ShellRoute(
      builder: (context, state, child) => ResponsiveWrapper(
        child: MainScreen(child: child),
      ),
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/diary',
          name: 'diary',
          builder: (context, state) => const DiaryScreen(),
        ),
        GoRoute(
          path: '/profile',
          name: 'profile',
          builder: (context, state) => const ProfileScreen(),
        ),
        GoRoute(
          path: '/subscription',
          name: 'subscription',
          builder: (context, state) => const SubscriptionScreen(),
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return MaterialApp.router(
          title: 'AI 일기장',
          locale: Locale(localizationService.currentLanguage),
          localizationsDelegates: const [
            AppLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ko', ''),
            Locale('en', ''),
          ],
          theme: ThemeData(
            primarySwatch: Colors.blue,
            primaryColor: const Color(0xFF6366F1),
            scaffoldBackgroundColor: const Color(0xFFF8FAFC),
            fontFamily: 'Pretendard',
            appBarTheme: const AppBarTheme(
              elevation: 0,
              backgroundColor: Colors.transparent,
              foregroundColor: Color(0xFF1E293B),
              centerTitle: true,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
            ),
            cardTheme: CardTheme(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.white,
            ),
          ),
          routerConfig: _router,
        );
      },
    );
  }
}