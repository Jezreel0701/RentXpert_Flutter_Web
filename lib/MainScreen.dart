import 'package:flutter/material.dart';
import 'Dashboard_Screen.dart';
import 'User_ManagementTenant.dart';
import 'User_ManagementLandlord.dart';
import 'Properties_Management.dart';
import 'Analytics_Managenent.dart';
import 'Settings_Screen.dart';
import 'sidebar.dart';

class Mainscreen extends StatefulWidget {
  const Mainscreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<Mainscreen> {
  // Current route management
  String _currentRoute = '/dashboard';

  // Route to content mapping
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolveInitialRoute();
    });
  }

  void _resolveInitialRoute() {
    final routeName = ModalRoute.of(context)?.settings.name;
    if (routeName != null && routeName != '/') {
      setState(() {
        _currentRoute = routeName;
      });
    }
  }

  Widget _getCurrentContent() {
    return _routeContentMap[_currentRoute] ?? DashboardScreen();
  }

  void _handleNavigation(String route) {
    if (_currentRoute != route) {
      setState(() {
        _currentRoute = route;
      });

      // Update the URL in the navigation stack
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => Mainscreen(),
          settings: RouteSettings(name: route),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 1000;
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
      drawer: _buildSidebar(),
      body: _getCurrentContent(),
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
          ),
        ),
        Expanded(
          flex: 5,
          child: Container(
            color: const Color(0xFFF5F5F5),
            child: _getCurrentContent(),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    return Sidebar(
      currentRoute: _currentRoute,
      onNavigation: _handleNavigation,
      parentContext: context,
    );
  }
}