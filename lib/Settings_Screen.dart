import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedPage = 'Account';
  String _hoveredPage = '';
  bool _isDarkMode = false; // State for Dark Mode

  void _toggleDarkMode() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: _isDarkMode ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Settings",
              style: TextStyle(
                fontSize: 45,
                fontFamily: "Inter",
                color: _isDarkMode ? Colors.white : const Color(0xFF4F768E),
                fontWeight: FontWeight.w600,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  // Sidebar
                  Container(
                    width: screenWidth * 0.18,
                    margin: const EdgeInsets.only(right: 30),
                    decoration: BoxDecoration(
                      color: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 10),
                      ],
                    ),
                    child: Column(
  mainAxisAlignment: MainAxisAlignment.start,
  children: [
    Padding(
      padding: const EdgeInsets.only(top: 50.0),
      child: _buildSidebarTile("Account", Icons.verified_user),
    ),
    _buildSidebarTile("User Permission", Icons.settings),
    const SizedBox(height: 20),
    // Dark Mode Toggle with adjustable spacing
    SwitchListTile(
      title: Row(
        children: [
          Text(
            "Dark Mode",
            style: TextStyle(
              color: _isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 5), // Adjustable spacing between text and switch
        ],
      ),
      value: _isDarkMode,
      onChanged: (value) => _toggleDarkMode(),
      activeColor: const Color(0xFF4A758F),
    ),
  ],
),
                  ),

                  // Main Content
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double containerWidth = constraints.maxWidth > 900
                            ? 800
                            : constraints.maxWidth * 5;

                        return Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: containerWidth,
                            constraints: BoxConstraints(
                              minHeight: 350,
                              maxHeight: MediaQuery.of(context).size.height * 5,
                            ),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 10),
                              ],
                            ),
                            child: _selectedPage == 'Account'
                                ? _buildAccountPage()
                                : _buildUserPermissionPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarTile(String title, IconData icon) {
    bool isSelected = _selectedPage == title;
    bool isHovered = _hoveredPage == title;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredPage = title),
      onExit: (_) => setState(() => _hoveredPage = ''),
      child: GestureDetector(
        onTap: () => setState(() => _selectedPage = title),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? (_isDarkMode ? const Color(0xFF2E2E2E) : const Color(0xFFD7E4ED))
                : isHovered
                    ? (_isDarkMode ? const Color(0xFF2E2E2E) : const Color(0xFFD7E4ED))
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, color: _isDarkMode ? Colors.white : Colors.black),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  title,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Account",
          style: TextStyle(
            color: _isDarkMode ? Colors.white : const Color(0xFF4B6C81),
            fontFamily: "Krub",
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(thickness: 1),
        const SizedBox(height: 8),
        Text(
          "My Profile",
          style: TextStyle(
            color: _isDarkMode ? Colors.white : const Color(0xFF4B6C81),
            fontFamily: "Krub",
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: CircleAvatar(
            radius: 35,
            backgroundImage: NetworkImage('https://via.placeholder.com/150'),
          ),
        ),
        const SizedBox(height: 24),
        _responsiveInput("Username"),
        const SizedBox(height: 16),
        _responsiveInput("Password", obscureText: true),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: _showDeleteConfirmationDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD24E4E),
              ),
              child: Text(
                "Delete Account",
                style: TextStyle(
                  color: Colors.white, // Always white for both modes
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _saveAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A758F),
              ),
              child: Text(
                "Save",
                style: TextStyle(
                  color: Colors.white, // Always white for both modes
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _responsiveInput(String label, {bool obscureText = false}) {
    return TextField(
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: _isDarkMode ? Colors.white70 : const Color(0xFF848484),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: _isDarkMode ? Colors.white70 : Colors.grey,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: _isDarkMode ? Colors.white : const Color(0xFF4A758F),
          ),
        ),
      ),
    );
  }

  Widget _buildUserPermissionPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "User Permission",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _isDarkMode ? Colors.white : Colors.black,
          ),
        ),
        const Divider(thickness: 1),
        const SizedBox(height: 16),
        Text(
          "This is the User Permission page.",
          style: TextStyle(
            color: _isDarkMode ? Colors.white70 : Colors.black87,
          ),
        ),
      ],
    );
  }
}

void _saveAccount() {
  // Add your save account logic here
  print("Account saved!");
}

void _showDeleteConfirmationDialog() {
  var context;
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("Are you sure you want to delete your account? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              // Add your delete account logic here
              Navigator.of(context).pop();
            },
            child: const Text("Delete"),
          ),
        ],
      );
    },
  );
}