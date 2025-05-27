import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'package:rentxpert_flutter_web/Dashboard_Screen.dart';
import 'package:go_router/go_router.dart';

class PageNotFoundScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Theme colors consistent with DashboardScreen
    final backgroundColor = isDarkMode ? Colors.grey[900] : Color(0xFFF5F5F5);
    final textColor = isDarkMode ? Colors.white : Color(0xFF4F768E);
    final cardColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final buttonColor = isDarkMode ? Color(0xFF69769F) : Color(0xFF4F768E);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            width: screenWidth * 0.8,
            constraints: BoxConstraints(maxWidth: 600),
            padding: EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Optional: Add an image or icon
                Image.asset(
                  'assets/images/not_found.png', // Replace with your 404 image
                  height: screenHeight * 0.2,
                  width: screenHeight * 0.2,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.error_outline,
                    size: screenHeight * 0.15,
                    color: textColor,
                  ),
                ),
                SizedBox(height: 24),
                Text(
                  "404 - Page Not Found",
                  style: TextStyle(
                    fontSize: screenWidth * 0.05,
                    fontFamily: "Inter",
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  "Oops! The page you're looking for doesn't exist or has been moved.",
                  style: TextStyle(
                    fontSize: screenWidth * 0.025,
                    fontFamily: "Inter",
                    color: textColor.withOpacity(0.8),
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    GoRouter.of(context).go('/dashboard');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    "Back to Dashboard",
                    style: TextStyle(
                      fontSize: screenWidth * 0.025,
                      fontFamily: "Inter",
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}