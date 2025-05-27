import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:go_router/go_router.dart';
import 'dart:html' as html;

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
            return FutureBuilder<bool>(
              future: _checkLogin(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Scaffold(body: Center(child: CircularProgressIndicator()));
                }
                if (!snapshot.data!) return Login();
                return ScaffoldWithSidebar(child: child);
              },
            );
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
        final isLoggedIn = await _checkLogin();
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
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          title: 'Admin RentXpert',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Krub-Regular',
          ),
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          routerConfig: _buildRouter(isLoggedIn),
        );
      },
    );
  }
}

class ScaffoldWithSidebar extends StatelessWidget {
  final Widget child;

  const ScaffoldWithSidebar({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 1000;

            if (isMobile) {
              return MainScreen();
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
                      color: const Color(0xFFF5F5F5),
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

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(ThemeProvider themeProvider) {
    notifyListeners();
    themeProvider.addListener(notifyListeners);
  }
}