import 'package:flutter/material.dart';
import 'package:rentxpert_flutter_web/service/api.dart'; // Your API service


class DashboardScreen extends StatefulWidget {
 @override
 _DashboardScreenState createState() => _DashboardScreenState();
}


class _DashboardScreenState extends State<DashboardScreen> {
 int? allUserCount;
 int? landlordCount;
 int? tenantCount;
 int? apartmentCount; // New: Store apartment count


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


   print(
     'Counts: Users = $allUserCount, Landlords = $landlordCount, Tenants = $tenantCount, Apartments = $apartmentCount',
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
                     padding: const EdgeInsets.all(18.0),
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
             padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
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
         ],
       ),
     ),
   );
 }


 // Reusable Dashboard Box Widget
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
             width: 100,
             fit: BoxFit.contain,
           ),
           SizedBox(width: 6),
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
                           maxLines: 1,
                           overflow: TextOverflow.ellipsis,
                           style: TextStyle(
                             fontSize: countFontSize,
                             color: Color(0xFF69769F),
                             fontWeight: FontWeight.w600,
                           ),
                         ),
                       ),
                       SizedBox(width: 6),
                       Flexible(
                         child: Text(
                           smallLabel,
                           maxLines: 1,
                           overflow: TextOverflow.ellipsis,
                           style: TextStyle(
                             fontSize: 14,
                             color: Color(0xFF4D4B4B),
                           ),
                         ),
                       ),
                     ],
                   ),
                   SizedBox(height: 4),
                   Text(
                     subtitle,
                     maxLines: 1,
                     overflow: TextOverflow.ellipsis,
                     style: TextStyle(
                       fontSize: 14,
                       color: Color(0xFF4D4B4B),
                     ),
                   ),
                 ],
               ),
             )
           else
           // Only show count text when screen is small
             Flexible(
               child: Text(
                 mainNumber,
                 maxLines: 1,
                 overflow: TextOverflow.ellipsis,
                 style: TextStyle(
                   fontSize: screenWidth * 0.03,
                   color: Color(0xFF69769F),
                   fontWeight: FontWeight.w600,
                 ),
               ),
             ),
         ],
       ),
     ),
   );
 }




}



