import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:rentxpert_flutter_web/service/Firebase/Firebase_appNotification_model.dart';
import 'package:rentxpert_flutter_web/service/Firebase/chat_notification_service.dart';
import 'package:rentxpert_flutter_web/service/Firebase/firebase_service.dart';
import 'package:rentxpert_flutter_web/service/api.dart';
import 'package:provider/provider.dart';
import 'package:rentxpert_flutter_web/service/profileservice.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'theme_provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class SettingsScreen extends StatefulWidget {

  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedPage = 'Account';
  final TextEditingController _changePasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  final ProfileService profileService = ProfileService();

  @override
  void dispose() {
    _changePasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSaveTopSnackBar(String message, {bool isError = false}) {
    final overlay = Overlay.of(context);
    final color = isError ? Colors.red : Colors.green;

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

  bool _validateInputs(String changePassword, String confirmPassword) {
    final passwordValid = changePassword.length >= 8;
    final passwordsMatch = changePassword == confirmPassword;

    if (!passwordValid) {
      _showSaveTopSnackBar("Password must be at least 8 characters", isError: true);
      return false;
    }

    if (!passwordsMatch) {
      _showSaveTopSnackBar("Passwords do not match", isError: true);
      return false;
    }

    return true;
  }

  Future<void> _saveAccount() async {
    final newPassword = _changePasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (!_validateInputs(newPassword, confirmPassword)) return;

    setState(() => _isLoading = true);

    try {
      final success = await AdminApiService.updateAdminCredentials(
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );

      if (success) {
        _showSaveTopSnackBar("Password successfully changed!");
        _changePasswordController.clear();
        _confirmPasswordController.clear();
      } else {
        _showSaveTopSnackBar("Failed to update password", isError: true);
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
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  _buildSidebar(isDarkMode, screenWidth),
                  const SizedBox(width: 30),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          constraints: BoxConstraints(
                            maxHeight: MediaQuery.of(context).size.height,
                          ),
                          decoration: BoxDecoration(
                            color: isDarkMode ? Colors.grey[800] : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 10)
                            ],
                          ),
                          child: _selectedPage == 'Account'
                              ? _buildAccountPage(themeProvider)
                              : _buildNotificationPage(themeProvider),
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

  Widget _buildSidebar(bool isDarkMode, double screenWidth) {
    return Container(
      width: screenWidth * 0.18,
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: ListView(
        padding: const EdgeInsets.only(top: 50),
        children: [
          _buildSidebarTile("Account", Icons.verified_user, isDarkMode, screenWidth),
          _buildSidebarTile("Notifications", Icons.notifications_active, isDarkMode, screenWidth),
        ],
      ),
    );
  }

  Widget _buildSidebarTile(String title, IconData icon, bool isDarkMode, double screenWidth) {
    final isSelected = _selectedPage == title;
    return MouseRegion(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPage = title),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDarkMode ? Colors.grey[700] : const Color(0xFFD7E4ED))
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, color: isDarkMode ? const Color(0xFF4F768E) : Colors.black87),
              if (screenWidth > 600) const SizedBox(width: 10),
              if (screenWidth > 1100)
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAccountPage(ThemeProvider themeProvider) {
    final isDarkMode = themeProvider.isDarkMode;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Account",
            style: TextStyle(
              color: isDarkMode ? Colors.white : const Color(0xFF4B6C81),
              fontFamily: "Krub",
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Divider(
            thickness: 1,
            indent: 20, // Space on the left
            endIndent: 20, // Space on the right
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              "My Profile",
              style: TextStyle(
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
              children: const [
                CircleAvatar(
                  radius: 35,
                  backgroundImage: AssetImage('assets/images/admin_icon.png'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildThemeToggle(themeProvider),
          const SizedBox(height: 20),
          _buildAccountForm(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildThemeToggle(ThemeProvider themeProvider) {
    return Selector<ThemeProvider, bool>(
      selector: (_, provider) => provider.isDarkMode,
      builder: (context, isDarkMode, child) {
        return SwitchListTile(
          title: const Text('Dark Mode'),
          value: Provider.of<ThemeProvider>(context).isDarkMode,
          onChanged: (value) async {
            await Future.delayed(const Duration(milliseconds: 50));
            Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
          },
        );
      },
    );
  }

  Widget _buildAccountForm(bool isDarkMode) {
    return Column(
      children: [
        const SizedBox(height: 12),
        const Text(
          "Change admin password",
          style: TextStyle(
            fontFamily: "Krub",
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildInputField(
                "Change Password",
                controller: _changePasswordController,
                isDarkMode: isDarkMode,
                obscureText: true,
                showVisibilityToggle: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildInputField(
                "Confirm Password",
                controller: _confirmPasswordController,
                isDarkMode: isDarkMode,
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
                backgroundColor: const Color(0xFF4A758F),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
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
    );
  }

  Widget _buildInputField(
      String label, {
        required TextEditingController controller,
        required bool isDarkMode,
        bool obscureText = false,
        bool showVisibilityToggle = false,
      }) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.25,
        child: TextField(
          controller: controller,
          obscureText: obscureText,
          style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Color(0xFF4A758F), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(15),
            ),
            labelText: label,
            labelStyle: TextStyle(
                color: isDarkMode ? Colors.grey[400] : const Color(0xFF848484)),
            fillColor: isDarkMode ? Colors.grey[700] : Colors.white,
            filled: true,
            suffixIcon: showVisibilityToggle
                ? IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: isDarkMode ? Colors.grey[400] : Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  obscureText = !obscureText;
                });
              },
            )
                : null,
          ),
        ),
      ),
    );
  }


  //Notification page
  Widget _buildNotificationPage(ThemeProvider themeProvider) {
    final isDarkMode = themeProvider.isDarkMode;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 1, // Matches full height of _buildAccountPage
            maxWidth: MediaQuery.of(context).size.width * 0.8, // Matches approximate content width
          ),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 10),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Notifications",
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : const Color(0xFF4B6C81),
                      fontFamily: "Krub",
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(
                  thickness: 1,
                  indent: 20,
                  endIndent: 20,
                ),
                const SizedBox(height: 8),
                StreamBuilder<List<AppNotificationFirebase>>(
                  stream: NotificationRepository.getUserNotifications(
                      FirebaseService.auth.currentUser?.uid ?? ''),
                  builder: (context, snapshot) {
                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          'Error loading notifications.',
                          style: TextStyle(fontSize: 20, fontFamily: "Krub"),
                        ),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final notifications = snapshot.data ?? [];

                    if (notifications.isEmpty) {
                      return const Center(
                        child: Text(
                          'No notifications yet.',
                          style: TextStyle(fontSize: 20, fontFamily: "Krub"),
                        ),
                      );
                    }

                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        return _buildNotificationItem(notifications[index], isDarkMode);
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(AppNotificationFirebase notification, bool isDarkMode) {
    final isUnread = notification.status != 'read';

    return FutureBuilder<String?>(
      future: profileService.getUserProfilePhotoByUid(notification.senderId ?? ''),
      builder: (context, snapshot) {
        return Container(
          decoration: BoxDecoration(
            color: isUnread
                ? (isDarkMode ? Colors.blueGrey[700] : Colors.blue[100])
                : (isDarkMode ? Colors.grey[800] : Colors.white),
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
          child: InkWell(
            onTap: isUnread
                ? () => NotificationRepository.markAsRead(notification.id)
                : null,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: isDarkMode ? Colors.grey[700] : Colors.grey[200],
                      child: snapshot.hasData && snapshot.data!.isNotEmpty
                          ? ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: snapshot.data!,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.person),
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Icon(
                              Icons.person,
                              size: 24,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('MMM dd, yyyy').format(notification.timestamp),
                            style: TextStyle(
                              fontSize: 11,
                              color: isDarkMode ? Colors.grey[400] : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            notification.title ?? 'New message',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            notification.body ?? 'You have a new message',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode ? Colors.grey[400] : Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            timeago.format(notification.timestamp),
                            style: TextStyle(
                              fontSize: 11,
                              color: isDarkMode ? Colors.grey[400] : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}