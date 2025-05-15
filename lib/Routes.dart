import 'package:flutter/material.dart';
import 'Sidebar.dart';
import 'Dashboard_Screen.dart';
import 'User_ManagementTenant.dart';
import 'User_ManagementLandlord.dart';
import 'Properties_Management.dart';
import 'Analytics_Managenent.dart';
import 'Settings_Screen.dart';
import 'Main_Screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html; // Only for web


class Routes extends StatefulWidget {
  final String initialRoute;
  final bool showSidebar;

  const Routes({
    super.key,
    required this.initialRoute,
    this.showSidebar = true,
  });

  @override
  State<Routes> createState() => _RoutesState();
}

class _RoutesState extends State<Routes> {
  late String _currentRoute;
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
    _currentRoute = widget.initialRoute;

    // Add web-specific listeners
    if (kIsWeb) {
      html.window.onPopState.listen((event) {
        final newRoute = html.window.location.hash.replaceFirst('#', '');
        if (newRoute.isNotEmpty && newRoute != _currentRoute) {
          setState(() => _currentRoute = newRoute);
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveInitialRoute();
  }

  void _resolveInitialRoute() {
    final routeName = ModalRoute.of(context)?.settings.name;
    if (routeName != null && routeName != '/' && routeName != _currentRoute) {
      setState(() {
        _currentRoute = routeName;
      });
    }
  }
  // Handle navigation for Routes links
  void _handleNavigation(String route) {
    if (_currentRoute != route) {
      setState(() => _currentRoute = route);

      // For web: Force update the browser URL
      if (kIsWeb) {
        html.window.history.pushState(null, '', '#$route');
      }

      // For all platforms: Update the navigation stack
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => Routes(
            initialRoute: route,
            showSidebar: widget.showSidebar,
          ),
          settings: RouteSettings(name: route),
        ),
      );
    }
  }

  Widget _getCurrentContent() {
    return _routeContentMap[_currentRoute] ?? DashboardScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 1000;

            if (isMobile) {
              // Render MainScreen for mobile view
              return MainScreen();
            } else {
              return Row(
                children: [
                  if (widget.showSidebar)
                    Container(
                      width: 220,
                      color: const Color(0xFF4A758F),
                      child: Sidebar(
                        currentRoute: _currentRoute,
                        onNavigation: _handleNavigation,
                        parentContext: context,
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
          },
        ),
      ),
    );
  }
}
