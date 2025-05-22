import 'package:flutter/material.dart';
import 'package:rentxpert_flutter_web/service/usermanagement.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';


class UserManagementTenant extends StatefulWidget {
  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementTenant> {
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

 // Helper method to calculate the ending index of the current page
  int get _endIndex {
    final end = _currentPage * _rowsPerPage;
    return end > _totalUsers ? _totalUsers : end;
  }


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
        userType: 'Tenant',
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
      'ID': user.ID,
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


  // Update / Edit user Snackbar
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
        _showUpdateTUserSnackBar("User account updated successfully", false);
      } else {
        _showUpdateTUserSnackBar("Failed to update user", true);
      }
    } catch (e) {
      _showUpdateTUserSnackBar("Update error: ${e.toString()}", true);
    }
  }


  //Update / edit snackbar style
  void _showUpdateTUserSnackBar(String message, bool isError) {
    final overlay = Overlay.of(context);
    final screenSize = MediaQuery.of(context).size;
    const double snackbarWidth = 300;
    const double snackbarHeight = 80;

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: screenSize.width / 2 - snackbarWidth / 2,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: snackbarWidth,
            height: snackbarHeight,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: isError ? Colors.red : Colors.green,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: "Inter",
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), overlayEntry.remove);
  }



  //Delete Confirmation Dialog
  void _showDeleteConfirmationDialog(String uid) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
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
              Text(
                'Delete',
                style: TextStyle(
                    color: isDarkMode ? Colors.white:Color(0xFF000000),
                    fontSize: 25,
                    fontFamily: "Krub",
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete?',
                style: TextStyle(
                    color:  isDarkMode ? Colors.white:Color(0xFF979797),
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

  //Delete User Snackbar
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


  //Delete Snackbar style
  void _showDeleteTopSnackBar(String message, bool success) {
    final overlay = Overlay.of(context);
    final screenSize = MediaQuery.of(context).size;
    const double snackbarWidth = 300;
    const double snackbarHeight = 80;

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: MediaQuery.of(context).size.width / 2 - 150,
        right: MediaQuery.of(context).size.width / 2 - 150,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: snackbarWidth,
            height: snackbarHeight,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: success ? Colors.red : Colors.red,
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
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
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
              backgroundColor: isDarkMode ? Colors.grey[800] : Color(0xFFFFFFFF),
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
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey[900] : const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "User Management: Tenant",
              style: TextStyle(
                fontSize: 45,
                fontFamily: "Inter",
                color: isDarkMode ? Colors.white : const Color(0xFF4F768E),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            _buildSearchBar(isDarkMode),
            const SizedBox(height: 20),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildUserTable(isDarkMode, key: ValueKey(_currentPage)),
              ),
            ),
            const SizedBox(height: 20),
            _buildPaginationBar(isDarkMode),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(bool isDarkMode) {
    return Row(
      children: [
        FittedBox(
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
          width: MediaQuery.of(context).size.width * 0.3,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 200, maxWidth: 400),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search, color: isDarkMode ? Colors.white70 : Colors.black54),
                suffixIcon: IconButton(
                  icon: Icon(Icons.close, color: isDarkMode ? Colors.white70 : Colors.black54),
                  onPressed: () {
                    _searchController.clear();
                    _appliedFilter = null;
                    loadUsers();
                  },
                ),
                hintText: 'Search...',
                hintStyle: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                filled: true,
              ),
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
              onSubmitted: (value) => loadUsers(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUserTable(bool isDarkMode, {Key? key}) {
    final columnTitles = ['Uid', 'Name', 'Email', 'Account Status', 'User Type', 'Customize'];
    const double columnWidth = 120;
    const double customizeColumnWidth = 260;

    return LayoutBuilder(
      key: key,
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey[800] : Colors.white,
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
                  height: MediaQuery.of(context).size.height * 0.9 - 20,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.vertical,
                    child: DataTable(
                      columnSpacing: 24,
                      headingRowHeight: 56,
                      dataRowHeight: 60,
                      border: TableBorder.all(
                        color: isDarkMode ? Colors.grey[600]! : Colors.grey.shade300,
                        width: 1,
                      ),
                      columns: columnTitles.map((title) => DataColumn(
                        label: SizedBox(
                          width: title == 'Customize' ? customizeColumnWidth : columnWidth,
                          child: Center(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontFamily: "Krub",
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: isDarkMode ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      )).toList(),
                      rows: userData.map((user) {
                        final isEditing = editingUserId == user['uid'];
                        return DataRow(
                          color: MaterialStateProperty.resolveWith<Color?>(
                                (Set<MaterialState> states) {
                              if (isDarkMode) {
                                return states.contains(MaterialState.hovered)
                                    ? Colors.grey[700]
                                    : Colors.grey[800];
                              }
                              return null;
                            },
                          ),
                          cells: [
                            DataCell(SizedBox(
                              width: columnWidth,
                              child: Center(child: Text(user['uid']?.toString() ?? '', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
                            )),
                            _buildEditableCell(user, 'fullname', columnWidth, isDarkMode),
                            _buildEditableCell(user, 'email', columnWidth, isDarkMode),
                            DataCell(SizedBox(
                              width: columnWidth,
                              child: Center(child: Text(user['account_status'] ?? '', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
                            )),
                            DataCell(SizedBox(
                              width: columnWidth,
                              child: Center(child: Text(user['user_type'] ?? '', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
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
                                          icon: const Icon(Icons.save, size: 15, color: Colors.white),
                                          label: const Text('Save', style: TextStyle(color: Colors.white)),
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
                                          icon: const Icon(Icons.edit, size: 15, color: Colors.white),
                                          label: const Text('Edit', style: TextStyle(color: Colors.white)),
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
                                          onPressed: () => showStatusBasedDialog(user), // New method names
                                        ),
                                      ]
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
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

  DataCell _buildEditableCell(Map<String, dynamic> user, String field, double width, bool isDarkMode) {
    final isEditing = editingUserId == user['uid'];
    return DataCell(
        SizedBox(
          width: width,
          child: isEditing
              ? TextFormField(
            initialValue: editedUser[field] ?? user[field],
            onChanged: (value) => editedUser[field] = value,
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          )
              : Center(child: Text(user[field]?.toString() ?? '', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black))),
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
            onPressed: () => showStatusBasedDialog(user), // New method name
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

  void showStatusBasedDialog(Map<String, dynamic> user) {
    if (user['account_status'] == 'Pending') {
      _showPendingDialog(user);
    } else if (user['account_status'] == 'Unverified') {
      _showUnverifiedDialog(user);
    }
  }

  void _showUnverifiedDialog(Map<String, dynamic> user) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            content: SizedBox(
              width: 400,
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "User Details",
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Color(0xFF4F768E),
                            fontFamily: "Krub",
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                        const SizedBox(height: 40),
                        Padding(
                          padding: const EdgeInsets.only(left: 53.0),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: _infoRow("Name", user['fullname'], isDarkMode),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: _infoRow("Phone Number", user['phone_number'], isDarkMode),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: _infoRow("Address", user['address'], isDarkMode),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: _infoRow("Valid ID", user['valid_id'], isDarkMode),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: Image.asset(
                        'assets/images/back_image.png',
                        width: 20,
                        height: 20,
                        color: isDarkMode ? Colors.white : null,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  void _showPendingDialog(Map<String, dynamic> user) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    showDialog(
      context: context,
      builder: (context) {
        bool isVerified = false;
        bool isRejected = false;
        bool isProcessing = false;

        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            contentPadding: const EdgeInsets.all(20),
            content: SizedBox(
              width: 800,
              height: 500,
              child: Stack(
                children: [
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
                  Column(
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "User Details",
                                      style: TextStyle(
                                        color: isDarkMode ? Colors.white : Color(0xFF4F768E),
                                        fontFamily: "Krub",
                                        fontWeight: FontWeight.bold,
                                        fontSize: 35,
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 30.0, left: 30.0),
                                      child: SingleChildScrollView(
                                        child: ConstrainedBox(
                                          constraints: BoxConstraints(
                                            minHeight: 0,
                                            maxHeight: 350,
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Align(
                                                alignment: Alignment.center,
                                                child: _infoRow("ID", int.parse(user['ID'].toString()).toString(), isDarkMode),
                                              ),
                                              Align(
                                                alignment: Alignment.center,
                                                child: _infoRow("Name", user['fullname'], isDarkMode),
                                              ),
                                              Align(
                                                alignment: Alignment.center,
                                                child: _infoRow("Phone Number", user['phone_number'], isDarkMode),
                                              ),
                                              Align(
                                                alignment: Alignment.center,
                                                child: _infoRow("Address", user['address'], isDarkMode),
                                              ),
                                              Align(
                                                alignment: Alignment.center,
                                                child: _infoRow("Valid ID", user['valid_id'], isDarkMode),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Expanded(
                            //   flex: 1,
                            //   child: Padding(
                            //     padding: const EdgeInsets.all(20),
                            //     child: Center(
                            //
                            //       child: user['valid_id'] != null
                            //           ? Image.network(
                            //         user['valid_id'],
                            //         fit: BoxFit.cover,
                            //         width: 200,
                            //         height: 200,
                            //       )
                            //           : const Icon(
                            //         Icons.image_not_supported,
                            //         size: 100,
                            //         color: Colors.grey,
                            //       ),
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: (user['account_status'] != 'Pending' || isProcessing)
                                  ? Colors.grey
                                  : const Color(0xFF79BD85),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              minimumSize: const Size(150, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: (user['account_status'] != 'Pending' || isProcessing)
                                ? null
                                : () async {
                              // Your backend handling code here
                              setState(() => isProcessing = true);
                              final userId =  int.parse(user['ID'].toString()).toString();

                              if (userId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("User ID is missing."),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                                setState(() => isProcessing = false);
                                return;
                              }

                              final success = await UserManagementStatus.verifyLandlordViaAdmin(user['uid']);

                              setState(() => isProcessing = false);

                              if (success) {
                                _showApproveTopSnackBar("User verified successfully");
                                _showSuccessrSnackBar("User verified successfully");
                                await loadUsers();
                                Navigator.of(context).pop();
                              } else {
                                _showErrorSnackBar("Failed to verify user");
                              }
                            },
                            child: Text(
                              isVerified ? "Verified" : "Verify",
                              style: const TextStyle(
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: (user['account_status'] != 'Pending' || isProcessing)
                                  ? Colors.grey
                                  : const Color(0xFFDE5959),
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                              minimumSize: const Size(150, 50),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: (user['account_status'] != 'Pending' || isProcessing)
                                ? null
                                : () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  final TextEditingController _messageController = TextEditingController();
                                  return AlertDialog(
                                    backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    title: Text(
                                      "Reject Landlord",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20,
                                        fontFamily: "Krub",
                                        color: isDarkMode ? Colors.white : const Color(0xFF4F768E),
                                      ),
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          "Please provide a reason for rejection:",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            fontFamily: "Inter",
                                            color: isDarkMode ? Colors.white : Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 10),
                                        TextField(
                                          controller: _messageController,
                                          maxLines: 3,
                                          decoration: InputDecoration(
                                            border: const OutlineInputBorder(),
                                            hintText: "Type your message here...",
                                            hintStyle: TextStyle(
                                              fontFamily: "Inter",
                                              fontSize: 14,
                                              color: isDarkMode ? Colors.grey[400] : Colors.grey,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                          style: TextStyle(
                                            color: isDarkMode ? Colors.white : Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: Text(
                                          "Cancel",
                                          style: TextStyle(
                                            fontFamily: "Inter",
                                            fontSize: 16,
                                            color: isDarkMode ? Colors.white : const Color(0xFF4F768E),
                                          ),
                                        ),
                                      ),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isDarkMode
                                              ? Colors.blueGrey
                                              : const Color(0xFF4F768E),
                                        ),
                                        onPressed: () async {
                                          final message = _messageController.text.trim();
                                          if (message.isEmpty) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                content: Text("Message cannot be empty"),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                            return;
                                          }
                                          Navigator.pop(context); // Close dialog
                                          if (!mounted) return;
                                          setState(() => isProcessing = true);
                                          try {
                                            final userId = user['uid'];
                                            if (userId == null || userId.isEmpty) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text("User UID is missing or invalid."),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                              return;
                                            }

                                            final result = await UserManagementRejection.rejectLandlordRequest(
                                              uid: userId,
                                              rejectionReason: message, // Use dynamic message
                                            );

                                            if (result.success) {
                                              _showRejectTopSnackBar(result.message);
                                              await loadUsers();
                                              if (mounted) Navigator.of(context).pop(); // Close any bottom sheet
                                            } else {
                                              _showErrorSnackBar(result.message);
                                            }
                                          } catch (e) {
                                            _showErrorSnackBar("Operation failed: ${e.toString()}");
                                          } finally {
                                            if (mounted) setState(() => isProcessing = false);
                                          }
                                        },
                                        child: const Text(
                                          "Submit",
                                          style: TextStyle(
                                            fontFamily: "Inter",
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },

                            child: Text(
                              isRejected ? "Rejected" : "Reject",
                              style: const TextStyle(
                                fontFamily: "Inter",
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  //Approve Snackbar style
  void _showApproveTopSnackBar(String message) {
    final overlay = Overlay.of(context);
    final screenSize = MediaQuery.of(context).size;
    const double snackbarWidth = 300;
    const double snackbarHeight = 80;

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,  // Adjust the top value as per your needs
        left: MediaQuery.of(context).size.width / 2 - 150, // Center the snackbar
        right: MediaQuery.of(context).size.width / 2 - 150,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: snackbarWidth,
            height: snackbarHeight,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.green,
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
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessrSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }
  //Reject Snackbar style
  void _showRejectTopSnackBar(String message) {
    final overlay = Overlay.of(context);
    final screenSize = MediaQuery.of(context).size;
    const double snackbarWidth = 300;
    const double snackbarHeight = 80;

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,  // Adjust the top value as per your needs
        left: MediaQuery.of(context).size.width / 2 - 150, // Center the snackbar
        right: MediaQuery.of(context).size.width / 2 - 150,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: snackbarWidth,
            height: snackbarHeight,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red,
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
// Updated _infoRow with dark mode support
  Widget _infoRow(String label, String? value, bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              "$label:",
              style: TextStyle(
                fontFamily: "Inter",
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '',
              style: TextStyle(
                fontFamily: "Inter",
                fontSize: 16,
                color: isDarkMode ? Colors.white : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }



  Widget _buildPaginationBar(bool isDarkMode) {
    return Padding(
      padding: const EdgeInsets.only(right: 60.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Showing ${_endIndex} of $_totalUsers results",
            style: TextStyle(
              fontWeight: FontWeight.w300,
              fontFamily: "Inter",
              fontSize: 16,
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          Row(
            children: [
              _buildPaginateButton(
                icon: Icons.arrow_back,
                label: 'Previous',
                onPressed: _currentPage > 1 ? () => loadUsers(page: _currentPage - 1) : null,
                isDarkMode: isDarkMode,
              ),
              ..._buildPageNumbers(isDarkMode),
              _buildPaginateButton(
                icon: Icons.arrow_forward,
                label: 'Next',
                onPressed: _currentPage < _totalPages ? () => loadUsers(page: _currentPage + 1) : null,
                isDarkMode: isDarkMode,
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
    required bool isDarkMode,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: onPressed != null
                ? const Color(0xFF4F768E)
                : isDarkMode ? Colors.grey[600]! : Colors.grey.shade300,
            width: 2,
          ),
        ),
        backgroundColor: onPressed != null
            ? const Color(0xFF4F768E)
            : isDarkMode ? Colors.grey[700] : Colors.grey.shade300,
        foregroundColor: onPressed != null
            ? Colors.white
            : isDarkMode ? Colors.white : Colors.black,
      ),
      child: Row(
        children: [
          Icon(icon, color: onPressed != null ? Colors.white : isDarkMode ? Colors.white : Colors.black),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: onPressed != null ? Colors.white : isDarkMode ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPageNumbers(bool isDarkMode) {
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

