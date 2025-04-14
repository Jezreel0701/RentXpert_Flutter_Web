import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedPage = 'Account';
  String _hoveredPage = '';

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
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
                color: Color(0xFF4F768E),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 10),
                      ],
                    ),

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 50.0), // <-- Add top padding here
                          child: _buildSidebarTile("Account", Icons.settings),
                        ),
                        _buildSidebarTile("User Permission", Icons.info_outline),

                      ],
                    ),


                  ),

                  // Main Content: Account
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double containerWidth = constraints.maxWidth > 900
                            ? 800
                            : constraints.maxWidth * 5;

                        return Center(
                          child: Container(
                            width: containerWidth,
                            constraints: BoxConstraints(
                              minHeight: 900,
                              maxHeight: MediaQuery.of(context).size.height * 5,
                            ),

                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
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
                ? const Color(0xFFD7E2F0)
                : isHovered
                ? const Color(0xFFE6EDF6)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.black87),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildAccountPage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Account",
                  style: TextStyle(
                      color: Color(0xFF4B6C81),
                  fontFamily: "Krub",
                  fontSize: 25,
                  fontWeight: FontWeight.bold)),
              const Divider(thickness: 1),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 24.0),
                child: Text(
                  "My Profile",
                  style: TextStyle(
                    color: Color(0xFF4B6C81),
                    fontFamily: "Krub",
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                  ),

                  const SizedBox(width: 12),

                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFD7E2F0),
                      foregroundColor: Colors.black,
                      elevation: 0,
                    ),
                    onPressed: () {},
                    label: Text("Edit"),
                    icon: Icon(Icons.edit, size: 16),
                  )
                ],
              ),

              const SizedBox(height: 24),
              // Wrap for 2 per row
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _responsiveInput("First Name"),
                  _responsiveInput("Last Name"),
                  _responsiveInput("Phone Number"),
                  _responsiveInput("Email Address"),
                  _responsiveInput("Birth of Date"),
                  _responsiveInput("Password", obscureText: true),
                ],
              ),
              const SizedBox(height: 32),
              Align(
                alignment: Alignment.centerLeft,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text("Delete account"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _responsiveInput(String label, {bool obscureText = false}) {
    return SizedBox(
      width: 300, // Fixed width for 2-in-a-row layout
      child: TextField(
        obscureText: obscureText,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }


  Widget _buildUserPermissionPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text("User Permission", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Divider(thickness: 1),
        SizedBox(height: 16),
        Text("This is the User Permission page."),
      ],
    );
  }
}
