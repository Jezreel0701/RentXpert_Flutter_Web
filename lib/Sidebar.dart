import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Sidebar extends StatefulWidget {
  final String currentRoute;
  final BuildContext parentContext;
  final VoidCallback? onLogout;

  const Sidebar({
    Key? key,
    required this.currentRoute,
    required this.parentContext,
    this.onLogout,
  }) : super(key: key);

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool isHoveredDashboard = false;
  bool isHoveredUsers = false;
  bool isHoveredProperties = false;
  bool isHoveredAnalytics = false;
  bool isHoveredSettings = false;
  bool isHoveredLogout = false;
  bool isUserDropdownExpanded = false;
  bool isHoveredTenant = false;
  bool isHoveredLandlord = false;
  bool isDropdownLocked = false;

  bool get shouldKeepDropdownOpen {
    return widget.currentRoute == '/users-tenant' ||
        widget.currentRoute == '/users-landlord';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF4A758F),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30),
            child: Column(
              children: [
                GestureDetector(
                  onTap: () => context.go('/dashboard'),
                  child: Image.asset("assets/images/white_logo.png", height: 120),
                )
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: _buildSidebarItems(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSidebarItems() {
    return [
      _buildSidebarTile(
        iconPath: "assets/images/dashboard.png",
        title: "Dashboard",
        isHovered: isHoveredDashboard,
        onHoverChange: (val) => setState(() => isHoveredDashboard = val),
        onTap: () => context.go('/dashboard'),
        isSelected: widget.currentRoute == '/dashboard',
      ),
      _buildUsersDropdown(),
      _buildSidebarTile(
        iconPath: "assets/images/properties.png",
        title: "Properties",
        isHovered: isHoveredProperties,
        onHoverChange: (val) => setState(() => isHoveredProperties = val),
        onTap: () => context.go('/properties-management'),
        isSelected: widget.currentRoute == '/properties-management',
      ),
      _buildSidebarTile(
        iconPath: "assets/images/analytics.png",
        title: "Analytics",
        isHovered: isHoveredAnalytics,
        onHoverChange: (val) => setState(() => isHoveredAnalytics = val),
        onTap: () => context.go('/analytics'),
        isSelected: widget.currentRoute == '/analytics',
      ),
      _buildSidebarTile(
        iconPath: "assets/images/settings.png",
        title: "Settings",
        isHovered: isHoveredSettings,
        onHoverChange: (val) => setState(() => isHoveredSettings = val),
        onTap: () => context.go('/settings'),
        isSelected: widget.currentRoute == '/settings',
      ),
      _buildSidebarTile(
        iconPath: "assets/images/logout.png",
        title: "Logout",
        isHovered: isHoveredLogout,
        onHoverChange: (val) => setState(() => isHoveredLogout = val),
        onTap: _showLogoutDialog,
        isSelected: false,
      ),
    ];
  }

  Widget _buildUsersDropdown() {
    return MouseRegion(
      onEnter: (_) => setState(() => isUserDropdownExpanded = true),
      onExit: (_) => setState(() {
        if (!isDropdownLocked && !shouldKeepDropdownOpen) {
          isUserDropdownExpanded = false;
        }
      }),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: MouseRegion(
              onEnter: (_) => setState(() => isHoveredUsers = true),
              onExit: (_) => setState(() => isHoveredUsers = false),
              child: Row(
                children: [
                  Transform.translate(
                    offset: const Offset(5, -1),
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
                    isUserDropdownExpanded || shouldKeepDropdownOpen
                        ? Icons.keyboard_arrow_down
                        : Icons.arrow_forward_ios,
                    size: 12,
                    color: isHoveredUsers ? const Color(0xFFF9E9B6) : Colors.white,
                  ),
                ],
              ),
            ),
          ),
          if (isUserDropdownExpanded || shouldKeepDropdownOpen)
            Padding(
              padding: const EdgeInsets.only(left: 40),
              child: Column(
                children: [
                  _buildDropdownItem("Tenant", '/users-tenant'),
                  _buildDropdownItem("Landlord", '/users-landlord'),
                ],
              ),
            ),
          Center(
            child: const SizedBox(
              width: 220,
              child: Divider(color: Colors.white, thickness: 1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownItem(String title, String route) {
    bool isActive = widget.currentRoute == route;
    bool isHovered = route == '/users-tenant' ? isHoveredTenant : isHoveredLandlord;

    return MouseRegion(
      onEnter: (_) => setState(() {
        if (route == '/users-tenant') isHoveredTenant = true;
        if (route == '/users-landlord') isHoveredLandlord = true;
      }),
      onExit: (_) => setState(() {
        if (route == '/users-tenant') isHoveredTenant = false;
        if (route == '/users-landlord') isHoveredLandlord = false;
      }),
      child: GestureDetector(
        onTap: () {
          context.go(route);
          setState(() {
            isUserDropdownExpanded = true;
            isDropdownLocked = true;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 2),
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: TextStyle(
              color: isActive || isHovered
                  ? const Color(0xFFF9E9B6)
                  : Colors.white70,
              fontSize: 12,
            ),
          ),
        ),
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
                    offset: const Offset(5, -1),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: Image.asset(
                        iconPath,
                        color: isHovered || isSelected ? const Color(0xFFF9E9B6) : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: isHovered || isSelected ? const Color(0xFFF9E9B6) : Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: isHovered || isSelected ? const Color(0xFFF9E9B6) : Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(
          width: 220,
          child: Divider(color: Colors.white, thickness: 1),
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    final isDarkMode = Theme.of(widget.parentContext).brightness == Brightness.dark;

    showDialog(
      context: widget.parentContext,
      builder: (context) => Dialog(
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 300,
          height: 180,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Are you sure you want to log out?',
                style: TextStyle(
                  fontSize: 20,
                  fontFamily: "Krub",
                  fontWeight: FontWeight.w600,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: 120,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 4,
                        backgroundColor: isDarkMode ? Colors.grey[700] : const Color(0xFF4A758F),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: isDarkMode ? Colors.black : Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 4,
                        backgroundColor: isDarkMode ? Colors.red[400] : const Color(0xFFDE5959),
                      ),
                      onPressed: () async {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('authToken');
                        if (mounted) {
                          Navigator.of(context).pop();
                          GoRouter.of(context).go('/login');
                        }
                      },
                      child: Text(
                        'Log Out',
                        style: TextStyle(color: isDarkMode ? Colors.black : Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}