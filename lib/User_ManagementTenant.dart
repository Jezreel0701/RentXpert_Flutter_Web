import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserManagementTenant extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementTenant> {
  List<Map<String, dynamic>> userData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers() async {
    try {
      final users = await fetchUsers();
      setState(() {
        userData = users;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching users: $e');
      setState(() => isLoading = false);
    }
  }

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/display/users'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<dynamic> users = data['data']['users'];
      return users.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to load users');
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
                  "User Management: Tenant",
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
                            ...userData.map((user) {
                              return _tableDataRow([
                                user['uid']?.toString() ?? '',
                                user['fullname'] ?? '',
                                user['email'] ?? '',
                                user['phone_number'] ?? '',
                                user['address'] ?? '',
                                user['valid_id'] ?? '',
                                user['account_status'] ?? '',
                                user['user_type'] ?? '',
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
      'Uid',
      'Name',
      'Email',
      'Phone Number',
      'Address',
      'Valid ID',
      'Account Status',
      'User Type'
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
