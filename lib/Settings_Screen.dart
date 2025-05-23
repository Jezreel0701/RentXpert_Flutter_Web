import 'package:flutter/material.dart';
import 'package:rentxpert_flutter_web/service/api.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedPage = 'Account';
  String _hoveredPage = '';
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _showSaveTopSnackBar(String message, {bool isError = false}) {
    final overlay = Overlay.of(context);
    final color = isError ? Colors.red : Colors.green;
    final screenSize = MediaQuery.of(context).size;
    const double snackbarWidth = 800;
    const double snackbarHeight = 80;

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: MediaQuery.of(context).size.width / 2 - 150,
        right: MediaQuery.of(context).size.width / 2 - 150,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () => overlayEntry.remove());
  }

  bool _validateInputs(String email, String password) {
    final emailValid = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    final passwordValid = password.length >= 8;

    if (!emailValid) {
      _showSaveTopSnackBar("Please enter a valid email", isError: true);
      return false;
    }

    if (!passwordValid) {
      _showSaveTopSnackBar("Password must be at least 8 characters", isError: true);
      return false;
    }

    return true;
  }

  Future<void> _saveAccount() async {
    final newEmail = _emailController.text.trim();
    final newPassword = _passwordController.text.trim();

    if (!_validateInputs(newEmail, newPassword)) return;

    setState(() => _isLoading = true);

    try {
      final success = await AdminApiService.updateAdminCredentials(
        newEmail: newEmail,
        newPassword: newPassword,
      );

      if (success) {
        _showSaveTopSnackBar("Account successfully saved!");
        _emailController.clear();
        _passwordController.clear();
      } else {
        _showSaveTopSnackBar("Failed to update credentials", isError: true);
      }
    } catch (e) {
      _showSaveTopSnackBar(e.toString(), isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : const Color(0xFFF5F5F5),
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
                color: isDarkMode ? Colors.white : const Color(0xFF4F768E),
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
                    height: 900,
                    width: screenWidth * 0.18,
                    margin: const EdgeInsets.only(right: 30),
                    decoration: BoxDecoration(
                      color: isDarkMode ? Colors.grey[800] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 50.0),
                            child: _buildSidebarTile("Account", Icons.verified_user),
                          ),
                          _buildSidebarTile("Notifications", Icons.notifications_active),
                        ],
                      ),
                    ),
                  ),
                  // Main Content: Account
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double containerWidth = constraints.maxWidth > 900 ? 800 : constraints.maxWidth * 5;
                        return Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: containerWidth,
                            constraints: BoxConstraints(
                                minHeight: 350,
                                maxHeight: MediaQuery.of(context).size.height * 5),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: isDarkMode ? Colors.grey[800] : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                            ),
                            child: _selectedPage == 'Account'
                                ? _buildAccountPage()
                                : _buildNotificationPage(),
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isSelected = _selectedPage == title;
    bool isHovered = _hoveredPage == title;
    double screenWidth = MediaQuery.of(context).size.width;
    final isDarkMode = themeProvider.isDarkMode;

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
                ? isDarkMode ? Colors.grey[700] : Color(0xFFD7E4ED)
                : isHovered
                ? isDarkMode ? Colors.grey[700] : Color(0xFFD7E4ED)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, color: isDarkMode ? Colors.white : Colors.black87),
              if (screenWidth > 600) const SizedBox(width: 10),
              if (screenWidth > 1100)
                Flexible(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }


  //Profile page
  // Inside _buildAccountPage
  Widget _buildAccountPage() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Account",
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Color(0xFF4B6C81),
                  fontFamily: "Krub",
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(thickness: 1),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  "My Profile",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Color(0xFF4B6C81),
                    fontFamily: "Krub",
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: AssetImage('assets/images/admin_icon.png'),
                    ),
                    const SizedBox(width: 12),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SwitchListTile(
                title: Text(
                  'Dark Mode',
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
                value: isDarkMode,
                onChanged: (bool value) {
                  themeProvider.toggleTheme();
                },
              ),
              const SizedBox(height: 20),
              // Email and Password fields stacked vertically
             Row(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
                 Expanded(
                   child: _responsiveInput(
                     "Email",
                     controller: _emailController,
                   ),
                 ),
                 const SizedBox(width: 16), // Add spacing between the fields
                 Expanded(
                   child: _responsiveInput(
                     "Password",
                     controller: _passwordController,
                     obscureText: true,
                     showVisibilityToggle: true,
                   ),
                 ),
               ],
             ),
              const SizedBox(height: 20),
              const Divider(thickness: 1),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 24.0),
                child: SizedBox(
                  width: 170,
                  height: 43,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF4A758F),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                      "Save",
                      style: TextStyle(
                        fontSize: 16,
                        fontFamily: "Krub",
                        fontWeight: FontWeight.w300,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// Modified _responsiveInput
  Widget _responsiveInput(
      String label, {
        required TextEditingController controller,
        bool obscureText = false,
        bool showVisibilityToggle = false,
      }) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    bool _obscureText = obscureText; // Local state for password visibility

    return Padding(
      padding: const EdgeInsets.only(left: 25.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 1 / 4,
        child: StatefulBuilder(
          builder: (context, setState) {
            return TextField(
              controller: controller,
              obscureText: _obscureText,
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF4A758F), width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1),
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                ),
                labelText: label,
                labelStyle: TextStyle(color: isDarkMode ? Colors.grey[400] : Color(0xFF848484)),
                fillColor: isDarkMode ? Colors.grey[700] : Colors.white,
                filled: true,
                suffixIcon: showVisibilityToggle
                    ? IconButton(
                  icon: Icon(
                    _obscureText ? Icons.visibility_off : Icons.visibility,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                )
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }


  //Notification page
  Widget _buildNotificationPage() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    // Sample notification data
    final notifications = [
      {
        'title': 'New Message',
        'message': 'You received a new message from John Doe.',
        'timestamp': '2h ago',
        'isRead': true,
      },
      {
        'title': 'Payment Received',
        'message': 'Your payment of \$500 has been processed.',
        'timestamp': '5h ago',
        'isRead': false,
      },
      {
        'title': 'System Update',
        'message': 'RentXpert system will undergo maintenance tonight.',
        'timestamp': '1d ago',
        'isRead': false,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Notifications",
          style: TextStyle(
            color: isDarkMode ? Colors.white : const Color(0xFF4B6C81),
            fontFamily: "Krub",
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Divider(thickness: 1),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: notifications.map((notification) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.grey[800]
                          : Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isDarkMode
                              ? Colors.black54
                              : Colors.black12,
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(top: 5, right: 10),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: notification['isRead'] as bool
                                ? Colors.grey
                                : const Color(0xFF4A758F),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification['title'] as String,
                                style: TextStyle(
                                  fontFamily: "Krub",
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: isDarkMode
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notification['message'] as String,
                                style: TextStyle(
                                  fontFamily: "Krub",
                                  fontSize: 14,
                                  color: isDarkMode
                                      ? Colors.grey[300]
                                      : Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                notification['timestamp'] as String,
                                style: TextStyle(
                                  fontFamily: "Krub",
                                  fontSize: 12,
                                  color: isDarkMode
                                      ? Colors.grey[400]
                                      : Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}