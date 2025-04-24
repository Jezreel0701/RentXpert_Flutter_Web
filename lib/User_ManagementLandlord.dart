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

  int _rowsPerPage = 10;
  int _currentPage = 1;

  String? editingUserId;
  Map<String, dynamic> editedUser = {};

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers({int page = 1}) async {
    setState(() => isLoading = true);

    try {
      final users = await fetchUsers(page, _rowsPerPage);
      setState(() {
        userData = users;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching users: $e');
      setState(() => isLoading = false);
    }
  }

  Future<List<Map<String, dynamic>>> fetchUsers(int page, int limit) async {
    final response = await http.get(
      Uri.parse('http://localhost:8080/display/users?page=$page&limit=$limit&user_type=Landlord'), // Change tenant capitalization
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

  int get _totalPages => (userData.length / _rowsPerPage).ceil();

  List<Map<String, dynamic>> get _paginatedData {
    final startIndex = (_currentPage - 1) * _rowsPerPage;
    final endIndex = startIndex + _rowsPerPage;
    return userData.sublist(
      startIndex,
      endIndex > userData.length ? userData.length : endIndex,
    );
  }

  // Delete function and design
  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(45),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 400,
          height: 300,

          child: Column(
            mainAxisSize: MainAxisSize.min,
            // mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FittedBox(
                fit: BoxFit.contain,
                child: Image.asset(
                  'assets/images/delete.png',
                  width: 75,
                  height: 75,
                ),
              ),
              const SizedBox(height: 12),

              const Text(
                'Delete',
                style: TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 25,
                    fontFamily: "Krub",
                    fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              const Text(
                'Are you sure you want to delete?',
                style: TextStyle(
                    color: Color(0xFF979797),
                    fontSize: 18,
                    fontFamily: "Krub",
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: 170, // Adjust the width here
                    height: 50, // Adjust the height here
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 4,
                        backgroundColor: Color(0xFFEDEDED),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
                            fontSize: 20,
                            color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 170, // Adjust the width here
                    height: 50, // Adjust the height here
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        elevation: 4,
                        backgroundColor: Color(0xFF79BD85),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                        //   Function for delete account
                        _deleteAccount();
                      },
                      child: const Text(
                          'Confirm',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),

        ),
      ),
    );
  }

  void _deleteAccount() {
    // Add your account deletion logic here.

    // Show custom top snack bar
    _showDeleteTopSnackBar("Account deleted successfully");
  }

  //Snakcbar notification for delete button
  void _showDeleteTopSnackBar(String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,  // Adjust the top value as per your needs
        left: MediaQuery.of(context).size.width / 2 - 150, // Center the snackbar
        right: MediaQuery.of(context).size.width / 2 - 150,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );

    // Insert the overlay
    overlay.insert(overlayEntry);

    // Remove the overlay after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }


  //Dialog for filter
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // List of filter options
        final filterOptions = [
          'Name',
          'Email',
          'Address',
          'Phone Number',
          'Valid ID',
          'Account Status',
          'User Type',
        ];

        // Track selected filters
        List<String> selectedOptions = [];

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFFFFFFFF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),

              content: SizedBox(
                width: 400,
                height: 250,
                child: SingleChildScrollView(

                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Wrap(
                        spacing: 16.0,      // Horizontal gap between chips
                        runSpacing: 16.0,   // Vertical gap between rows
                        alignment: WrapAlignment.start, // Align items to the start

                        children: filterOptions.map((option) {
                          final isSelected = selectedOptions.contains(option);

                          // Check for Phone Number and Account Status to apply fixed size
                          final isFixedSize = option == 'Phone Number' || option == 'Address' ||
                              option == 'Valid ID' || option == 'User Type' || option == 'Name' || option == 'Email'
                              || option == 'Account Status';

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                if (isSelected) {
                                  selectedOptions.remove(option); // Deselect option
                                } else {
                                  selectedOptions.add(option); // Select option
                                }
                              });
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.0, // Apply standard padding
                                vertical: 8.0,    // Apply vertical padding for all options
                              ),
                              width: isFixedSize ? 160.0 : null, // Fixed width for Phone and Account Status
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF4F768E) : Colors.white, // Background color
                                borderRadius: BorderRadius.circular(30), // Oval shape
                                border: Border.all(
                                  color: isSelected ? Colors.transparent : Color(0xFF818181), // Border color
                                ),
                              ),
                              child: Center( // Ensures text is centered within the container
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Krub",
                                    color: isSelected ? Colors.white : Colors.black, // Text color change on select
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ),




              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 17), // Padding inside the button
                    backgroundColor: const Color(0xFFFFFFFF),
                    foregroundColor: const Color(0xFF000000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), // Rounded corners
                      side: BorderSide(
                        color: Color(0xFFC3C3C3), // Border color
                        width: 1, // Border width
                      ),
                    ),
                  ),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 19,
                      fontFamily: "Krub",
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 17), // Padding inside the button
                    backgroundColor: const Color(0xFF9AD47F),
                    foregroundColor: const Color(0xFFFFFFFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15), // Rounded corners
                    ),
                  ),

                  onPressed: () {
                    // Handle selectedOptions here
                    Navigator.of(context).pop();
                  },

                  child: const Text(
                    'Apply filters',
                    style: TextStyle(
                      fontSize: 19,
                      fontFamily: "Krub",
                      fontWeight: FontWeight.w500,

                    ),
                  ),
                ),
              ],

            );
          },
        );
      },
    );
  }

  //Data cell Styles
  DataCell buildCenteredTextCell(String? text) {
    return DataCell(
      Center(
        child: Text(
          text ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: "Krub",
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
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
              "User Management: Tenant",
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
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildUserTable(key: ValueKey(_currentPage)),
              ),
            ),
            const SizedBox(height: 20),
            _buildPaginationBar(),
          ],
        ),
      ),
    );
  }

  //Search bar widget
  Widget _buildSearchBar() {
    return Row(
      children: [
        FittedBox(
          // width: 50,
          // decoration: BoxDecoration(
          //   border: Border.all(color: Colors.grey),
          //   borderRadius: BorderRadius.circular(10),
          //   color: Colors.white,
          // ),

          child: IconButton(
            icon: Image.asset(
              'assets/images/filter_icon.png',
              width: 55,
              height: 55,
            ),
            onPressed: () {
              _showFilterDialog();
            },
          ),


        ),

        const SizedBox(width: 10),

        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3, // Set the desired width for the search bar
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


  // Table  widget
  Widget _buildUserTable({Key? key}) {
    final paginatedUsers = _paginatedData;

    final columnTitles = [
      'Uid',
      'Name',
      'Email',
      'Account Status',
      'User Type',
      'Customize',
    ];

    // Consistent width for columns (except Customize)
    const double columnWidth = 120;

    return LayoutBuilder(
      key: key,
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Container(
            width: constraints.maxWidth,
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0),
                  child: DataTable(
                    columnSpacing: 24,
                    headingRowHeight: 56,
                    dataRowHeight: 60,
                    border: TableBorder.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                    columns: [
                      for (var title in columnTitles)
                        DataColumn(
                          label: SizedBox(
                            width: title == 'Customize' ? 260 : columnWidth,
                            child: Center(
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontFamily: "Krub",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                    rows: paginatedUsers.map((user) {
                      final isEditing = editingUserId == user['uid'];
                      return DataRow(cells: [
                        DataCell(SizedBox(
                          width: columnWidth,
                          child: Center(child: Text(user['uid']?.toString() ?? '', textAlign: TextAlign.center)),
                        )),
                        isEditing
                            ? DataCell(SizedBox(
                          width: columnWidth,
                          child: TextFormField(
                            initialValue: editedUser['fullname'] ?? user['fullname'],
                            onChanged: (value) => editedUser['fullname'] = value,
                          ),
                        ))
                            : DataCell(SizedBox(
                          width: columnWidth,
                          child: Center(child: Text(user['fullname'], textAlign: TextAlign.center)),
                        )),
                        isEditing
                            ? DataCell(SizedBox(
                          width: columnWidth,
                          child: TextFormField(
                            initialValue: editedUser['email'] ?? user['email'],
                            onChanged: (value) => editedUser['email'] = value,
                          ),
                        ))
                            : DataCell(SizedBox(
                          width: columnWidth,
                          child: Center(child: Text(user['email'], textAlign: TextAlign.center)),
                        )),
                        DataCell(SizedBox(
                          width: columnWidth,
                          child: Center(child: Text(user['account_status'], textAlign: TextAlign.center)),
                        )),
                        DataCell(SizedBox(
                          width: columnWidth,
                          child: Center(child: Text(user['user_type'], textAlign: TextAlign.center)),
                        )),
                        DataCell(
                          SizedBox(
                            width: 260,
                            child: Center(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  isEditing
                                      ? TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        final index = userData.indexWhere((u) => u['uid'] == user['uid']);
                                        if (index != -1) {
                                          userData[index] = {
                                            ...userData[index],
                                            ...editedUser,
                                          };
                                        }
                                        editingUserId = null;
                                        editedUser = {};
                                      });
                                    },
                                    icon: const Icon(Icons.save, size: 15),
                                    label: const Text('Save'),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                  )
                                      : TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        editingUserId = user['uid'];
                                        editedUser = Map<String, dynamic>.from(user);
                                      });
                                    },
                                    icon: const Icon(Icons.edit, size: 15),
                                    label: const Text('Edit'),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      backgroundColor: const Color(0xFF4F768E),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                  if (isEditing)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: IconButton(
                                        icon: const Icon(Icons.cancel, color: Colors.red),
                                        onPressed: () {
                                          setState(() {
                                            editingUserId = null;
                                            editedUser = {};
                                          });
                                        },
                                      ),
                                    ),
                                  if (!isEditing)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 13.0),
                                      child: IconButton(
                                        icon: Image.asset('assets/images/white_delete.png', width: 30, height: 30),
                                        onPressed: () {
                                          _showDeleteConfirmationDialog();
                                        },
                                      ),
                                    ),
                                  if (!isEditing)
                                    IconButton(
                                      icon: Image.asset('assets/images/more_options.png', width: 55, height: 55),
                                      onPressed: () => _showUserDetailsDialog(user),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }



  void _showUserDetailsDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text(
          "User Details",
          style: TextStyle(
            color: Color(0xFF4F768E),
            fontFamily: "Krub",
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow("Name", user['fullname']),
            _infoRow("Phone Number", user['phone_number']),
            _infoRow("Address", user['address']),
            _infoRow("Valid ID", user['valid_id']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              "Close",
              style: TextStyle(
                color: Color(0xFF4F768E),
                fontFamily: "Inter",
                fontWeight: FontWeight.w300,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            "$label:",
            style: const TextStyle(
              fontFamily: "Inter",
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value ?? '',
              style: const TextStyle(
                fontFamily: "Inter",
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildPaginationBar() {
    return Padding(
      padding: const EdgeInsets.only(right: 60.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Results per page: ${userData.length}",
              style: TextStyle(
                fontWeight:  FontWeight.w300,
                fontFamily: "Inter",
                fontSize: 16,
              )),
          Row(
            children: [
              _buildPaginateButton(
                icon: Icons.arrow_back,
                label: 'Previous',
                onPressed: _currentPage > 1 ? () => setState(() => _currentPage--) : null,
              ),
              ..._buildPageNumbers(),
              _buildPaginateButton(
                icon: Icons.arrow_forward,
                label: 'Next',
                onPressed: _currentPage < _totalPages ? () => setState(() => _currentPage++) : null,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaginateButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: onPressed != null ? const Color(0xFF4F768E) : Colors.grey.shade300,
            width: 2,
          ),
        ),
        backgroundColor: onPressed != null ? const Color(0xFF4F768E) : Colors.grey.shade300,
        foregroundColor: onPressed != null ? Colors.white : Colors.black,
      ),
      child: Row(
        children: [
          Icon(icon, color: onPressed != null ? Colors.white : Colors.black),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: onPressed != null ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers() {
    List<Widget> pageWidgets = [];
    for (int i = 1; i <= _totalPages; i++) {
      if (i == 1 || i == _totalPages || (i - _currentPage).abs() <= 1) {
        pageWidgets.add(_pageNumberButton(i));
      } else if (pageWidgets.isEmpty ||
          (pageWidgets.last is! Text &&
              (pageWidgets.last as TextButton).child is! Text ||
              ((pageWidgets.last as TextButton).child as Text).data != "...")) {
        pageWidgets.add(
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0),
            child: Text("...", style: TextStyle(fontSize: 16)),
          ),
        );
      }
    }
    return pageWidgets;
  }

  Widget _pageNumberButton(int page) {
    final isSelected = page == _currentPage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextButton(
        onPressed: () => setState(() => _currentPage = page),
        style: TextButton.styleFrom(
          backgroundColor: isSelected ? const Color(0xFF4F768E) : Colors.white,
          foregroundColor: isSelected ? Colors.white : Colors.black,
          minimumSize: const Size(40, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: isSelected ? const Color(0xFF4F768E) : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          elevation: isSelected ? 2 : 0,
          shadowColor: isSelected ? Colors.black26 : null,
        ),
        child: Text(
          page.toString(),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

