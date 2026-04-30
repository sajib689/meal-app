import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/meals/providers/meal_provider.dart';
import 'features/bazar/providers/bazar_provider.dart';
import 'features/notices/providers/notice_provider.dart';
import 'features/billing/providers/transaction_provider.dart';
import 'features/reports/providers/report_provider.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'shared/theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MealProvider()),
        ChangeNotifierProvider(create: (_) => BazarProvider()),
        ChangeNotifierProvider(create: (_) => NoticeProvider()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: const MealMasterApp(),
    ),
  );
}

class MealMasterApp extends StatelessWidget {
  const MealMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    final router = GoRouter(
      initialLocation: authProvider.isAuthenticated ? '/dashboard' : '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
      ],
      redirect: (context, state) {
        final loggingIn = state.uri.path == '/login';
        final registering = state.uri.path == '/register';

        if (!authProvider.isAuthenticated) {
          if (loggingIn || registering) return null;
          return '/login';
        }

        if (loggingIn || registering) {
          return '/dashboard';
        }
        return null;
      },
    );

    return MaterialApp.router(
      title: 'MealMaster',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: router,
    );
  }
}
