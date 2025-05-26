import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'Sidebar.dart';
import 'Dashboard_Screen.dart';
import 'User_ManagementTenant.dart';
import 'User_ManagementLandlord.dart';
import 'Properties_Management.dart';
import 'Analytics_Managenent.dart';
import 'Settings_Screen.dart';
import 'Main_Screen.dart';

class Routes extends StatelessWidget {
  final bool showSidebar;

  const Routes({
    super.key,
    this.showSidebar = true,
  });

  @override
  Widget build(BuildContext context) {
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
                  if (showSidebar)
                    Container(
                      width: 220,
                      color: const Color(0xFF4A758F),
                      child: Sidebar(
                        currentRoute: GoRouterState.of(context).matchedLocation,
                        parentContext: context,
                      ),
                    ),
                  Expanded(
                    child: Container(
                      color: const Color(0xFFF5F5F5),
                      child: _getCurrentContent(context),
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

  Widget _getCurrentContent(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    switch (location) {
      case '/dashboard':
        return  DashboardScreen();
      case '/users-tenant':
        return  UserManagementTenant();
      case '/users-landlord':
        return  UserManagementLandlord();
      case '/properties-management':
        return  PropertiesManagementScreen();
      case '/analytics':
        return const AnalyticsScreen();
      case '/settings':
        return  SettingsScreen();
      default:
        return  DashboardScreen();
    }
  }
}