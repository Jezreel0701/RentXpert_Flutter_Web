import 'package:flutter/material.dart';
import 'sidebar.dart';
import 'Dashboard_Screen.dart';
import 'User_ManagementTenant.dart';
import 'User_ManagementLandlord.dart';
import 'Properties_Management.dart';
import 'Analytics_Managenent.dart';
import 'Settings_Screen.dart';

class MainLayout extends StatefulWidget {
  final String initialRoute;
  final bool showSidebar;

  const MainLayout({
    super.key,
    required this.initialRoute,
    this.showSidebar = true,
  });

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  late String _currentRoute;
  final Map<String, Widget> _routeContentMap = {
    '/dashboard': DashboardScreen(),
    '/users-tenant': UserManagementTenant(),
    '/users-landlord': UserManagementLandlord(),
    '/properties': PropertiesManagementScreen(),
    '/analytics': AnalyticsScreen(),
    '/settings': SettingsScreen(),
  };

  @override
  void initState() {
    super.initState();
    _currentRoute = widget.initialRoute;
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

  void _handleNavigation(String route) {
    if (_currentRoute != route) {
      setState(() {
        _currentRoute = route;
      });

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => MainLayout(
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
              return Scaffold(
                appBar: AppBar(
                  backgroundColor: const Color(0xFF4A758F),
                  leading: widget.showSidebar
                      ? Builder(
                    builder: (context) => IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: () => Scaffold.of(context).openDrawer(),
                    ),
                  )
                      : null,
                ),
                drawer: widget.showSidebar
                    ? Sidebar(
                  currentRoute: _currentRoute,
                  onNavigation: _handleNavigation,
                  parentContext: context,
                )
                    : null,
                body: _getCurrentContent(),
              );
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