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

class MainScreen extends StatefulWidget {
  final String initialRoute;
  const MainScreen({Key? key, this.initialRoute = '/dashboard'}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  // Hover states
  bool isHoveredDashboard = false;
  bool isHoveredUsers = false;
  bool isHoveredProperties = false;
  bool isHoveredAnalytics = false;
  bool isHoveredSettings = false;
  bool isHoveredLogout = false;

  // Dropdown state
  bool isUserDropdownExpanded = false;
  bool isHoveredTenant = false;
  bool isHoveredLandlord = false;

  // Current route management
  late String _currentRoute;
  final Duration _transitionDuration = const Duration(milliseconds: 300);

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

    if (kIsWeb) {
      // Set initial route from URL hash
      final hash = html.window.location.hash;
      _currentRoute = hash.isNotEmpty ? hash.replaceFirst('#', '') : widget.initialRoute;

      // Listen for hash changes
      html.window.onHashChange.listen((event) {
        final newHash = html.window.location.hash;
        final newRoute = newHash.isNotEmpty ? newHash.replaceFirst('#', '') : '/dashboard';
        if (_currentRoute != newRoute) {
          setState(() {
            _currentRoute = newRoute;
          });
        }
      });
    } else {
      _currentRoute = widget.initialRoute;
    }
  }

  @override
  void didUpdateWidget(MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update current route if initialRoute changed from parent
    if (widget.initialRoute != oldWidget.initialRoute) {
      _currentRoute = widget.initialRoute;
    }
  }

  Widget _getCurrentContent() {
    return _routeContentMap[_currentRoute] ?? DashboardScreen();
  }

  // Handle navigation for Routes links
  void _handleNavigation(String route) {
    if (_currentRoute != route) {
      setState(() {
        _currentRoute = route;
      });

      // Update the URL if running on web
      if (kIsWeb) {
        html.window.history.pushState(null, '', '#$route');
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: ValueKey(_currentRoute), // Important for preserving state
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
            onPressed: () => Scaffold.of(context).openDrawer(), // Open the drawer
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
           color: const Color(0xFF4A758F), // Set the background color
          child: Sidebar(
            currentRoute: _currentRoute, // Pass the current route
            onNavigation: _handleNavigation, // Pass the navigation handler
            parentContext: context, // Pass the parent context
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
                begin: const Offset(0.1, 0), // Slide in from the right
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: _getCurrentContent(), // Ensure this changes based on _currentRoute
        key: ValueKey(_currentRoute), // Ensure the key updates with the route
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Sidebar implementation
        Container(
          width: 220, // Sidebar width
          color: const Color(0xFF4A758F), // Sidebar background color
          child: Sidebar(
            currentRoute: _currentRoute, // Pass the current route
            onNavigation: _handleNavigation, // Pass the navigation handler
            parentContext: context, // Pass the parent context
          ),
        ),

        // Main content area
        Expanded(
          child: Container(
            color: const Color(0xFFF5F5F5), // Main content background color
            child: AnimatedSwitcher(
              duration: _transitionDuration,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.1, 0), // Slide in from the right
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                );
              },
              child: _getCurrentContent(), // Display the current content
            ),
          ),
        ),
      ],
    );
  }
  List<Widget> _buildSidebarMenuItems() {
    return [
      _buildSidebarTile(
        iconPath: "assets/images/dashboard.png",
        title: "Dashboard",
        isHovered: isHoveredDashboard,
        onHoverChange: (val) => setState(() => isHoveredDashboard = val),
        onTap: () => _handleNavigation('/dashboard'),
        isSelected: _currentRoute == '/dashboard',
      ),
      _buildUsersDropdown(),
      _buildSidebarTile(
        iconPath: "assets/images/properties.png",
        title: "Properties Management",
        isHovered: isHoveredProperties,
        onHoverChange: (val) => setState(() => isHoveredProperties = val),
        onTap: () => _handleNavigation('/properties-management'),
        isSelected: _currentRoute == '/properties-management',
      ),
      _buildSidebarTile(
        iconPath: "assets/images/analytics.png",
        title: "Reports & Analytics",
        isHovered: isHoveredAnalytics,
        onHoverChange: (val) => setState(() => isHoveredAnalytics = val),
        onTap: () => _handleNavigation('/analytics'),
        isSelected: _currentRoute == '/analytics',
      ),
      _buildSidebarTile(
        iconPath: "assets/images/settings.png",
        title: "Settings",
        isHovered: isHoveredSettings,
        onHoverChange: (val) => setState(() => isHoveredSettings = val),
        onTap: () => _handleNavigation('/settings'),
        isSelected: _currentRoute == '/settings',
      ),
      Sidebar(
        currentRoute: _currentRoute, // Pass the current route
        onNavigation: _handleNavigation, // Pass the navigation handler
        parentContext: context, // Pass the parent context
      ),
    ];
  }

  Widget _buildUsersDropdown() {
    return MouseRegion(
      onEnter: (_) => setState(() => isUserDropdownExpanded = true),
      onExit: (_) => setState(() => isUserDropdownExpanded = false),
      child: Column(
        children: [
          ListTile(
            title: Row(
              children: [
                Transform.translate(
                  offset: Offset(5, -1),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: Image.asset(
                      "assets/images/user.png",
                      color: isHoveredUsers ? const Color(0xFFF9E9B6) : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Users Management",
                    style: TextStyle(
                      color: isHoveredUsers ? const Color(0xFFF9E9B6) : Colors.white,
                      fontWeight: FontWeight.w300,
                      fontSize: 13,
                    ),
                  ),
                ),
                Icon(
                  isUserDropdownExpanded
                      ? Icons.keyboard_arrow_down
                      : Icons.arrow_forward_ios,
                  size: 12,
                  color: isHoveredUsers ? const Color(0xFFF9E9B6) : Colors.white,
                ),
              ],
            ),
          ),
          if (isUserDropdownExpanded)
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      _handleNavigation('/users-tenant');
                      setState(() => isUserDropdownExpanded = true);
                    },
                    child: MouseRegion(
                      onEnter: (_) => setState(() => isHoveredTenant = true),
                      onExit: (_) => setState(() => isHoveredTenant = false),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          "Tenant",
                          style: TextStyle(
                            color: (_currentRoute == '/users-tenant' || isHoveredTenant)
                                ? const Color(0xFFF9E9B6)
                                : Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _handleNavigation('/users-landlord');
                      setState(() => isUserDropdownExpanded = true);
                    },
                    child: MouseRegion(
                      onEnter: (_) => setState(() => isHoveredLandlord = true),
                      onExit: (_) => setState(() => isHoveredLandlord = false),
                      child: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Text(
                          "Landlord",
                          style: TextStyle(
                            color: (_currentRoute == '/users-landlord' || isHoveredLandlord)
                                ? const Color(0xFFF9E9B6)
                                : Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSidebarTile({
    required String iconPath,
    required String title,
    required bool isHovered,
    required Function(bool) onHoverChange,
    required VoidCallback onTap,
    required bool isSelected,
  }) {
    return Column(
      children: [
        ListTile(
          title: MouseRegion(
            onEnter: (_) => onHoverChange(true),
            onExit: (_) => onHoverChange(false),
            child: GestureDetector(
              onTap: onTap,
              child: Row(
                children: [
                  Transform.translate(
                    offset: Offset(5, -1),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: Image.asset(
                        iconPath,
                        color: isHovered || isSelected ? Color(0xFFF9E9B6) : Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: isHovered || isSelected ? Color(0xFFF9E9B6) : Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: isHovered || isSelected ? Color(0xFFF9E9B6) : Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}