import 'package:flutter/material.dart';
import 'package:rentxpert_flutter_web/service/usermanagement.dart';

class UserManagementLandlord extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementLandlord> {
  List<Map<String, dynamic>> userData = [];
  bool isLoading = true;
  int _rowsPerPage = 8;
  int _currentPage = 1;
  int _totalUsers = 0;
  int _totalPages = 0;
  String? _appliedFilter;
  String? editingUserId;
  Map<String, dynamic> editedUser = {};
  final TextEditingController _searchController = TextEditingController();

  final Map<String, String> _filterFieldMap = {
    'Name': 'fullname',
    'Email': 'email',
    'Address': 'address',
    'Phone Number': 'phone_number',
    'Valid ID': 'valid_id',
    'Account Status': 'account_status',
    'User Type': 'user_type',
  };

  @override
  void initState() {
    super.initState();
    loadUsers();
  }

  Future<void> loadUsers({int page = 1}) async {
    setState(() => isLoading = true);
    try {
      String? accountStatus;
      String? name;
      String? searchField;
      String? searchTerm;

      if (_appliedFilter != null && _searchController.text.isNotEmpty) {
        final filter = _appliedFilter!;
        final term = _searchController.text.trim();

        switch (filter) {
          case 'Account Status':
            accountStatus = term;
            break;
          case 'Name':
            name = term;
            break;
          default:
            searchField = _filterFieldMap[filter];
            searchTerm = term;
            break;
        }
      }

      final result = await UserManagementFetch.fetchUsers(
        userType: 'Landlord',
        page: page,
        limit: _rowsPerPage,
        accountStatus: accountStatus,
        name: name,
        searchField: searchField,
        searchTerm: searchTerm,
      );

      if (result != null) {
        setState(() {
          userData = result.users.map(_userToMap).toList();
          _totalUsers = result.total;
          _totalPages = result.totalPages;
          _currentPage = page;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching users: $e');
      setState(() => isLoading = false);
    }
  }

  Map<String, dynamic> _userToMap(UserData user) {
    return {
      'uid': user.uid,
      'email': user.email,
      'phone_number': user.phoneNumber,
      'fullname': user.fullName,
      'address': user.address,
      'valid_id': user.validId,
      'account_status': user.accountStatus,
      'user_type': user.userType,
    };
  }

  Future<void> _saveUserUpdates(String userId) async {
    try {
      final updatedUser = await UserManagementUpdate.updateUserDetails(
        payload: {
          'uid': userId,
          ...editedUser,
        },
      );

      if (updatedUser != null) {
        setState(() {
          final index = userData.indexWhere((u) => u['uid'] == userId);
          if (index != -1) {
            userData[index] = {...userData[index], ...updatedUser};
          }
          editingUserId = null;
          editedUser = {};
        });
        _showTopSnackBar("User updated successfully", false);
      } else {
        _showTopSnackBar("Failed to update user", true);
      }
    } catch (e) {
      _showTopSnackBar("Update error: ${e.toString()}", true);
    }
  }

  void _showTopSnackBar(String message, bool isError) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: MediaQuery.of(context).size.width / 2 - 150,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: isError ? Colors.red : Color(0xFF2E7D32),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(message, style: TextStyle(color: Colors.white)),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(Duration(seconds: 3), overlayEntry.remove);
  }

  void _showDeleteConfirmationDialog(String uid) {
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
              ),
              const SizedBox(height: 12),
              const Text(
                'Are you sure you want to delete?',
                style: TextStyle(
                    color: Color(0xFF979797),
                    fontSize: 18,
                    fontFamily: "Krub",
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: 170,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 4,
                          backgroundColor: Color(0xFFEDEDED)),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                          'Cancel',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.black)),
                    ),
                  ),
                  SizedBox(
                    width: 170,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 4,
                          backgroundColor: Color(0xFF79BD85)),
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteAccount(uid);
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

  Future<void> _deleteAccount(String uid) async {
    try {
      final success = await UserManagementDelete.deleteUser(uid);
      if (success) {
        await loadUsers();
        _showDeleteTopSnackBar("Account deleted successfully", true);
      } else {
        _showDeleteTopSnackBar("Failed to delete account", false);
      }
    } catch (e) {
      _showDeleteTopSnackBar("Delete error: ${e.toString()}", false);
    }
  }

  void _showDeleteTopSnackBar(String message, bool success) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: MediaQuery.of(context).size.width / 2 - 150,
        right: MediaQuery.of(context).size.width / 2 - 150,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: success ? Color(0xFF2E7D32) : Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(Duration(seconds: 3), () => overlayEntry.remove());
  }

  //Dialog for filter
  void _showFilterDialog() {
    // List of filter options
    final filterOptions = [
      'Name',
      'Email',
      'Address',
      'Phone Number',
      'Account Status',
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Initialize with the currently applied filter (if any)
        String? selectedOption = _appliedFilter;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
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
                        spacing: 16.0,
                        runSpacing: 16.0,
                        alignment: WrapAlignment.start,
                        children: filterOptions.map((option) {
                          final isSelected = selectedOption == option;
                          final isFixedSize = option == 'Phone Number' ||
                              option == 'Address' ||
                              option == 'Name' ||
                              option == 'Email' ||
                              option == 'Account Status';

                          return GestureDetector(
                            onTap: () {
                              setStateDialog(() {
                                selectedOption = isSelected ? null : option;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              width: isFixedSize ? 160.0 : null,
                              decoration: BoxDecoration(
                                color: isSelected ? const Color(0xFF4F768E) : Colors.white,
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: isSelected ? Colors.transparent : const Color(0xFF818181),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Krub",
                                    color: isSelected ? Colors.white : Colors.black,
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
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 17),
                    backgroundColor: const Color(0xFFFFFFFF),
                    foregroundColor: const Color(0xFF000000),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                      side: const BorderSide(
                        color: Color(0xFFC3C3C3),
                        width: 1,
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
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Update the parent widget's state
                    setState(() {
                      _appliedFilter = selectedOption;
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 17),
                    backgroundColor: const Color(0xFF9AD47F),
                    foregroundColor: const Color(0xFFFFFFFF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
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
            icon: _appliedFilter == null
                ? Image.asset(
              'assets/images/filter_icon.png',
              width: 55,
              height: 55,
            )
                : Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF4F768E),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                _appliedFilter!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontFamily: 'Krub',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            onPressed: _showFilterDialog,
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
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    _appliedFilter = null;
                    loadUsers();
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
              onSubmitted: (value) => loadUsers(),
            ),
          ),


        ),
      ],
    );
  }

  Widget _buildUserTable({Key? key}) {
    final columnTitles = ['Uid', 'Name', 'Email', 'Account Status', 'User Type', 'Customize'];
    const double columnWidth = 120;
    const double customizeColumnWidth = 260;

    return LayoutBuilder(
      key: key,
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          // Set a fixed height for the container (adjust as needed)
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0),
                child: SizedBox(
                  // Adjust height to account for padding
                  height: MediaQuery.of(context).size.height * 0.9 - 20,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columnSpacing: 24,
                      headingRowHeight: 56,
                      dataRowHeight: 60,
                      border: TableBorder.all(
                        color: Colors.grey.shade300,
                        width: 1,
                      ),
                      columns: columnTitles.map((title) => DataColumn(
                        label: SizedBox(
                          width: title == 'Customize' ? customizeColumnWidth : columnWidth,
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
                      )).toList(),
                      rows: userData.map((user) {
                        final isEditing = editingUserId == user['uid'];
                        return DataRow(cells: [
                          DataCell(SizedBox(
                            width: columnWidth,
                            child: Center(child: Text(user['uid']?.toString() ?? '')),
                          )),
                          _buildEditableCell(user, 'fullname', columnWidth),
                          _buildEditableCell(user, 'email', columnWidth),
                          DataCell(SizedBox(
                            width: columnWidth,
                            child: Center(child: Text(user['account_status'] ?? '')),
                          )),
                          DataCell(SizedBox(
                            width: columnWidth,
                            child: Center(child: Text(user['user_type'] ?? '')),
                          )),
                          DataCell(
                            SizedBox(
                              width: customizeColumnWidth,
                              child: Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isEditing) ...[
                                      TextButton.icon(
                                        onPressed: () => _saveUserUpdates(user['uid']),
                                        icon: const Icon(Icons.save, size: 15),
                                        label: const Text('Save'),
                                        style: _buttonStyle(Colors.green),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.cancel, color: Colors.red),
                                        onPressed: () => setState(() {
                                          editingUserId = null;
                                          editedUser = {};
                                        }),
                                      ),
                                    ] else ...[
                                      TextButton.icon(
                                        onPressed: () => setState(() {
                                          editingUserId = user['uid'];
                                          editedUser = Map.from(user);
                                        }),
                                        icon: const Icon(Icons.edit, size: 15),
                                        label: const Text('Edit'),
                                        style: _buttonStyle(const Color(0xFF4F768E)),
                                      ),
                                      const SizedBox(width: 13),
                                      IconButton(
                                        icon: Image.asset(
                                          'assets/images/white_delete.png',
                                          width: 30,
                                          height: 30,
                                        ),
                                        onPressed: () => _showDeleteConfirmationDialog(user['uid']),
                                      ),
                                      IconButton(
                                        icon: Image.asset(
                                          'assets/images/more_options.png',
                                          width: 55,
                                          height: 55,
                                        ),
                                        onPressed: () => _showUserDetailsDialog(user),
                                      ),
                                    ]
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
          ),
        );
      },
    );
  }

  DataCell _buildEditableCell(Map<String, dynamic> user, String field, double width) {
    final isEditing = editingUserId == user['uid'];
    return DataCell(
        SizedBox(
          width: width,
          child: isEditing
              ? TextFormField(
            initialValue: editedUser[field] ?? user[field],
            onChanged: (value) => editedUser[field] = value,
          )
              : Center(child: Text(user[field]?.toString() ?? '')),
        )
    );
  }

  Widget _buildActionButtons(Map<String, dynamic> user) {
    final isEditing = editingUserId == user['uid'];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isEditing) ...[
          TextButton.icon(
            onPressed: () => _saveUserUpdates(user['uid']),
            icon: Icon(
              Icons.save,
              size: 15,
              color: Colors.white, // Explicitly set the icon color to white
            ),
            label: Text('Save'),
            style: _buttonStyle(Colors.green),
          ),
          IconButton(
            icon: Icon(Icons.cancel, color: Colors.red),
            onPressed: () => setState(() {
              editingUserId = null;
              editedUser = {};
            }),
          ),
        ] else ...[
          TextButton.icon(
            onPressed: () => setState(() {
              editingUserId = user['uid'];
              editedUser = Map.from(user);
            }),
            icon: Icon(Icons.edit,
              size: 15,
              color: Colors.white, // Added white color
            ),
            label: Text('Edit',
              style: TextStyle(
                color: Colors.white, // Ensure text is white
              ),
            ),
            style: _buttonStyle(const Color(0xFF4F768E)),
          ),
          IconButton(
            icon: Image.asset('assets/images/white_delete.png', width: 30),
            onPressed: () => _showDeleteConfirmationDialog(user['uid']),
          ),
          IconButton(
            icon: Image.asset('assets/images/more_options.png', width: 55),
            onPressed: () => _showUserDetailsDialog(user),
          ),
        ]
      ],
    );
  }

  ButtonStyle _buttonStyle(Color color) => TextButton.styleFrom(
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    backgroundColor: color,
    foregroundColor: Colors.white, // This affects both icon and text color
  );



  void _showUserDetailsDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        contentPadding: const EdgeInsets.all(20), // Add some padding
        content: SizedBox(
          width: 800,
          height: 400,
          child: Stack(
            children: [
              // The Back Arrow (Positioned at the top-right corner)
              Positioned(
                top: 5.0,
                right: 5.0,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0, right: 20.0),
                  child: IconButton(
                    icon: Image.asset(
                      'assets/images/back_image.png',
                      width: 30,
                      height: 30,
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),


              // Row to slice the container in half (User Details on Left, Valid ID on Right)
              Row(
                children: [
                  // Left section: User Details
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "User Details",
                            style: TextStyle(
                              color: Color(0xFF4F768E),
                              fontFamily: "Krub",
                              fontWeight: FontWeight.bold,
                              fontSize: 35,
                            ),
                          ),


                          const SizedBox(height: 20),


                          Padding(
                            padding: const EdgeInsets.only(top: 30.0, left: 30.0), // Smaller, more responsive padding
                            child: SingleChildScrollView(
                              child: ConstrainedBox(
                                constraints: BoxConstraints(
                                  minHeight: 0,
                                  maxHeight: 350, // or any maxHeight that fits inside your container
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _infoRow("Name", user['fullname']),
                                    SizedBox(height: 10),
                                    _infoRow("Phone Number", user['phone_number']),
                                    SizedBox(height: 10),
                                    _infoRow("Address", user['address']),
                                  ],
                                ),
                              ),
                            ),
                          )


                        ],
                      ),
                    ),
                  ),


                  // Right section: Valid ID Image
                  Expanded(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: user['valid_id'] != null
                            ? Image.network(
                          user['valid_id'], // Assuming valid_id holds the image URL
                          fit: BoxFit.cover,
                          width: 200,
                          height: 200,
                        )
                            : const Icon(
                          Icons.image_not_supported, // Fallback icon
                          size: 100,
                          color: Colors.grey,
                        ),
                      ),
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
          Text(
            "Showing ${_rowsPerPage} of  $_totalUsers results",
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontFamily: "Inter",
              fontSize: 16,
            ),
          ),
          Row(
            children: [
              _buildPaginateButton(
                icon: Icons.arrow_back,
                label: 'Previous',
                onPressed: _currentPage > 1 ? () => loadUsers(page: _currentPage - 1) : null,
              ),
              ..._buildPageNumbers(),
              _buildPaginateButton(
                icon: Icons.arrow_forward,
                label: 'Next',
                onPressed: _currentPage < _totalPages ? () => loadUsers(page: _currentPage + 1) : null,
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
      } else {
        // Check if we already added an ellipsis
        if (pageWidgets.isNotEmpty &&
            pageWidgets.last is Padding) {
          continue;
        }
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
        onPressed: () {
          setState(() => _currentPage = page);
          loadUsers(page: page); // Add this line
        },
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

