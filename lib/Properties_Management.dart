import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PropertiesManagementScreen extends StatefulWidget {
  @override
  _PropertyManagementScreenState createState() => _PropertyManagementScreenState();
}

class _PropertyManagementScreenState extends State<PropertiesManagementScreen> {
  List<Map<String, dynamic>> apartmentsData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      final apartments = await fetchUsers();
      setState(() {
        apartmentsData = apartments;
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
                        padding: const EdgeInsets.only(top: 40.0), // Add padding here
                        child: Table(
                          border: TableBorder.all(color: Colors.grey, width: 1),
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                          children: [
                            _tableHeaderRow(),
                            ...apartmentsData.map((apartments) {
                              return _tableDataRow([
                                apartments['name']?.toString() ?? '',
                                apartments['type'] ?? '',
                                apartments['location'] ?? '',
                                apartments['price'] ?? '',
                                apartments['status'] ?? '',
                                apartments['customize'] ?? '',
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
