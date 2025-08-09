import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/main_screen.dart';
import 'screens/home_screen.dart';
import 'screens/diary_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/subscription_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Supabase 초기화 (실제 URL과 KEY는 나중에 설정)
  await Supabase.initialize(
    url: 'YOUR_SUPABASE_URL',
    anonKey: 'YOUR_SUPABASE_ANON_KEY',
  );
  
  // 앱 시작 시 익명 로그인
  try {
    final authService = AuthService();
    if (authService.currentUser == null) {
      await authService.signInAnonymously();
    }
  } catch (e) {
    debugPrint('익명 로그인 실패: $e');
  }
  
  runApp(MyApp());
}

final _router = GoRouter(
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainScreen(child: child),
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
    return MaterialApp.router(
      title: 'AI 일기장',
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
  }
}