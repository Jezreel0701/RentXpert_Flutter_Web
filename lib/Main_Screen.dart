import 'package:flutter/material.dart';
import 'User_ManagementTenant.dart';
import 'User_ManagementLandlord.dart';
import 'Dashboard_Screen.dart';
import 'Properties_Management.dart';
import 'Analytics_Managenent.dart';
import 'Settings_Screen.dart';
import 'login.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();

}

class _MainScreenState extends State<MainScreen> {
  bool isHoveredDashboard = false;
  bool isHoveredUsers = false;
  bool isHoveredProperties = false;
  bool isHoveredAnalytics = false;
  bool isHoveredSettings = false;
  bool isHoveredLogout = false;

  bool isUserDropdownExpanded = false;
  bool isHoveredTenant = false;
  bool isHoveredLandlord = false;

  // Index: 0 - Dashboard, 1 - Tenant, 2 - Landlord, 3 - Properties, 4 - Analytics, 5 - Settings, 6 - Logout
  int _selectedIndex = 0;

// logout pop-up function
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
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
              const Text(
                'Are you sure you want to log out?',
                style: TextStyle(
                    fontSize: 20,
                    fontFamily: "Krub",
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: 120, // Adjust the width here
                    height: 50, // Adjust the height here
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 4,
                        backgroundColor: Color(0xFF4A758F),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: const Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 120, // Adjust the width here
                    height: 50, // Adjust the height here
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 4,
                        backgroundColor: Color(0xFFDE5959),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        // setState(() {
                        //   _selectedIndex = 6; // Navigate to logout screen
                        // });
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Login()),
                        );
                      },
                      child: const Text(
                          'Log Out',
                        style: TextStyle(color: Colors.white)),
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

  final List<Widget> _screens = [
    DashboardScreen(),
    UserManagementTenant(), // Tenant
    UserManagementLandlord(), // Landlord (can use different screen)
    PropertiesManagementScreen(),
    AnalyticsScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            bool isMobile = constraints.maxWidth < 1000;

            return isMobile
                ? Scaffold(
              appBar: AppBar(
                backgroundColor: Color(0xFF4A758F),
                leading: Builder(
                  builder: (context) => IconButton(
                    icon: Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                ),
              ),
              drawer: Drawer(
                child: Container(
                  color: Color(0xFF4A758F),
                  child: Column(
                    children: [
                      DrawerHeader(
                        child: Image.asset(
                          "assets/images/white_logo.png",
                          height: 120,
                          fit: BoxFit.contain,
                        ),
                      ),
                      ..._buildSidebarItems(),
                    ],
                  ),
                ),
              ),
              body: _screens[_selectedIndex],
            )
                : Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Container(
                    color: Color(0xFF4A758F),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 30),
                          alignment: Alignment.center,
                          child: Column(
                            children: [
                              Image.asset(
                                "assets/images/white_logo.png",
                                height: 120,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(
                                width: 220,
                                child: Divider(
                                  color: Colors.white,
                                  thickness: 1,
                                  height: 40,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ..._buildSidebarItems(),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Container(
                    color: Color(0xFFF5F5F5),
                    child: _screens[_selectedIndex],
                  ),
                ),
              ],
            );
          },
        ),
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
        onTap: () => setState(() => _selectedIndex = 0),
        isSelected: _selectedIndex == 0,
      ),
      _buildUsersDropdown(),
      _buildSidebarTile(
        iconPath: "assets/images/properties.png",
        title: "Properties Management",
        isHovered: isHoveredProperties,
        onHoverChange: (val) => setState(() => isHoveredProperties = val),
        onTap: () => setState(() => _selectedIndex = 3),
        isSelected: _selectedIndex == 3,
      ),
      _buildSidebarTile(
        iconPath: "assets/images/analytics.png",
        title: "Reports & Analytics",
        isHovered: isHoveredAnalytics,
        onHoverChange: (val) => setState(() => isHoveredAnalytics = val),
        onTap: () => setState(() => _selectedIndex = 4),
        isSelected: _selectedIndex == 4,
      ),
      _buildSidebarTile(
        iconPath: "assets/images/settings.png",
        title: "Settings",
        isHovered: isHoveredSettings,
        onHoverChange: (val) => setState(() => isHoveredSettings = val),
        onTap: () => setState(() => _selectedIndex = 5),
        isSelected: _selectedIndex == 5,
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
    return Column(
      children: [
        ListTile(
          title: MouseRegion(
            onEnter: (_) => setState(() => isHoveredUsers = true),
            onExit: (_) => setState(() => isHoveredUsers = false),
            child: GestureDetector(
              onTap: () => setState(() => isUserDropdownExpanded = !isUserDropdownExpanded),
              child: Row(
                children: [
                  Transform.translate(
                    offset: Offset(5, -1),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: Image.asset(
                        "assets/images/user.png",
                        color: isHoveredUsers ? Color(0xFFF9E9B6) : Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Users Management",
                      style: TextStyle(
                        color: isHoveredUsers ? Color(0xFFF9E9B6) : Colors.white,
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
                    color: isHoveredUsers ? Color(0xFFF9E9B6) : Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (isUserDropdownExpanded)
          Padding(
            padding: const EdgeInsets.only(left: 40),
            child: Column(
              children: [
                MouseRegion(
                  onEnter: (_) => setState(() => isHoveredTenant = true),
                  onExit: (_) => setState(() => isHoveredTenant = false),
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedIndex = 1; // Tenant screen
                     // isUserDropdownExpanded = false;
                    }),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        "Tenant",
                        style: TextStyle(
                          color: (_selectedIndex == 1 || isHoveredTenant)
                              ? Color(0xFFF9E9B6)
                              : Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                MouseRegion(
                  onEnter: (_) => setState(() => isHoveredLandlord = true),
                  onExit: (_) => setState(() => isHoveredLandlord = false),
                  child: GestureDetector(
                    onTap: () => setState(() {
                      _selectedIndex = 2; // Landlord screen
                      // isUserDropdownExpanded = false;
                    }),
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        "Landlord",
                        style: TextStyle(
                          color: (_selectedIndex == 2 || isHoveredLandlord)
                              ? Color(0xFFF9E9B6)
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
        const SizedBox(
          width: 220,
          child: Divider(color: Colors.white, thickness: 1),
        ),
      ],
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
        SizedBox(
          width: 220,
          child: Divider(color: Colors.white, thickness: 1),
        ),
      ],
    );
  }
}
