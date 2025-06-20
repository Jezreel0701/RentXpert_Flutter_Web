import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:rentxpert_flutter_web/service/propertymanagement.dart';
import 'package:rentxpert_flutter_web/service/usermanagement.dart';
import 'theme_provider.dart';

class PropertiesManagementScreen extends StatefulWidget {
  @override
  _PropertiesManagementScreenState createState() =>
      _PropertiesManagementScreenState();
}

class _PropertiesManagementScreenState
    extends State<PropertiesManagementScreen> {
  List<Map<String, dynamic>> apartmentData = [];
  bool isLoading = false;
  int _rowsPerPage = 8;
  int _currentPage = 1;
  int _totalApartments = 0;
  String? _appliedFilter;
  String? editingUserId;
  Map<String, dynamic> editedUser = {};
  final TextEditingController _searchController = TextEditingController();

  // Controllers for editing
  final TextEditingController _landlordController = TextEditingController();
  final TextEditingController _rentPriceController = TextEditingController();
  final TextEditingController _landmarksController = TextEditingController();

  Map<String, dynamic> _editedApartment = {};

  @override
  void initState() {
    super.initState();
    _fetchApartments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchApartments() async {
    setState(() => isLoading = true);
    try {
      final result = await ApartmentManagementFetch.fetchApartments(
        page: _currentPage,
        limit: _rowsPerPage,
        propertyName:
        _appliedFilter == 'Property Name' ? _searchController.text : null,
        landlordName:
        _appliedFilter == 'Landlord' ? _searchController.text : null,
        status: _appliedFilter == 'Status' ? _searchController.text : null,
        propertyType:
        _appliedFilter == 'Property Type' ? _searchController.text : null,
        uid: _appliedFilter == 'UID' ? _searchController.text : null,
      );

      if (result != null) {
        setState(() {
          apartmentData = result.apartments
              .map((apartment) => {
            'ID': apartment.id.toString(),
            'Uid': apartment.uid,
            'PropertyName': apartment.propertyName,
            'PropertyType': apartment.propertyType,
            'Status': apartment.status,
            'landlord_name': apartment.landlordName,
            'Rent_Price': apartment.rentPrice.toStringAsFixed(2),
            'Landmarks': apartment.landmarks,
            'Allowed_Gender': apartment.allowedGender,
            'Availability': apartment.availability,
          })
              .toList();
          _totalApartments = result.total;
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
        // Handle error if needed
      }
    } catch (e) {
      setState(() => isLoading = false);
      // Handle error if needed
    }
  }

  int get _endIndex {
    final end = _currentPage * _rowsPerPage;
    return end > _totalApartments ? _totalApartments : end;
  }

  int get _totalPages => (_totalApartments / _rowsPerPage).ceil();

  void _showDeleteConfirmationDialog(String apartmentId) {
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
                    color: isDarkMode ? Colors.white : Color(0xFF000000),
                    fontSize: 25,
                    fontFamily: "Krub",
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Text(
                'Are you sure you want to delete?',
                style: TextStyle(
                    color: isDarkMode ? Colors.white : Color(0xFF979797),
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
                          elevation: 4, backgroundColor: Color(0xFFEDEDED)),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel',
                          style: TextStyle(fontSize: 20, color: Colors.black)),
                    ),
                  ),
                  SizedBox(
                    width: 170,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 4, backgroundColor: Color(0xFF79BD85)),
                      onPressed: () {
                        Navigator.pop(context);
                        _deleteApartment(apartmentId);
                      },
                      child: const Text('Confirm',
                          style: TextStyle(fontSize: 20, color: Colors.white)),
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

  Future<void> _deleteApartment(String id) async {
    final success = await ApartmentManagementDelete.deleteApartment(id);
    if (success) {
      _showDeleteTopSnackBar("Apartment deleted successfully");
      _fetchApartments();
    } else {
      _showErrorSnackBar("Failed to delete apartment");
    }
  }

  void _showDeleteTopSnackBar(String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: MediaQuery.of(context).size.width / 2 - 150,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 300,
            height: 80,
            decoration: BoxDecoration(
                color: Colors.green, borderRadius: BorderRadius.circular(10)),
            child: Center(
                child: Text(message, style: TextStyle(color: Colors.white))),
          ),
        ),
      ),
    );
    overlay.insert(overlayEntry);
    Future.delayed(Duration(seconds: 3), () => overlayEntry.remove());
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessRejectSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showApproveTopSnackBar(String message) {
    final overlay = Overlay.of(context);
    const double snackbarWidth = 300; // Define the snackbar width
    const double snackbarHeight = 80; // Define the snackbar height
    const double screenWidth = 1149; // Fixed screen width for centering

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50, // Adjust the vertical position as needed
        left: ((screenWidth - snackbarWidth) / 2) - 50, // Center horizontally for 1149px screen
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: snackbarWidth,
            height: snackbarHeight,
            decoration: BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () => overlayEntry.remove());
  }

  void _showRejectTopSnackBar(String message) {
    final overlay = Overlay.of(context);
    const double snackbarWidth = 300; // Define the snackbar width
    const double snackbarHeight = 80; // Define the snackbar height
    const double screenWidth = 1149; // Fixed screen width for centering

    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50, // Adjust the vertical position as needed
        left: ((screenWidth - snackbarWidth) / 2) - 50, // Center horizontally for 1149px screen
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: snackbarWidth,
            height: snackbarHeight,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 3), () => overlayEntry.remove());
  }

  void _showFilterDialog() {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    final filterOptions = [
      'Landlord',
      'UID',
      'Property Name',
      'Property Type',
      'Status',
    ];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? selectedOption = _appliedFilter;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              content: SizedBox(
                width: 400,
                height: 250,
                child: SingleChildScrollView(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 50.0),
                      child: Wrap(
                        spacing: 16.0,
                        runSpacing: 16.0,
                        alignment: WrapAlignment.start,
                        children: filterOptions.map((option) {
                          final isSelected = selectedOption == option;
                          final isFixedSize = [
                            'Landlord',
                            'UID',
                            'Property Name',
                            'Property Type',
                            'Status'
                          ].contains(option);

                          return GestureDetector(
                            onTap: () => setStateDialog(() =>
                            selectedOption = isSelected ? null : option),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              width: isFixedSize ? 160.0 : null,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? (isDarkMode
                                    ? Colors.blueGrey
                                    : const Color(0xFF4F768E))
                                    : (isDarkMode ? Colors.grey[700] : Colors.white),
                                borderRadius: BorderRadius.circular(30),
                                border: Border.all(
                                  color: isSelected
                                      ? Colors.transparent
                                      : (isDarkMode
                                      ? Colors.grey[500]!
                                      : const Color(0xFF818181)),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Krub",
                                    color: isSelected
                                        ? Colors.white
                                        : (isDarkMode ? Colors.white : Colors.black),
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
                  onPressed: () => Navigator.pop(context),
                  style: _filterButtonStyle(
                    isDarkMode ? Colors.grey[700]! : Colors.white,
                    isDarkMode ? Colors.white : Colors.black,
                  ),
                  child: const Text('Cancel', style: _filterTextStyle),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _appliedFilter = selectedOption;
                      _currentPage = 1;
                    });
                    _fetchApartments();
                  },
                  // style: _filterButtonStyle(
                  //     isDarkMode ? Colors.green[700]! : const Color(0xFF9AD47F),
                  //   Colors.white,
                  // ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 17),
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: const Text('Apply filters', style: _filterTextStyle),
                ),
              ],
            );
          },
        );
      },
    );
  }

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
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth <= 600 || constraints.maxHeight <= 600;

          return isSmallScreen
              ? SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: _buildContent(context, isDarkMode, isSmallScreen, constraints),
            ),
          )
              : _buildContent(context, isDarkMode, isSmallScreen, constraints);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDarkMode, bool isSmallScreen, BoxConstraints constraints) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Properties Management: Apartments",
            style: TextStyle(
              fontSize: isSmallScreen ? 32 : 45,
              fontFamily: "Inter",
              color: isDarkMode ? Colors.white : const Color(0xFF4F768E),
              fontWeight: FontWeight.w600,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 20),
          _buildSearchBar(),
          const SizedBox(height: 20),
          Flexible(
            fit: isSmallScreen ? FlexFit.loose : FlexFit.tight,
            child: Container(
              constraints: BoxConstraints(
                maxHeight: isSmallScreen ? constraints.maxHeight * 0.7 : constraints.maxHeight * 0.9,
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildUserTable(key: ValueKey(_currentPage)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          if (!isSmallScreen) _buildPaginationBar(isDarkMode),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Row(
      children: [
        IconButton(
          icon: _appliedFilter == null
              ? Image.asset(
            'assets/images/filter_icon.png',
            width: 55,
            height: 55,
          )
              : Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey[700] : const Color(0xFF4F768E),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Text(
              _appliedFilter!,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Krub',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          onPressed: _showFilterDialog,
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.3,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: 200,
              maxWidth: 400,
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _appliedFilter = null);
                    _fetchApartments();
                  },
                ),
                hintText: 'Search...',
                hintStyle: TextStyle(
                  color: isDarkMode ? Colors.white70 : Colors.black54,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                filled: true,
              ),
              style: TextStyle(
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              onSubmitted: (value) => _fetchApartments(),
            ),
          ),
        ),
      ],
    );
  }

  ButtonStyle _filterButtonStyle(Color bgColor, Color textColor) {
    return TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 17),
      backgroundColor: bgColor,
      foregroundColor: textColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: bgColor == Colors.white
            ? const BorderSide(color: Color(0xFFC3C3C3), width: 1)
            : BorderSide.none,
      ),
    );
  }

  static const TextStyle _filterTextStyle = TextStyle(
    fontSize: 19,
    fontFamily: "Krub",
    fontWeight: FontWeight.w500,
  );

  Widget _buildUserTable({Key? key}) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;
    final columnTitles = [
      'UID',
      'Property Name',
      'Property Type',
      'Status',
      'Customize',
    ];
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
          child: apartmentData.isEmpty
              ? Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                "No data available",
                style: TextStyle(
                  fontSize: 18,
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontFamily: "Inter",
                ),
              ),
            ),
          )
              : SingleChildScrollView(
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
                      rows: apartmentData.map((apartment) {
                        final isEditing = editingUserId == apartment['ID'];
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
                              child: Center(
                                child: Text(
                                  apartment['Uid'] ?? '',
                                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                                ),
                              ),
                            )),
                            DataCell(SizedBox(
                              width: columnWidth,
                              child: isEditing
                                  ? TextFormField(
                                initialValue: editedUser['PropertyName'] ?? apartment['PropertyName'] ?? '',
                                onChanged: (value) => editedUser['PropertyName'] = value,
                                style: TextStyle(color: isDarkMode ? Colors.white : Colors.black, fontSize: 14),
                              )
                                  : Center(
                                child: Text(
                                  apartment['PropertyName'] ?? '',
                                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                                ),
                              ),
                            )),
                            DataCell(SizedBox(
                              width: 150, // Constrain the width of the dropdown
                              child: isEditing
                                  ? DropdownButtonFormField<String>(
                                      value: editedUser['PropertyType'] ?? apartment['PropertyType'] ?? '',
                                      items: const [
                                        DropdownMenuItem(
                                          value: 'BoardingHouse',
                                          child: Center(child: Text('Boarding House')), // Center the text
                                        ),
                                        DropdownMenuItem(
                                          value: 'Condo',
                                          child: Center(child: Text('Condo')), // Center the text
                                        ),
                                        DropdownMenuItem(
                                          value: 'Apartment',
                                          child: Center(child: Text('Apartment')), // Center the text
                                        ),
                                        DropdownMenuItem(
                                          value: 'Transient',
                                          child: Center(child: Text('Transient')), // Center the text
                                        ),
                                      ],
                                      onChanged: (value) {
                                        if (value != null) {
                                          setState(() {
                                            editedUser['PropertyType'] = value;
                                          });
                                        }
                                      },
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(),
                                        contentPadding: EdgeInsets.symmetric(horizontal: 8),
                                      ),
                                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                                      dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
                                      isExpanded: true, // Ensures the dropdown takes full width
                                      alignment: Alignment.center, // Centers the icon
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        color: isDarkMode ? Colors.white : Colors.black,
                                      ),
                                      iconSize: 24,

                              )
                                  : Center(
                                      child: Text(
                                        apartment['PropertyType'] ?? '',
                                        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                                      ),
                                    ),
                            )),

                            DataCell(SizedBox(
                              width: columnWidth,
                              child: Center(
                                child: Text(
                                  apartment['Status'] ?? '',
                                  style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                                ),
                              ),
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
                                          onPressed: () async {
                                            final index = apartmentData.indexWhere(
                                                    (u) => u['ID'] == apartment['ID']);
                                            if (index != -1) {
                                              setState(() => isLoading = true);
                                              try {
                                                final rentPrice = double.tryParse(
                                                    apartmentData[index]['Rent_Price'] ?? '0');
                                                if (rentPrice == null) {
                                                  _showErrorSnackBar("Invalid rent price format");
                                                  return;
                                                }
                                                final success = await ApartmentManagementUpdate.updateApartment(
                                                  id: apartment['ID'],
                                                  propertyName: editedUser['PropertyName'] ?? apartment['PropertyName'],
                                                  propertyType: editedUser['PropertyType'] ?? apartment['PropertyType'],
                                                  rentPrice: rentPrice,
                                                  landmarks: apartment['Landmarks'],
                                                  allowedGender: apartment['Allowed_Gender'],
                                                  availability: apartment['Availability'],
                                                );
                                                if (success) {
                                                  _showSuccessSnackBar("Apartment updated successfully");
                                                  await _fetchApartments();
                                                } else {
                                                  _showErrorSnackBar("Update failed. Check server logs.");
                                                }
                                              } catch (e) {
                                                _showErrorSnackBar("Update error: ${e.toString()}");
                                              } finally {
                                                setState(() {
                                                  isLoading = false;
                                                  editingUserId = null;
                                                  editedUser = {};
                                                });
                                              }
                                            }
                                          },
                                          icon: const Icon(Icons.save, size: 15, color: Colors.white),
                                          label: const Text('Save', style: TextStyle(color: Colors.white)),
                                          style: _buttonStyle(Colors.green),
                                        ),
                                        const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.cancel, color: Colors.red),
                                          onPressed: () {
                                            setState(() {
                                              editingUserId = null;
                                              editedUser = {};
                                            });
                                          },
                                        ),
                                      ] else ...[
                                        TextButton.icon(
                                          onPressed: () {
                                            setState(() {
                                              editingUserId = apartment['ID'];
                                              editedUser = Map<String, dynamic>.from(apartment);
                                            });
                                          },
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
                                          onPressed: () => _showDeleteConfirmationDialog(apartment['ID']),
                                        ),
                                        IconButton(
                                          icon: Image.asset(
                                            'assets/images/more_options.png',
                                            width: 55,
                                            height: 55,
                                          ),
                                          onPressed: () => _showUserDetailsDialog(apartment),
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

  ButtonStyle _buttonStyle(Color color) {
    return TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      backgroundColor: color,
      foregroundColor: Colors.white,
    );
  }

  Widget _infoRow(String label, String? value, bool isDarkMode, {bool isEditing = false}) {
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
                decoration: isEditing ? TextDecoration.underline : TextDecoration.none,
                decorationColor: Colors.blue,
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
            "Showing ${_endIndex} of $_totalApartments results",
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
                onPressed: _currentPage > 1
                    ? () {
                  setState(() {
                    _currentPage--;
                  });
                  _fetchApartments();
                }
                    : null,
                isDarkMode: isDarkMode,
              ),
              ..._buildPageNumbers(isDarkMode),
              _buildPaginateButton(
                icon: Icons.arrow_forward,
                label: 'Next',
                onPressed: _currentPage < _totalPages
                    ? () {
                  setState(() {
                    _currentPage++;
                  });
                  _fetchApartments();
                }
                    : null,
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
    if (MediaQuery.of(context).size.width <= 600) {
      return const SizedBox.shrink();
    }

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
        if (pageWidgets.isNotEmpty && pageWidgets.last is Padding) {
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
          _fetchApartments();
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

  void _showUserDetailsDialog(Map<String, dynamic> apartment) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;
    String? selectedAvailability = apartment['Availability'];
    String? selectedGender = apartment['Allowed_Gender'];
    final List<String> availabilityOptions = ['Available', 'Not Available'];
    final List<String> genderOptions = ['Male', 'Female', 'Other'];
    final TextEditingController _rentPriceController = TextEditingController();
    final TextEditingController _landmarksController = TextEditingController();


    showDialog(
      context: context,
      builder: (context) {
        bool isApproved = apartment['Status'] == 'Approved';
        bool isRejected = apartment['Status'] == 'Rejected';
        bool isProcessing = false;
        bool isEditing = false;


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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Apartment Details",
                              style: TextStyle(
                                color: isDarkMode ? Colors.white : const Color(0xFF4F768E),
                                fontFamily: "Krub",
                                fontWeight: FontWeight.bold,
                                fontSize: 25,
                              ),
                            ),
                            Row(
                              children: [
                                if (isEditing)
                                  TextButton(
                                    onPressed: () async {
                                      final rentPriceText = _rentPriceController.text;


                                      if (rentPriceText.isEmpty) {
                                        _showErrorSnackBar("Rent price cannot be empty");
                                        return;
                                      }


                                      final rentPrice = double.tryParse(rentPriceText);
                                      if (rentPrice == null) {
                                        _showErrorSnackBar("Invalid rent price format");
                                        return;
                                      }


                                      setState(() => isProcessing = true);


                                      try {
                                        final success = await ApartmentManagementUpdate.updateApartment(
                                          id: apartment['ID'],
                                          propertyName: apartment['PropertyName'],
                                          propertyType: apartment['PropertyType'],
                                          rentPrice: rentPrice,
                                          landmarks: _landmarksController.text,
                                          allowedGender: selectedGender ?? apartment['Allowed_Gender'],
                                          availability: selectedAvailability ?? apartment['Availability'],
                                        );


                                        if (success) {
                                          _showSuccessrSnackBar("Apartment updated successfully");
                                          await _fetchApartments();
                                          Navigator.pop(context);
                                        } else {
                                          _showErrorSnackBar("Update failed. Check server logs.");
                                        }
                                      } catch (e) {
                                        _showErrorSnackBar("Update error: ${e.toString()}");
                                      } finally {
                                        setState(() => isProcessing = false);
                                      }
                                    },
                                    child: const Text('Save', style: TextStyle(color: Colors.green)),
                                  ),
                                IconButton(
                                  icon: Icon(
                                    isEditing ? Icons.edit_off : Icons.edit,
                                    color: isDarkMode ? Colors.white : const Color(0xFF4F768E),
                                  ),
                                  onPressed: () {
                                    if (!isEditing) {
                                      _rentPriceController.text = apartment['Rent_Price'];
                                      _landmarksController.text = apartment['Landmarks'];
                                      selectedAvailability = apartment['Availability'];
                                      selectedGender = apartment['Allowed_Gender'];
                                    }
                                    setState(() => isEditing = !isEditing);
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(left: 53.0),
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: _infoRow("Apartment ID", apartment['ID'], isDarkMode),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: _infoRow("Property Name", apartment['PropertyName'], isDarkMode),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: isEditing
                                    ? _dropdownRow(
                                  "Availability",
                                  selectedAvailability,
                                  availabilityOptions,
                                      (value) => setState(() => selectedAvailability = value),
                                  isDarkMode,
                                )
                                    : _infoRow("Availability", apartment['Availability'], isDarkMode),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: isEditing
                                    ? _dropdownRow(
                                  "Allowed Gender",
                                  selectedGender,
                                  genderOptions,
                                      (value) => setState(() => selectedGender = value),
                                  isDarkMode,
                                )
                                    : _infoRow("Allowed Gender", apartment['Allowed_Gender'], isDarkMode),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: isEditing
                                    ? Column(
                                  children: [
                                    _editableInfoRow("Rent Price", _rentPriceController),
                                    if (_rentPriceController.text.isNotEmpty &&
                                        double.tryParse(_rentPriceController.text) == null)
                                      Text(
                                        "Must be a valid number (e.g. 1500.00)",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 12,
                                          fontFamily: 'Inter',
                                        ),
                                      ),
                                  ],
                                )
                                    : _infoRow("Rent Price", apartment['Rent_Price'], isDarkMode),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: isEditing
                                    ? _editableInfoRow("LandMarks", _landmarksController)
                                    : _infoRow("LandMarks", apartment['Landmarks'], isDarkMode),
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
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                ],
              ),
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [ ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isApproved
                    ? Colors.green
                    : (isRejected ? Colors.grey : const Color(0xFF79BD85)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                minimumSize: const Size(150, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: (isApproved || isRejected || isProcessing)
                  ? null
                  : () async {
                setState(() => isProcessing = true);
                final success = await ApartmentManagementStatus.updateApartmentStatus(
                  apartment['ID'],
                  'Approved',
                );
                setState(() => isProcessing = false);


                if (success) {
                  _showApproveTopSnackBar("Apartment approved successfully");
                  _showSuccessrSnackBar("Apartment approved successfully");
                  _fetchApartments();
                  Navigator.of(context).pop();
                } else {
                  _showErrorSnackBar("Failed to approve apartment");
                }
              },
              child: isProcessing && !isApproved && !isRejected
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
                  : Text(
                isApproved ? "Approved" : "Approve",
                style: const TextStyle(
                  fontFamily: "Inter",
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
              // Reject Button Section
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isRejected
                      ? Colors.red
                      : (isApproved ? Colors.grey : const Color(0xFFDE5959)),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  minimumSize: const Size(150, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: (isRejected || isApproved || isProcessing)
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
                          "Reject Apartment",
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
                                _showErrorSnackBar("Message cannot be empty");
                                return;
                              }

                              Navigator.pop(context); // Close message dialog
                              if (!mounted) return;

                              setState(() => isProcessing = true);

                              try {
                                final result = await ApartmentManagementReject.rejectApartment(
                                  apartment['ID'],
                                  message,
                                );

                                if (result.success) {
                                  // Close the apartment details dialog
                                  if (mounted) Navigator.of(context).pop();

                                  // Refresh data before showing messages
                                  await _fetchApartments();

                                  // Show server-provided messages
                                  if (result.message.isNotEmpty) {
                                    _showRejectTopSnackBar(result.message);
                                    _showSuccessRejectSnackBar("Apartment rejected successfully");
                                  }
                                } else {
                                  _showErrorSnackBar(result.message.isNotEmpty
                                      ? result.message
                                      : "Failed to reject apartment");
                                }
                              } catch (e) {
                                _showErrorSnackBar("Network error: Please check your connection");
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
                child: isProcessing && !isApproved && !isRejected
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                    : Text(
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
        );
      },
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



  Widget _dropdownRow(
      String label,
      String? value,
      List<String> options,
      ValueChanged<String?> onChanged,
      bool isDarkMode,
      ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
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
            child: DropdownButtonFormField<String>(
              value: value,
              items: options.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(
                    option,
                    style: TextStyle(
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
              style: TextStyle(
                fontFamily: "Inter",
                fontSize: 16,
              ),
              dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _editableInfoRow(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 150,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontFamily: "Inter",
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue),
                ),
              ),
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
}