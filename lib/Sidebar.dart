import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth/auth_provider.dart'; // Import AuthService

class Sidebar extends StatefulWidget {
  final String currentRoute;
  final BuildContext parentContext;
  final VoidCallback? onLogout;
  final VoidCallback? onWebRefresh; // Callback to refresh dashboard

  const Sidebar({
    Key? key,
    required this.currentRoute,
    required this.parentContext,
    this.onLogout,
    this.onWebRefresh,
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
  bool isHoveredTransactions = false;
  final AuthService _authService = AuthService();

  bool get shouldKeepDropdownOpen {
    return widget.currentRoute == '/users-tenant' ||
        widget.currentRoute == '/users-landlord';
  }

  Future<bool> _verifyToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('authToken');
      if (token == null) return false;

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        await prefs.remove('authToken');
        return false;
      }

// Optional: Add backend token verification
// bool isValid = await _authService.verifyToken(token);
// return isValid && user != null;
      return true;
    } catch (e) {
      print('Token verification error: $e');
      ScaffoldMessenger.of(widget.parentContext).showSnackBar(
        SnackBar(content: Text('Session verification failed: $e')),
      );
      return false;
    }
  }

  Future<void> _navigateWithTokenCheck(String route) async {
    bool isValid = await _verifyToken();
    if (!isValid) {
      GoRouter.of(widget.parentContext).go('/login');
      return;
    }

// Update dropdown state based on the route
    setState(() {
      if (route != '/users-tenant' && route != '/users-landlord') {
        isUserDropdownExpanded = false; // Close dropdown for non-users routes
        isDropdownLocked = false; // Unlock dropdown
      } else {
        isUserDropdownExpanded = true; // Keep dropdown open for users routes
        isDropdownLocked = true; // Lock dropdown open
      }
    });

    if (route == '/dashboard' && widget.onWebRefresh != null) {
      widget.onWebRefresh!(); // Trigger dashboard refresh
    }
    GoRouter.of(widget.parentContext).go(route);
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
                  onTap: () => _navigateWithTokenCheck('/dashboard'),
                  child:
                      Image.asset("assets/images/white_logo.png", height: 120),
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
        onTap: () => _navigateWithTokenCheck('/properties-management'),
        isSelected: widget.currentRoute == '/properties-management',
      ),
      _buildSidebarTile(
        iconPath: "assets/images/analytics.png",
        title: "Analytics",
        isHovered: isHoveredAnalytics,
        onHoverChange: (val) => setState(() => isHoveredAnalytics = val),
        onTap: () => _navigateWithTokenCheck('/analytics'),
        isSelected: widget.currentRoute == '/analytics',
      ),
      // Add this new transaction item
      // _buildSidebarTile(
      //   iconPath: "assets/images/transactions.png",
      //   title: "Transactions",
      //   isHovered: isHoveredTransactions,
      //   onHoverChange: (val) => setState(() => isHoveredTransactions = val),
      //   onTap: () => _navigateWithTokenCheck('/transactions'),
      //   isSelected: widget.currentRoute == '/transactions',
      // ),
      _buildSidebarTile(
        iconPath: "assets/images/settings.png",
        title: "Settings",
        isHovered: isHoveredSettings,
        onHoverChange: (val) => setState(() => isHoveredSettings = val),
        onTap: () => _navigateWithTokenCheck('/settings'),
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
                        color: isHoveredUsers
                            ? const Color(0xFFF9E9B6)
                            : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Users Management",
                      style: TextStyle(
                        color: isHoveredUsers
                            ? const Color(0xFFF9E9B6)
                            : Colors.white,
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
            onTap: () {
              setState(() {
                isUserDropdownExpanded = true; // Open dropdown on click
                isDropdownLocked = true; // Lock dropdown open
              });
            },
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
          const Center(
            child: SizedBox(
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
    bool isHovered =
        route == '/users-tenant' ? isHoveredTenant : isHoveredLandlord;

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
          setState(() {
            isUserDropdownExpanded = true; // Keep dropdown open
            isDropdownLocked = true; // Lock dropdown
          });
          _navigateWithTokenCheck(route); // Navigate to the route
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: TextStyle(
              color: isActive || isHovered
                  ? const Color(0xFFF9E9B6)
                  : Colors.white70,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
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
                        color: isHovered || isSelected
                            ? const Color(0xFFF9E9B6)
                            : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: isHovered || isSelected
                            ? const Color(0xFFF9E9B6)
                            : Colors.white,
                        fontWeight: FontWeight.w300,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: isHovered || isSelected
                        ? const Color(0xFFF9E9B6)
                        : Colors.white,
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
    final isDarkMode =
        Theme.of(widget.parentContext).brightness == Brightness.dark;

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
                        backgroundColor: isDarkMode
                            ? Colors.grey[700]
                            : const Color(0xFF4A758F),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                            color: isDarkMode ? Colors.black : Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 120,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 4,
                        backgroundColor: isDarkMode
                            ? Colors.red[400]
                            : const Color(0xFFDE5959),
                      ),
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.remove('authToken');
                        if (mounted) {
                          Navigator.of(context).pop();
                          GoRouter.of(context).go('/login');
                        }
                      },
                      child: Text(
                        'Log Out',
                        style: TextStyle(
                            color: isDarkMode ? Colors.black : Colors.white),
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