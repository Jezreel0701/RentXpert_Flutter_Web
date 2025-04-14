import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedPage = 'Account';
  String _hoveredPage = '';

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
                'Are you sure you want to delete your account?',
                style: TextStyle(
                  color: Color(0xFF979797),
                    fontSize: 18,
                    fontFamily: "Krub",
                    fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: 170, // Adjust the width here
                    height: 40, // Adjust the height here
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
                    height: 40, // Adjust the height here
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 4,
                        backgroundColor: Color(0xFFF47D7D),
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

  void _deleteAccount() {
    // Add your account deletion logic here.

    // Show custom top snack bar
    _showDeleteTopSnackBar("Account deleted successfully");
  }

// Snackbar notification for Save button
  void _showSaveTopSnackBar(String message) {
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
            child: Center (
              child: Text(
                message,
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            )

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

  void _saveAccount() {
    // Add your account Save logic here.

    // Show custom top snack bar
    _showSaveTopSnackBar("Account Succesfully saved!");
  }


  @override
  Widget build(BuildContext context) {


    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Settings",
              style: TextStyle(
                fontSize: 45,
                fontFamily: "Inter",
                color: Color(0xFF4F768E),
                fontWeight: FontWeight.w600,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  // Sidebar
                  Container(
                    width: screenWidth * 0.18,
                    margin: const EdgeInsets.only(right: 30),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 10),
                      ],
                    ),

                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 50.0), // <-- Add top padding here
                          child: _buildSidebarTile("Account", Icons.settings),
                        ),
                        _buildSidebarTile("User Permission", Icons.info_outline),

                      ],
                    ),


                  ),

                  // Main Content: Account
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        double containerWidth = constraints.maxWidth > 900
                            ? 800
                            : constraints.maxWidth * 5;

                        return Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: containerWidth,
                            constraints: BoxConstraints(
                              minHeight: 350,
                              maxHeight: MediaQuery.of(context).size.height * 5,
                            ),

                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(color: Colors.black26, blurRadius: 10),
                              ],
                            ),
                            child: _selectedPage == 'Account'
                                ? _buildAccountPage()
                                : _buildUserPermissionPage(),
                          ),
                        );
                      },
                    ),
                  ),



                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebarTile(String title, IconData icon) {
    bool isSelected = _selectedPage == title;
    bool isHovered = _hoveredPage == title;

    return MouseRegion(
      onEnter: (_) => setState(() => _hoveredPage = title),
      onExit: (_) => setState(() => _hoveredPage = ''),
      child: GestureDetector(
        onTap: () => setState(() => _selectedPage = title),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFFD7E4ED)
                : isHovered
                ? const Color(0xFFD7E4ED)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(icon, color: Colors.black87),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildAccountPage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 600;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Account",
                  style: TextStyle(
                      color: Color(0xFF4B6C81),
                  fontFamily: "Krub",
                  fontSize: 25,
                  fontWeight: FontWeight.bold)),
              const Divider(thickness: 1), // Divider
              const SizedBox(height: 8),

              Center(
                // padding: const EdgeInsets.only(left: 24.0),
                child: Text(
                  "My Profile",
                  style: TextStyle(
                    color: Color(0xFF4B6C81),
                    fontFamily: "Krub",
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Profile Icon
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min, // Important to center within available space
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                    ),
                    const SizedBox(width: 12),

                    // ElevatedButton(
                    //   style: ElevatedButton.styleFrom(
                    //     backgroundColor: const Color(0xFFD7E2F0),
                    //     foregroundColor: Colors.black,
                    //     elevation: 0,
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(12),
                    //     ),
                    //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    //   ),
                    //   onPressed: () {
                    //     _showEditDialog();
                    //   },
                    //   child: Row(
                    //     mainAxisSize: MainAxisSize.min,
                    //     children: const [
                    //       Text("Edit"),
                    //       SizedBox(width: 6),
                    //       Icon(Icons.edit, size: 16),
                    //     ],
                    //   ),
                    // )

                  ],
                ),
              ),


              const SizedBox(height: 24),

              // Text fields
              Column(
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _responsiveInput("Username"),
                      _responsiveInput("Password", obscureText: true),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Divider(thickness: 1),
              const SizedBox(height: 8),
              const SizedBox(height: 13),

              //Delete Button
              Padding(
                padding: const EdgeInsets.only(left: 24.0),
                child: Row(
                  children: [
                    // Delete Button
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.12,
                      height: MediaQuery.of(context).size.width * 0.03,
                      child: ElevatedButton(
                        onPressed: () {
                          _showDeleteConfirmationDialog();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFD24E4E),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Delete account",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: "Krub",
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16), // Space between buttons

                    // Save Button
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.12,
                      height: MediaQuery.of(context).size.width * 0.03,
                      child: ElevatedButton(
                        onPressed: () {
                          _saveAccount();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF4A758F),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Save",
                          style: TextStyle(
                            fontSize: 16,
                            fontFamily: "Krub",
                            fontWeight: FontWeight.w300,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),


            ],
          ),
        );
      },
    );
  }

  Widget _responsiveInput(String label, {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 25.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 1/4,
        child: TextField(
          obscureText: obscureText,
          decoration: InputDecoration(
            focusedBorder: OutlineInputBorder( // border radius effect
              borderSide: BorderSide(color: Color(0xFF4A758F), width: 2),
            ),
            enabledBorder: OutlineInputBorder( // Border color
              borderSide: BorderSide(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            labelText: label,
            labelStyle: TextStyle(  // Added labelStyle to change label text color
              color: Color(0xFF848484),  //  label text color
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ),
    );
  }



  Widget _buildUserPermissionPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text("User Permission", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Divider(thickness: 1),
        SizedBox(height: 16),
        Text("This is the User Permission page."),
      ],
    );
  }
}
