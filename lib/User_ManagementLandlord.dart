import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class UserManagementLandlord extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementLandlord> {
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
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "User Management: Landlord",
              style: TextStyle(
                fontSize: 45,
                fontFamily: "Inter",
                color: Color(0xFF4F768E),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 20),
            Expanded(child: _buildUserTable()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10),
            color: Colors.white,
          ),
          child: IconButton(
            icon: const Icon(Icons.filter_list, color: Color(0xFF4F768E)),
            onPressed: () {
              // TODO: Implement filter action
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  // TODO: Clear search field
                },
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
      ],
    );
  }

  Widget _buildUserTable() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 10),
        ],
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: const [
            DataColumn(label: Text('Uid')),
            DataColumn(label: Text('Name')),
            DataColumn(label: Text('Email')),
            DataColumn(label: Text('Phone Number')),
            DataColumn(label: Text('Address')),
            DataColumn(label: Text('Valid ID')),
            DataColumn(label: Text('Pending')),
            DataColumn(label: Text('User Type')),
            DataColumn(label: Text('Customize')),
          ],
          rows: userData.map((user) {
            return DataRow(cells: [
              DataCell(Text(user['uid']?.toString() ?? '')),
              DataCell(Text(user['fullname'] ?? '')),
              DataCell(Text(user['email'] ?? '')),
              DataCell(Text(user['phone_number'] ?? '')),
              DataCell(Text(user['address'] ?? '')),
              DataCell(Text(user['valid_id'] ?? '')),
              DataCell(Text(user['account_status'] ?? '')),
              DataCell(Text(user['user_type'] ?? '')),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {
                      // TODO: Edit action
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.black),
                    onPressed: () {
                      // TODO: Delete action
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_horiz, color: Colors.grey),
                    onPressed: () {
                      // TODO: More action
                    },
                  ),
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
