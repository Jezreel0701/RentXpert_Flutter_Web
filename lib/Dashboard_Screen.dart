import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final RentXpertText = MediaQuery.of(context).size.width * 0.03; // Responsive font size

    return Scaffold(
      backgroundColor: Color(0xFFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.08),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "Dashboard",
                style: TextStyle(
                  fontSize: 50,
                  fontFamily: "Inter",
                  color: Color(0xFF4F768E),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 20),
            Center(
              child: Container(
                width: screenWidth * 0.8,
                height: screenHeight * 0.15,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.bottomLeft,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        "Welcome to RentXpert",
                        style: TextStyle(
                          color: Color(0xFF4F768E),
                          fontSize: RentXpertText,
                          fontFamily: "Krub-SemiBold",
                          fontWeight: FontWeight.w700,
                          overflow: TextOverflow.ellipsis,
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),

            /// 🧱 4 Separated Boxes with Images
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _dashboardBox(
                    context,
                    'assets/images/person.png',
                    "260",
                    "Registered\nUser",
                    "Total Users",
                    Color(0xFFD0D9DF),
                  ),
                  _dashboardBox(
                    context,
                    'assets/images/building.png',
                    "120",
                    "Landlords",
                    " ",
                    Color(0xFFC5D9E6),
                  ),
                  _dashboardBox(
                    context,
                    'assets/images/person-home.png',
                    "140",
                    "Tenants",
                    " ",
                    Color(0xFFB4C8D5),
                  ),
                  _dashboardBox(
                    context,
                    'assets/images/bank.png',
                    "185",
                    "Available\nRents",
                    "Total Listed Properties",
                    Color(0xFF9BBFD8),
                  ),
                ],
              ),
            ),


          ],
        ),
      ),
    );
  }


  // 🔧 Custom box widget with image and text
  Widget _dashboardBox(
      BuildContext context, String imageUrl, String mainTitle, String smallLabel, String subtitle, Color bgColor) {
    final screenWidth = MediaQuery.of(context).size.width; // Now passing context here to get screen width
    final screenHeight = MediaQuery.of(context).size.height;

    // Calculate the responsive font size based on the screen width
    double mainTitleFontSize = screenWidth * 0.03;
    double iconFontSizewidth = screenWidth * 0.06;
    double iconFontSizeheight = screenHeight * 0.06;

    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12),
        margin: EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Replace Icon with Image, resized to 60x60
            Image.asset(
              imageUrl,
              height: iconFontSizeheight,
              width: iconFontSizewidth,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          mainTitle,
                          style: TextStyle(
                            fontSize: mainTitleFontSize,
                            color: Color(0xFF69769F),
                            fontWeight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          smallLabel,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF4D4B4B),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF4D4B4B),
                      overflow: TextOverflow.ellipsis,
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
}


