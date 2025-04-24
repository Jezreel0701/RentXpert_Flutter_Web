import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class PropertiesManagementScreen extends StatefulWidget {
 @override
 _PropertyManagementScreenState createState() => _PropertyManagementScreenState();
}


class _PropertyManagementScreenState extends State<PropertiesManagementScreen> {
 List<Map<String, dynamic>> apartmentsData = [];
 List<Map<String, dynamic>> filteredApartmentsData = [];
 bool isLoading = true;
 TextEditingController searchController = TextEditingController();


 @override
 void initState() {
   super.initState();
   loadUsers();
   searchController.addListener(_filterApartments);
 }


 @override
 void dispose() {
   searchController.dispose();
   super.dispose();
 }


 Future<void> loadUsers() async {
   try {
     final apartments = await fetchUsers();
     setState(() {
       apartmentsData = apartments;
       filteredApartmentsData = apartments; // Initialize filtered data
       isLoading = false;
     });
   } catch (e) {
     print('Error fetching apartments: $e');
     setState(() => isLoading = false);
   }
 }


 Future<List<Map<String, dynamic>>> fetchUsers() async {
   final response = await http.get(
     Uri.parse('http://localhost:8080/display/apartments'),
     headers: {'Content-Type': 'application/json'},
   );


   if (response.statusCode == 200) {
     final data = json.decode(response.body);
     List<dynamic> users = data['data']['users'];
     return users.cast<Map<String, dynamic>>();
   } else {
     throw Exception('Failed to load properties');
   }
 }


 void _filterApartments() {
   final query = searchController.text.toLowerCase();
   setState(() {
     filteredApartmentsData = apartmentsData.where((apartment) {
       return apartment['name']?.toString().toLowerCase().contains(query) ?? false;
     }).toList();
   });
 }


 @override
 Widget build(BuildContext context) {
   return Scaffold(
     backgroundColor: const Color(0xFFF5F5F5),
     body: Padding(
       padding: const EdgeInsets.all(20.0),
       child: isLoading
           ? const Center(child: CircularProgressIndicator())
           : LayoutBuilder(
               builder: (context, constraints) {
                 return Column(
                   crossAxisAlignment: CrossAxisAlignment.start,
                   children: [
                     const Text(
                       "Properties Management",
                       style: TextStyle(
                         fontSize: 45,
                         fontFamily: "Inter",
                         color: Color(0xFF4F768E),
                         fontWeight: FontWeight.w600,
                         overflow: TextOverflow.ellipsis,
                       ),
                     ),
                     const SizedBox(height: 20),
                     _buildSearchBar(), // Add the search bar here
                     const SizedBox(height: 20),
                     Expanded(
                       child: Container(
                         width: constraints.maxWidth,
                         decoration: BoxDecoration(
                           color: Colors.white,
                           borderRadius: BorderRadius.circular(12),
                           boxShadow: const [
                             BoxShadow(color: Colors.black26, blurRadius: 10)
                           ],
                         ),
                         padding: const EdgeInsets.all(16.0),
                         child: SingleChildScrollView(
                           scrollDirection: Axis.vertical,
                           child: Padding(
                             padding: const EdgeInsets.only(top: 40.0),
                             child: Table(
                               border: TableBorder.all(color: Colors.grey, width: 1),
                               defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                               children: [
                                 _tableHeaderRow(),
                                 ...filteredApartmentsData.map((apartment) {
                                   return _tableDataRow([
                                     apartment['name']?.toString() ?? '',
                                     apartment['type'] ?? '',
                                     apartment['location'] ?? '',
                                     apartment['price'] ?? '',
                                     apartment['status'] ?? '',
                                     apartment['customize'] ?? '',
                                     
                                   ]);
                                 }).toList(),
                               ],
                             ),
                           ),
                         ),
                       ),
                     ),
                   ],
                 );
               },
             ),
     ),
   );
 }


 Widget _buildSearchBar() {
   return Row(
     children: [
       Container(
         width: 50,
         decoration: BoxDecoration(
           border: Border.all(color: Colors.grey),
           borderRadius: BorderRadius.circular(10),
           color: Colors.white,
         ),
         child: IconButton(
           icon: const Icon(Icons.filter_list, color: Color(0xFF4F768E)),
           onPressed: () {},
         ),
       ),
       const SizedBox(width: 10),
       SizedBox(
 width: 500, // Set the desired width for the search bar
 child: ConstrainedBox(
   constraints: BoxConstraints(
     minWidth: 200, // Minimum width for the search bar
     maxWidth: 400, // Maximum width for the search bar
   ),
   child: TextField(
     decoration: InputDecoration(
       prefixIcon: const Icon(Icons.search),
       suffixIcon: IconButton(
         icon: const Icon(Icons.close),
         onPressed: () {},
       ),
       hintText: 'Search...',
       border: OutlineInputBorder(
         borderRadius: BorderRadius.circular(10),
       ),
       contentPadding: const EdgeInsets.symmetric(vertical: 10),
       fillColor: Colors.white,
       filled: true,
     ),
   ),
 ),


        
       ),
     ],
   );
 }


 TableRow _tableHeaderRow() {
   final headers = [
     'Name',
     'Type',
     'Location',
     'Price',
     'Status',
     'Customize',
   ];
   return TableRow(
     decoration: BoxDecoration(color: Colors.grey[200]),
     children: headers.map(_tableHeaderCell).toList(),
   );
 }


 Widget _tableHeaderCell(String text) {
   return Padding(
     padding: const EdgeInsets.all(8.0),
     child: Center(
       child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
     ),
   );
 }


 TableRow _tableDataRow(List<String> values) {
   return TableRow(
     children: values.map((value) {
       return Padding(
         padding: const EdgeInsets.all(8.0),
         child: Center(child: Text(value)),
       );
     }).toList(),
   );
 }
}

