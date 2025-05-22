import 'package:flutter/material.dart';
import 'package:rentxpert_flutter_web/service/api.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int? allUserCount;
  int? landlordCount;
  int? tenantCount;
  int? apartmentCount;
  int? pendingApartmentCount = 20;

  @override
  void initState() {
    super.initState();
    fetchCounts();
  }

  Future<void> fetchCounts() async {
    allUserCount = await ApiService.fetchUserCount('All');
    landlordCount = await ApiService.fetchUserCount('Landlord');
    tenantCount = await ApiService.fetchUserCount('Tenant');
    apartmentCount = await ApiService.fetchApprovedApartmentCount();
    pendingApartmentCount = await ApiService.fetchPendingApartmentCount();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final RentXpertText = screenWidth * 0.03;

    // Theme colors
    final backgroundColor = isDarkMode ? Colors.grey[900] : Color(0xFFF5F5F5);
    final textColor = isDarkMode ? Colors.white : Color(0xFF4F768E);
    final cardColor = isDarkMode ? Colors.grey[800] : Colors.white;
    final chartTextColor = isDarkMode ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "Dashboard",
                style: TextStyle(
                  fontSize: 50,
                  fontFamily: "Inter",
                  color: textColor,
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
                  color: cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 12, offset: Offset(0, 6)),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "Welcome to RentXpert",
                    style: TextStyle(
                      color: textColor,
                      fontSize: RentXpertText,
                      fontFamily: "Krub-SemiBold",
                      fontWeight: FontWeight.w700,
                      overflow: TextOverflow.ellipsis,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _dashboardBox(
                    context,
                    'assets/images/person.png',
                    allUserCount?.toString() ?? "0",
                    "Registered\nUser",
                    "Total Users",
                    isDarkMode ? Colors.grey[700]! : Color(0xFFD0D9DF),
                    isDarkMode,
                  ),
                  _dashboardBox(
                    context,
                    'assets/images/building.png',
                    landlordCount?.toString() ?? "0",
                    "Landlords",
                    " ",
                    isDarkMode ? Colors.grey[700]! : Color(0xFFC5D9E6),
                    isDarkMode,
                  ),
                  _dashboardBox(
                    context,
                    'assets/images/person-home.png',
                    tenantCount?.toString() ?? "0",
                    "Tenants",
                    " ",
                    isDarkMode ? Colors.grey[700]! : Color(0xFFB4C8D5),
                    isDarkMode,
                  ),
                  _dashboardBox(
                    context,
                    'assets/images/bank.png',
                    apartmentCount?.toString() ?? "0",
                    "Available\nRents",
                    "Total Listed Properties",
                    isDarkMode ? Colors.grey[700]! : Color(0xFF9BBFD8),
                    isDarkMode,
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [

                    // Bar Chart Container
                  Container(
                  width: screenWidth * 0.22,
                  height: screenHeight * 0.45,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
                    ],
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.square, color: Color(0xFF8979FF), size: 14),
                              SizedBox(width: 8),
                              Text("2025",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: "Inter",
                                      fontWeight: FontWeight.w500,
                                      color: chartTextColor)),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),

                        // Bar chart container
                        SizedBox(
                          width: screenWidth * 0.3,
                          height: screenHeight * 0.35,
                          child: RotatedBox(
                            quarterTurns: 1,
                            child: BarChart(
                              BarChartData(
                                maxY: 100,
                                barGroups: [
                                  BarChartGroupData(
                                    x: 0,
                                    barRods: [
                                      BarChartRodData(
                                        toY: tenantCount?.toDouble() ?? 0,
                                        width: 60,
                                        color: Color(0xFF475782),
                                        borderRadius: BorderRadius.circular(4),
                                        backDrawRodData: BackgroundBarChartRodData(
                                          show: true,
                                          toY: 100,
                                          color: isDarkMode
                                              ? Colors.grey[700]!.withOpacity(0.5)
                                              : Color(0xFFD6DBED).withOpacity(0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                  BarChartGroupData(
                                    x: 1,
                                    barRods: [
                                      BarChartRodData(
                                        toY: landlordCount?.toDouble() ?? 0,
                                        width: 60,
                                        color: Color(0xFF8BACC0),
                                        borderRadius: BorderRadius.circular(4),
                                        backDrawRodData: BackgroundBarChartRodData(
                                          show: true,
                                          toY: 100,
                                          color: isDarkMode
                                              ? Colors.grey[700]!.withOpacity(0.5)
                                              : Color(0xFFD6DBED).withOpacity(0.5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        return Transform.rotate(
                                          angle: -1.5708,
                                          child: Text(
                                            value.toInt().toString(),
                                            style: TextStyle(
                                              color: chartTextColor,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 55,
                                      getTitlesWidget: (value, meta) {
                                        final label = value.toInt() == 0 ? "Tenants" : "Landlords";
                                        return Transform.rotate(
                                          angle: -1.5708,
                                          child: Padding(
                                            padding: const EdgeInsets.only(top: 20.0),
                                            child: Text(
                                              label,
                                              style: TextStyle(
                                                color: chartTextColor,
                                                fontFamily: "Inter",
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                gridData: FlGridData(show: true),
                                barTouchData: BarTouchData(enabled: false),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border(bottom: BorderSide(color: chartTextColor)),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                    SizedBox(width: 40),

                    // Pie Chart Container
                    Container(
                      width: screenWidth * 0.45,
                      height: screenHeight * 0.45,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
                        ],
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final maxWidth = constraints.maxWidth;
                          final maxHeight = constraints.maxHeight;
                          final chartSize = maxWidth < maxHeight ? maxWidth : maxHeight;
                          bool isSmallScreen = screenWidth < 1100;

                          return Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: chartSize * 0.9,
                                  height: chartSize * 0.9,
                                  child: PieChart(
                                    PieChartData(
                                      sections: [
                                        PieChartSectionData(
                                          value: apartmentCount?.toDouble() ?? 0,
                                          color: Color(0xFF69769F),
                                          radius: chartSize * 0.38,
                                          title: '${apartmentCount ?? 0}',
                                          titleStyle: TextStyle(
                                            fontFamily: "Inter",
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                        PieChartSectionData(
                                          value: pendingApartmentCount?.toDouble() ?? 0,
                                          color: Color(0xFF393F4C),
                                          radius: chartSize * 0.40,
                                          title: '${pendingApartmentCount ?? 0}',
                                          titleStyle: TextStyle(
                                            fontFamily: "Inter",
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                      sectionsSpace: 2,
                                      centerSpaceRadius: chartSize * 0.1,
                                    ),
                                  ),
                                ),
                                if (!isSmallScreen) ...[
                                  SizedBox(width: 32), // space between pie and legend
                                  Container(
                                    padding: EdgeInsets.only(left: 16),
                                    width: screenWidth * 0.15,
                                    height: screenHeight * 0.45,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.circle, color: Color(0xFF69769F), size: 12),
                                            SizedBox(width: 8),
                                            Text("Approved Rents",
                                                style: TextStyle(fontSize: 14, color: chartTextColor)),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Icon(Icons.circle, color: Color(0xFF393F4C), size: 12),
                                            SizedBox(width: 8),
                                            Text("Pending Rents",
                                                style: TextStyle(fontSize: 14, color: chartTextColor)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
                    ),

                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardBox(
      BuildContext context,
      String imageUrl,
      String mainNumber,
      String smallLabel,
      String subtitle,
      Color bgColor,
      bool isDarkMode,
      ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 1300;
    final double countFontSize = isSmallScreen
        ? screenWidth * 0.035
        : screenWidth * 0.025;
    final textColor = isDarkMode ? Colors.white : Color(0xFF4D4B4B);

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imageUrl,
              height: 60,
              width: 60,
              fit: BoxFit.contain,
            ),
            SizedBox(width: 10),
            if (!isSmallScreen)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            mainNumber,
                            style: TextStyle(
                              fontSize: countFontSize,
                              color: isDarkMode ? Colors.white : Color(0xFF69769F),
                              fontFamily: "Inter",
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            smallLabel,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: "Inter",
                              fontWeight: FontWeight.w800,
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: textColor,
                        fontFamily: "Inter",
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
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