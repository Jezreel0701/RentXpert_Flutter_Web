import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'dart:html' as html;

import 'firebase_options.dart';
import 'theme_provider.dart';
import 'Main_Screen.dart';
import 'login.dart';
import 'Dashboard_Screen.dart';
import 'User_ManagementTenant.dart';
import 'User_ManagementLandlord.dart';
import 'Properties_Management.dart';
import 'Analytics_Managenent.dart';
import 'Settings_Screen.dart';
import 'Sidebar.dart';
import 'PageNotfound.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // or your manual options
  );

  if (kIsWeb) {
    await FirebaseMessaging.instance.requestPermission();
    await FirebaseMessaging.instance.setAutoInitEnabled(true);
  }
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  final token = prefs.getString('authToken');
  final isLoggedIn = token != null;

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider()..initializeTheme(isDarkMode),
      child: AdminWeb(isLoggedIn: isLoggedIn),
    ),
  );
}

class AdminWeb extends StatelessWidget {
  final bool isLoggedIn;
  final _rootNavigatorKey = GlobalKey<NavigatorState>();
  final _shellNavigatorKey = GlobalKey<NavigatorState>();

    AdminWeb({super.key, required this.isLoggedIn});

  bool _isValidRoute(String route) {
    const validRoutes = {
      '/dashboard',
      '/users-tenant',
      '/users-landlord',
      '/properties-management',
      '/analytics',
      '/settings',
      '/login'
    };
    return validRoutes.contains(route);
  }

  String _getInitialRoute(bool isLoggedIn) {
    if (kIsWeb) {
      final currentHash = html.window.location.hash.replaceFirst('#', '');
      if (_isValidRoute(currentHash)) return currentHash;
      return isLoggedIn ? '/dashboard' : '/login';
    }
    return isLoggedIn ? '/dashboard' : '/login';
  }

  GoRouter _buildRouter(bool isLoggedIn) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: _getInitialRoute(isLoggedIn),
      routes: [
        GoRoute(
          path: '/login',
          pageBuilder: (context, state) => MaterialPage(
            key: state.pageKey,
            child: Login(),
          ),
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return ScaffoldWithSidebar(child: child);
          },
          routes: [
            GoRoute(
              path: '/dashboard',
              pageBuilder: (context, state) => MaterialPage(
                key: state.pageKey,
                child: DashboardScreen(),
              ),
            ),
            GoRoute(
              path: '/users-tenant',
              pageBuilder: (context, state) => MaterialPage(
                key: state.pageKey,
                child: UserManagementTenant(),
              ),
            ),
            GoRoute(
              path: '/users-landlord',
              pageBuilder: (context, state) => MaterialPage(
                key: state.pageKey,
                child: UserManagementLandlord(),
              ),
            ),
            GoRoute(
              path: '/properties-management',
              pageBuilder: (context, state) => MaterialPage(
                key: state.pageKey,
                child: PropertiesManagementScreen(),
              ),
            ),
            GoRoute(
              path: '/analytics',
              pageBuilder: (context, state) => MaterialPage(
                key: state.pageKey,
                child: AnalyticsScreen(),
              ),
            ),
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) => MaterialPage(
                key: state.pageKey,
                child: SettingsScreen(),
              ),
            ),
          ],
        ),
      ],
      redirect: (context, state) async {
        final prefs = await SharedPreferences.getInstance();
        final token = prefs.getString('authToken');
        final isLoggedIn = token != null;
        final goingToLogin = state.matchedLocation == '/login';

        if (!isLoggedIn && !goingToLogin) return '/login';
        if (isLoggedIn && goingToLogin) return '/dashboard';
        return null;
      },
      errorBuilder: (context, state) => PageNotFoundScreen(),
    );
  }

  Future<bool> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('authToken') != null;
  }


  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Provider.of<ThemeProvider>(context),
      builder: (context, _) {
        return MaterialApp.router(
          title: 'Admin RentXpert',
          debugShowCheckedModeBanner: false,
          theme: _buildLightTheme(),
          darkTheme: _buildDarkTheme(),
          themeMode: Provider.of<ThemeProvider>(context).isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          routerConfig: _buildRouter(isLoggedIn),
          builder: (context, child) {
            return AnimatedTheme(
              data: Theme.of(context),
              duration: const Duration(milliseconds: 200),
              child: child!,
            );
          },
        );
      },
    );
  }

  ThemeData _buildLightTheme() {
    return ThemeData(
      fontFamily: 'Krub-Regular',
      scaffoldBackgroundColor: const Color(0xFFF5F5F5),
      // [Add other light theme properties]
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData.dark().copyWith(
      colorScheme: ColorScheme.dark(
        primary: const Color(0xFF4A758F),
        secondary: Colors.tealAccent[200]!,
        surface: const Color(0xFF121212),
        background: const Color(0xFF1E1E1E),
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.grey[900]!,
        elevation: 0,
        titleTextStyle: const TextStyle(
          fontFamily: 'Krub-Regular',
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      // [Other dark theme properties]
    );
  }
}

class ScaffoldWithSidebar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithSidebar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).matchedLocation;
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 1000;

            if (isMobile) {
              return const MainScreen();
            } else {
              return Row(
                children: [
                  Container(
                    width: 220,
                    color: const Color(0xFF4A758F),
                    child: Sidebar(
                      currentRoute: currentRoute,
                      parentContext: context,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: isDarkMode
                          ? const Color(0xFF121212)
                          : const Color(0xFFF5F5F5),
                      child: child,
                    ),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
