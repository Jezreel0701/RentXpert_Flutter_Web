import 'package:flutter/material.dart';
import 'User_ManagementTenant.dart';
import 'User_ManagementLandlord.dart';
import 'Dashboard_Screen.dart';
import 'Properties_Management.dart';
import 'Analytics_Managenent.dart';
import 'Settings_Screen.dart';
import 'Sidebar.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;
import 'package:shared_preferences/shared_preferences.dart';

class MainScreen extends StatefulWidget {
  final String initialRoute;
  const MainScreen({Key? key, this.initialRoute = '/dashboard'}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late String _currentRoute;
  final Duration _transitionDuration = const Duration(milliseconds: 300);
  bool _isMobileLayout = false;
  bool _isProgrammaticNavigation = false;

  final Map<String, Widget> _routeContentMap = {
    '/dashboard': DashboardScreen(),
    '/users-tenant': UserManagementTenant(),
    '/users-landlord': UserManagementLandlord(),
    '/properties-management': PropertiesManagementScreen(),
    '/analytics': AnalyticsScreen(),
    '/settings': SettingsScreen(),
  };

  @override
  void initState() {
    super.initState();

    if (kIsWeb) {
      // First get the current hash from the URL
      final hash = html.window.location.hash;
      final initialHashRoute = hash.isNotEmpty ? hash.replaceFirst('#', '') : null;

      // Prioritize the URL hash over the widget's initialRoute
      _currentRoute = initialHashRoute ?? widget.initialRoute;

      // Ensure the route exists in our map, fallback to dashboard
      if (!_routeContentMap.containsKey(_currentRoute)) {
        _currentRoute = '/dashboard';
      }

      // Update the URL to match our validated route
      _updateUrlHash(_currentRoute);

      // Set up hash change listener
      html.window.onHashChange.listen((event) {
        if (!_isProgrammaticNavigation) {
          _handleHashChange();
        }
      });
    } else {
      _currentRoute = widget.initialRoute;
    }
  }

  void _handleHashChange() {
    final newHash = html.window.location.hash;
    final newRoute = newHash.isNotEmpty ? newHash.replaceFirst('#', '') : '/dashboard';

    if (_routeContentMap.containsKey(newRoute)){
    if (_currentRoute != newRoute) {
    setState(() {
    _currentRoute = newRoute;
    });
    }
    } else {
    // If the route is invalid, redirect to dashboard and update URL
    _updateUrlHash('/dashboard');
    }
    }

  void _updateUrlHash(String route) {
    if (kIsWeb) {
      _isProgrammaticNavigation = true;
      html.window.history.replaceState(null, '', '#$route');
      _isProgrammaticNavigation = false;
    }
  }

  @override
  void didUpdateWidget(MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialRoute != oldWidget.initialRoute && !kIsWeb) {
      setState(() {
        _currentRoute = widget.initialRoute;
      });
    }
  }

  Widget _getCurrentContent() {
    return _routeContentMap[_currentRoute] ?? DashboardScreen();
  }

  void _handleNavigation(String route) {
    if (_currentRoute != route && _routeContentMap.containsKey(route)) {
      setState(() {
        _currentRoute = route;
      });

      if (kIsWeb) {
        _updateUrlHash(route);
      }

      if (_isMobileLayout && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }

  void _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: ValueKey(_currentRoute),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 1000;
            if (_isMobileLayout != isMobile) {
              _isMobileLayout = isMobile;
              if (kIsWeb && html.window.location.hash != '#$_currentRoute') {
                _updateUrlHash(_currentRoute);
              }
            }
            return isMobile ? _buildMobileLayout() : _buildDesktopLayout();
          },
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF4A758F),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: Sidebar(
          currentRoute: _currentRoute,
          onNavigation: _handleNavigation,
          parentContext: context,
          onLogout: _handleLogout,
        ),
      ),
      body: _getCurrentContent(),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        SizedBox(
          width: 220,
          child: Sidebar(
            currentRoute: _currentRoute,
            onNavigation: _handleNavigation,
            parentContext: context,
            onLogout: _handleLogout,
          ),
        ),
        Expanded(
          child: Container(
            color: const Color(0xFFF5F5F5),
            child: _getCurrentContent(),
          ),
        ),
      ],
    );
  }
}