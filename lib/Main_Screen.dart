import 'package:flutter/material.dart';
import 'User_ManagementTenant.dart';
import 'User_ManagementLandlord.dart';
import 'Dashboard_Screen.dart';
import 'Properties_Management.dart';
import 'Analytics_Managenent.dart';
import 'Settings_Screen.dart';
import 'login.dart';
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
  // Current route management
  late String _currentRoute;
  final Duration _transitionDuration = const Duration(milliseconds: 300);
  bool _isMobileLayout = false; // Track current layout

  // Route to content mapping
  final Map<String, Widget> _routeContentMap = {
    '/dashboard':  DashboardScreen(),
    '/users-tenant':  UserManagementTenant(),
    '/users-landlord':  UserManagementLandlord(),
    '/properties-management':  PropertiesManagementScreen(),
    '/analytics':  AnalyticsScreen(),
    '/settings':  SettingsScreen(),
  };

  @override
  void initState() {
    super.initState();
    // Set initial route
    _currentRoute = widget.initialRoute;

    if (kIsWeb) {
      // Set initial route from URL hash only if valid
      final hash = html.window.location.hash;
      final initialHashRoute = hash.isNotEmpty ? hash.replaceFirst('#', '') : null;
      if (_routeContentMap.containsKey(initialHashRoute)) {
        _currentRoute = initialHashRoute!;
      }
      // Sync URL with initial route
      html.window.history.replaceState(null, '', '#$_currentRoute');
      print('Init: _currentRoute=$_currentRoute, Hash=${html.window.location.hash}');
    }
  }

  @override
  void didUpdateWidget(MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update current route if initialRoute changed from parent
    if (widget.initialRoute != oldWidget.initialRoute) {
      setState(() {
        _currentRoute = widget.initialRoute;
        if (kIsWeb) {
          html.window.history.replaceState(null, '', '#$_currentRoute');
          print('didUpdateWidget: _currentRoute=$_currentRoute, Hash=${html.window.location.hash}');
        }
      });
    }
  }

  Widget _getCurrentContent() {
    return _routeContentMap[_currentRoute] ??  DashboardScreen();
  }

  // Handle navigation for Routes links
  void _handleNavigation(String route) {
    if (_currentRoute != route && _routeContentMap.containsKey(route)) {
      print('Navigating to: $route, Current: $_currentRoute, Hash: ${kIsWeb ? html.window.location.hash : 'N/A'}');
      setState(() {
        _currentRoute = route;
      });

      // Update the URL if running on web
      if (kIsWeb) {
        html.window.history.pushState(null, '', '#$route');
        print('Updated Hash: ${html.window.location.hash}');
      }

      // Close drawer if in mobile layout
      if (_isMobileLayout && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(); // Close the drawer
      }
    }
  }

  // Handle logout
  void _handleLogout() async {
    print('Logout triggered');
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
            // Sync URL on layout change
            if (_isMobileLayout != isMobile) {
              _isMobileLayout = isMobile;
              if (kIsWeb) {
                html.window.history.replaceState(null, '', '#$_currentRoute');
                print('Layout changed to ${isMobile ? 'mobile' : 'desktop'}, _currentRoute=$_currentRoute, Hash=${html.window.location.hash}');
              }
            }
            print('Build: _currentRoute=$_currentRoute, IsMobile=$isMobile');
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
        child: Container(
          color: const Color(0xFF4A758F),
          child: Sidebar(
            currentRoute: _currentRoute,
            onNavigation: _handleNavigation,
            parentContext: context,
            onLogout: _handleLogout,
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: _transitionDuration,
        switchInCurve: Curves.easeIn,
        switchOutCurve: Curves.easeOut,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _getCurrentContent(),
        key: ValueKey(_currentRoute),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        Container(
          width: 220,
          color: const Color(0xFF4A758F),
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
            child: AnimatedSwitcher(
              duration: _transitionDuration,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _getCurrentContent(),
              key: ValueKey(_currentRoute),
            ),
          ),
        ),
      ],
    );
  }
}