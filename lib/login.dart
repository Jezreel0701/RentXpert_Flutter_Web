import 'package:flutter/material.dart';
import 'package:rentxpert_flutter_web/MainScreen.dart';
import 'package:rentxpert_flutter_web/service/api.dart';
import 'package:rentxpert_flutter_web/Dashboard_Screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences for token storage


class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isPasswordVisible = false; // Added password visibility state
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);

    try {
      // Debug print for login attempt
      print('🟡 Attempting admin login');
      print('📡 Endpoint: http://10.21.1.220:8080/admin/login');
      print('📨 Request Body: {"email":"${_emailController.text.trim()}","password":"${_passwordController.text.trim()}"}');

      final response = await AdminAuthService.loginAdmin(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      print('🔵 Response Status: ${response['status']}');
      print('🔵 Response Body: ${response.toString()}');

      if (response['success'] == true) {
        final token = response['data']['token']; // Token from API response
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token);  // Save token in SharedPreferences
        print('Token saved: $token');  // Debug print
        print('🔍 Full Parsed Response: $response');


        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => Mainscreen(),
            settings: const RouteSettings(name: '/dashboard'),
          ),
              (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Login failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
        // Left login form
        Container(
        width: MediaQuery.of(context).size.width * 0.4,
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Log In",
                  style: TextStyle(
                    fontSize: 37,
                    fontFamily: "Krub",
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Welcome to RentXpert! Please enter your details",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                    fontFamily: "Krub",
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Email
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Email",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontFamily: "Krub-SemiBold",
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Enter your email',
                    labelStyle: TextStyle(color: Color(0xFF848484)),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF4A758F), width: 2),
                    ),
                  ),
                ),

                const SizedBox(height: 15),

                  // Password
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Password",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontFamily: "Krub",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible, // Toggle visibility
                  decoration: InputDecoration(
                    labelText: '••••••',
                    labelStyle: const TextStyle(color: Color(0xFF848484)),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 1),
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF4A758F), width: 2),
                    ),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),



                const SizedBox(height: 20),

                // Log In Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: const Color(0xFF4A758F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      'Log In',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: "Krub",
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: 20),

        // Right image box
        Container(
          width: MediaQuery.of(context).size.width * 0.4,
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: const Color(0xFF4A758F),
            boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/white_logo.png',
                  width: MediaQuery.of(context).size.width * 0.2,
                  height: MediaQuery.of(context).size.width * 0.2,
                ),
                const SizedBox(height: 20),
                const Text(
                  "\"RentXpert : Connecting You to \n   Comfort and Convenience.\"",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: "Krub",
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}