import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:rentxpert_flutter_web/service/propertymanagement.dart';
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
  int _rowsPerPage = 10;
  int _currentPage = 1;
  int _totalApartments = 0;
  String? _appliedFilter;
  String? editingUserId;
  Map<String, dynamic> editedUser = {};
  final TextEditingController _searchController = TextEditingController();

  //User dialog edit controllers
  final TextEditingController _landlordController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
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
                    'Address': apartment.address,
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
        _showErrorSnackBar("Failed to fetch apartments");
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showErrorSnackBar("Failed to fetch apartments: ${e.toString()}");
    }
  }

  int get _endIndex {
    final end = _currentPage * _rowsPerPage;
    return end > _totalApartments ? _totalApartments : end;
  }

  int get _totalPages => (_totalApartments / _rowsPerPage).ceil();

  List<Map<String, dynamic>> get _paginatedData {
    final startIndex = (_currentPage - 1) * _rowsPerPage;
    final endIndex = startIndex + _rowsPerPage;
    return apartmentData.sublist(
      startIndex.clamp(0, apartmentData.length),
      endIndex.clamp(0, apartmentData.length),
    );
  }

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

  void _showSuccessrSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showApproveTopSnackBar(String message) {
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
              color: Colors.green,
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

  void _showRejectTopSnackBar(String message) {
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
              color: Colors.red,
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

  //Filter function
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
                  style: _filterButtonStyle(
                    isDarkMode ? Colors.green[700]! : const Color(0xFF9AD47F),
                    Colors.white,
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
      backgroundColor: isDarkMode ? Colors.grey[900] : Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Properties Management: Apartments",
              style: TextStyle(
                fontSize: 45,
                fontFamily: "Inter",
                color: isDarkMode ? Colors.white : const Color(0xFF4F768E),
                fontWeight: FontWeight.w600,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 20),
            _buildSearchBar(),
            const SizedBox(height: 20),
            isLoading
                ? Center(child: CircularProgressIndicator())
                : Expanded(child: _buildUserTable()),
            const SizedBox(height: 20),
            _buildPaginationBar(isDarkMode),
          ],
        ),
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
    final paginatedApartments = _paginatedData;
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
              color: isDarkMode ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: ConstrainedBox(
                constraints: BoxConstraints(minWidth: constraints.maxWidth),
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0),
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
                                style: TextStyle(
                                  fontFamily: "Krub",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                    rows: paginatedApartments.map((apartment) {
                      final isEditing = editingUserId == apartment['ID'];

                      return DataRow(cells: [
                        DataCell(SizedBox(
                          width: columnWidth,
                          child: Center(
                              child: Text(apartment['Uid'] ?? '',
                                  textAlign: TextAlign.center)),
                        )),
                        isEditing
                            ? DataCell(SizedBox(
                                width: columnWidth,
                                child: TextFormField(
                                  initialValue: editedUser['PropertyName'] ??
                                      apartment['PropertyName'] ??
                                      '',
                                  onChanged: (value) =>
                                      editedUser['PropertyName'] = value,
                                ),
                              ))
                            : DataCell(SizedBox(
                                width: columnWidth,
                                child: Center(
                                    child: Text(apartment['PropertyName'] ?? '',
                                        textAlign: TextAlign.center)),
                              )),
                        isEditing
                            ? DataCell(SizedBox(
                                width: columnWidth,
                                child: TextFormField(
                                  initialValue: editedUser['PropertyType'] ??
                                      apartment['PropertyType'] ??
                                      '',
                                  onChanged: (value) =>
                                      editedUser['PropertyType'] = value,
                                ),
                              ))
                            : DataCell(SizedBox(
                                width: columnWidth,
                                child: Center(
                                    child: Text(apartment['PropertyType'] ?? '',
                                        textAlign: TextAlign.center)),
                              )),
                        DataCell(SizedBox(
                          width: columnWidth,
                          child: Center(
                              child: Text(apartment['Status'] ?? '',
                                  textAlign: TextAlign.center)),
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
                                              final index = apartmentData
                                                  .indexWhere((u) =>
                                                      u['ID'] ==
                                                      apartment['ID']);
                                              if (index != -1) {
                                                apartmentData[index] = {
                                                  ...apartmentData[index],
                                                  ...editedUser,
                                                };
                                              }
                                              editingUserId = null;
                                              editedUser = {};
                                            });
                                          },
                                          icon:
                                              const Icon(Icons.save, size: 15),
                                          label: const Text('Save'),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            backgroundColor: Colors.green,
                                            foregroundColor: Colors.white,
                                          ),
                                        )
                                      : TextButton.icon(
                                          onPressed: () {
                                            setState(() {
                                              editingUserId = apartment['ID'];
                                              editedUser =
                                                  Map<String, dynamic>.from(
                                                      apartment);
                                            });
                                          },
                                          icon:
                                              const Icon(Icons.edit, size: 15),
                                          label: const Text('Edit'),
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12, vertical: 8),
                                            backgroundColor:
                                                const Color(0xFF4F768E),
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                  if (isEditing)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: IconButton(
                                        icon: const Icon(Icons.cancel,
                                            color: Colors.red),
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
                                      padding:
                                          const EdgeInsets.only(left: 13.0),
                                      child: IconButton(
                                        icon: Image.asset(
                                            'assets/images/white_delete.png',
                                            width: 30,
                                            height: 30),
                                        onPressed: () {
                                          _showDeleteConfirmationDialog(
                                              apartment['ID']);
                                        },
                                      ),
                                    ),
                                  if (!isEditing)
                                    IconButton(
                                      icon: Image.asset(
                                          'assets/images/more_options.png',
                                          width: 55,
                                          height: 55),
                                      onPressed: () =>
                                          _showUserDetailsDialog(apartment),
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
                color: isDarkMode ? Colors.white : Colors.black, // Set text color
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? '',
              style: TextStyle(
                fontFamily: "Inter",
                fontSize: 16,
                color: isDarkMode ? Colors.white : Colors.black, // Set text color
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
                        setState(() => _currentPage--);
                        _fetchApartments();
                      }
                    : null,
              ),
              ..._buildPageNumbers(),
              _buildPaginateButton(
                icon: Icons.arrow_forward,
                label: 'Next',
                onPressed: _currentPage < _totalPages
                    ? () {
                        setState(() => _currentPage++);
                        _fetchApartments();
                      }
                    : null,
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
            color: onPressed != null
                ? const Color(0xFF4F768E)
                : Colors.grey.shade300,
            width: 2,
          ),
        ),
        backgroundColor:
            onPressed != null ? const Color(0xFF4F768E) : Colors.grey.shade300,
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
              color:
                  isSelected ? const Color(0xFF4F768E) : Colors.grey.shade300,
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

  //More options dialog
  void _showUserDetailsDialog(Map<String, dynamic> apartment) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDarkMode = themeProvider.isDarkMode;

    // Add state variables for dropdowns
    String? selectedAvailability = apartment['Availability'];
    String? selectedGender = apartment['Allowed_Gender'];

    // Dropdown options
    final List<String> availabilityOptions = ['Available', 'Not Available'];
    final List<String> genderOptions = ['Male', 'Female', 'Other'];

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
                                    onPressed: () {
                                      final index = apartmentData.indexWhere((a) => a['ID'] == apartment['ID']);
                                      if (index != -1) {
                                        setState(() {
                                          // Create a new map with all values converted to strings
                                          final updatedData = {
                                            ...apartmentData[index],
                                            'landlord_name': _landlordController.text,
                                            'Address': _addressController.text,
                                            'Rent_Price': _rentPriceController.text,
                                            'Landmarks': _landmarksController.text,
                                            'Availability': selectedAvailability?.toString() ?? '',
                                            'Allowed_Gender': selectedGender?.toString() ?? '',
                                          };

                                          // Convert all values to strings explicitly
                                          apartmentData[index] = updatedData.map<String, String>(
                                                  (key, value) => MapEntry(key, value.toString())
                                          );
                                        });
                                        _showApproveTopSnackBar("Changes saved successfully");
                                        isEditing = false;
                                      } else {
                                        _showErrorSnackBar("Failed to save changes");
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
                                      _addressController.text = apartment['Address'];
                                      _rentPriceController.text = apartment['Rent_Price'];
                                      _landmarksController.text = apartment['Landmarks'];
                                      selectedAvailability = apartment['Availability'];
                                      selectedGender = apartment['Allowed_Gender'];
                                    }
                                    setState(() {
                                      isEditing = !isEditing;
                                    });
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
                                      (value) {
                                    setState(() {
                                      selectedAvailability = value;
                                    });
                                  },
                                  isDarkMode,
                                )
                                    : _infoRow("Availability", apartment['Availability'], isDarkMode),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: isEditing
                                    ? _editableInfoRow("Address", _addressController)
                                    : _infoRow("Address", apartment['Address'], isDarkMode),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: isEditing
                                    ? _dropdownRow(
                                  "Allowed Gender",
                                  selectedGender,
                                  genderOptions,
                                      (value) {
                                    setState(() {
                                      selectedGender = value;
                                    });
                                  },
                                  isDarkMode,
                                )
                                    : _infoRow("Allowed Gender", apartment['Allowed_Gender'], isDarkMode),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: isEditing
                                    ? _editableInfoRow("Rent Price", _rentPriceController)
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
            actions: [
              ElevatedButton(
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
                                border: OutlineInputBorder(),
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
                              if (message.isNotEmpty) {
                                Navigator.pop(context);
                                setState(() => isProcessing = true);
                                final success = await ApartmentManagementReject.rejectApartment(
                                    apartment['ID'],
                                    message
                                );

                                setState(() => isProcessing = false);


                                if (success) {
                                  _showRejectTopSnackBar("Apartment rejected successfully");
                                  _fetchApartments();
                                } else {
                                  _showErrorSnackBar("Failed to reject apartment");
                                }
                              } else {
                                _showErrorSnackBar("Message cannot be empty");
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

  // Add this new helper method for dropdown rows
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
