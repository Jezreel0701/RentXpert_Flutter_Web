import 'package:flutter/material.dart';
import 'package:rentxpert_flutter_web/service/api.dart'; // Your API service
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int? allUserCount;
  int? landlordCount;
  int? tenantCount;
  int? apartmentCount; // New: Store apartment count
  int? pendingApartmentCount = 20; // Placeholder for pending count, replace with real data

  @override
  void initState() {
    super.initState();
    fetchCounts(); // Fetch counts when the screen initializes
  }

  Future<void> fetchCounts() async {
    print('Fetching all counts...');

    allUserCount = await ApiService.fetchUserCount('All');
    landlordCount = await ApiService.fetchUserCount('Landlord');
    tenantCount = await ApiService.fetchUserCount('Tenant');
    apartmentCount = await ApiService.fetchApprovedApartmentCount(); // 🏠 Fetch apartments
    pendingApartmentCount = await ApiService.fetchPendingApartmentCount(); // 🏠 Fetch pending apartments

    print(
      'Counts: Users = $allUserCount, Landlords = $landlordCount, Tenants = $tenantCount, Apartments = $apartmentCount, Pending Apartments = $pendingApartmentCount',
    );

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final RentXpertText = screenWidth * 0.03;

    return Scaffold(
      backgroundColor: Color(0xFFFF5F5F5),
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

            // Dashboard Statistic Boxes
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
                    Color(0xFFD0D9DF),

                  ),
                  _dashboardBox(
                    context,
                    'assets/images/building.png',
                    landlordCount?.toString() ?? "0",
                    "Landlords",
                    " ",
                    Color(0xFFC5D9E6),
                  ),
                  _dashboardBox(
                    context,
                    'assets/images/person-home.png',
                    tenantCount?.toString() ?? "0",
                    "Tenants",
                    " ",
                    Color(0xFFB4C8D5),
                  ),
                  _dashboardBox(
                    context,
                    'assets/images/bank.png',
                    apartmentCount?.toString() ?? "0", // ✅ Now dynamic
                    "Available\nRents",
                    "Total Listed Properties",
                    Color(0xFF9BBFD8),
                  ),
                ],
              ),
            ),

            /// ✅ Barchart Widget here
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Align(
                alignment: Alignment.centerLeft, // Center vertically and align to the left
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Bar Chart Container
                    Container(
                      width: screenWidth * 0.22,
                      height: screenHeight * 0.45,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.square, color: Color(0xFF8979FF), size: 14),
                                SizedBox(width: 8),
                                Text("2025", style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: "Inter",
                                    fontWeight: FontWeight.w500)),
                              ],
                            ),
                          ),
                          SizedBox(height: 12),
                          SizedBox(
                            width: screenWidth * 0.3,  // 80% of screen width for the chart
                            height: screenHeight * 0.35,  // 25% of screen height for the chart
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
                                            color: Color(0xFFD6DBED).withOpacity(0.5),
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
                                            color: Color(0xFFD6DBED).withOpacity(0.5),
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
                                            angle: -1.5708, // 90 degrees counterclockwise in radians
                                            child: Text(
                                              value.toInt().toString(),
                                              style: TextStyle(
                                                color: Colors.black87,
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
                                        reservedSize: 55,  // Add margin to increase space between bars and the left titles
                                        getTitlesWidget: (value, meta) {
                                          String label;
                                          switch (value.toInt()) {
                                            case 0:
                                              label = "Tenants";
                                              break;
                                            case 1:
                                              label = "Landlords";
                                              break;
                                            default:
                                              label = "";
                                          }

                                          return Transform.rotate(
                                            angle: -1.5708, // 90 degrees counterclockwise in radians
                                            child: Padding(
                                              padding: const EdgeInsets.only(top: 20.0),
                                              child: Text(
                                                label,
                                                style: TextStyle(
                                                  color: Colors.black87,
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
                                    border: Border(
                                      bottom: BorderSide(color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(width: 40),

                    // ✅ Pie Chart Container
                    Container(
                      width: screenWidth * 0.45,
                      height: screenHeight * 0.45,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final maxWidth = constraints.maxWidth;
                          final maxHeight = constraints.maxHeight;
                          final chartSize = maxWidth < maxHeight ? maxWidth : maxHeight;

                          // Use MediaQuery to determine screen width
                          double screenWidth = MediaQuery.of(context).size.width;

                          // Check if screen width is smaller than 600px to hide the legend
                          bool isSmallScreen = screenWidth < 1100; // Set your threshold here

                          return Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                // Pie Chart Container
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
                                          title: '', // leave blank
                                          badgeWidget: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                '       Approved Apartments',
                                                style: TextStyle(
                                                  fontFamily: "Inter",
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                '${apartmentCount ?? 0}',
                                                style: TextStyle(
                                                  fontFamily: "Inter",
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                          badgePositionPercentageOffset: 0.6, // Adjust position as needed
                                        ),


                                        PieChartSectionData(
                                          value: pendingApartmentCount?.toDouble() ?? 0,
                                          color: Color(0xFF393F4C),
                                          radius: chartSize * 0.40,
                                          title: '', // leave blank
                                          badgeWidget: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Pending Apartments',
                                                style: TextStyle(
                                                  fontFamily: "Inter",
                                                  fontSize: 12,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                '${pendingApartmentCount ?? 0}',
                                                style: TextStyle(
                                                  fontFamily: "Inter",
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ],
                                          ),
                                          badgePositionPercentageOffset: 0.6, // Adjust position as needed
                                        ),


                                      ],
                                      sectionsSpace: 2,
                                      centerSpaceRadius: chartSize * 0.1,
                                    ),
                                  ),
                                ),

                                // Empty Space to Push Legend to the Right
                                Expanded(child: Container()),

                                // Conditionally show/hide the legend based on screen size
                                if (!isSmallScreen)
                                  Container(
                                    padding: EdgeInsets.only(left: 16),
                                    width: screenWidth * 0.15,  // Adjust width for the legend container
                                    height: screenHeight * 0.45,  // Adjust height to match the chart's height
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.circle, color: Color(0xFF69769F), size: 12),
                                            SizedBox(width: 8),
                                            Text("Approved Rents", style: TextStyle(fontSize: 14)),
                                          ],
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Icon(Icons.circle, color: Color(0xFF393F4C), size: 12),
                                            SizedBox(width: 8),
                                            Text("Pending Rents", style: TextStyle(fontSize: 14)),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
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

  // Small 4 Dashboard Box Widget
  Widget _dashboardBox(
      BuildContext context,
      String imageUrl,
      String mainNumber,
      String smallLabel,
      String subtitle,
      Color bgColor,

      ) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final isSmallScreen = screenWidth < 1300;
    // Adjust font size based on screen width
    final double countFontSize = isSmallScreen
        ? screenWidth * 0.035  // bigger count on small screen
        : screenWidth * 0.025; // regular size on wide screen

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
                          child: Text(            // Number
                            mainNumber,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: countFontSize,
                              color: Color(0xFF69769F),
                              fontFamily: "Inter",
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(            // Text beside number
                            smallLabel,
                            // maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontFamily: "Inter",
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF4D4B4B),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(                         // Text below number
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Color(0xFF4D4B4B),
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