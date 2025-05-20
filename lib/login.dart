import 'package:flutter/material.dart';
import 'package:rentxpert_flutter_web/service/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Main_Screen.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_emailFocusNode);
    });
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Email and password cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await AdminAuthService.loginAdmin(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response['success'] == true) {
        final token = response['data']['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', token);
        print('Token saved: $token');

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => MainScreen(),
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: constraints.maxWidth * 0.1,
                        vertical: constraints.maxHeight * 0.05,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                          SizedBox(height: constraints.maxHeight * 0.05),

                          // Email Field
                          Text(
                            "Email",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: constraints.maxWidth * 0.04,
                              fontFamily: "Krub-SemiBold",
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: constraints.maxHeight * 0.015),
                          SizedBox(
                            height: constraints.maxHeight * 0.1,
                            child: TextField(
                              controller: _emailController,
                              focusNode: _emailFocusNode,
                              textInputAction: TextInputAction.next,
                              onSubmitted: (_) {
                                FocusScope.of(context).requestFocus(_passwordFocusNode);
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: constraints.maxWidth * 0.04,
                                  vertical: constraints.maxHeight * 0.02,
                                ),
                                labelText: 'Enter your email',
                                labelStyle: const TextStyle(color: Color(0xFF848484)),
                                floatingLabelBehavior: FloatingLabelBehavior.never,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Color(0xFF4A758F), width: 2),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                            ),
                          ),
                          SizedBox(height: constraints.maxHeight * 0.03),

                          // Password Field
                          Text(
                            "Password",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: constraints.maxWidth * 0.04,
                              fontFamily: "Krub",
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: constraints.maxHeight * 0.015),
                          SizedBox(
                            height: constraints.maxHeight * 0.1,
                            child: TextField(
                              controller: _passwordController,
                              focusNode: _passwordFocusNode,
                              obscureText: !_isPasswordVisible,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) {
                                if (!_isLoading) {
                                  _handleLogin();
                                }
                              },
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: constraints.maxWidth * 0.04,
                                  vertical: constraints.maxHeight * 0.02,
                                ),
                                labelText: '••••••',
                                labelStyle: const TextStyle(color: Color(0xFF848484)),
                                floatingLabelBehavior: FloatingLabelBehavior.never,
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Colors.grey, width: 1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: Color(0xFF4A758F), width: 2),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                filled: true,
                                fillColor: Colors.grey[50],
                                suffixIcon: Padding(
                                  padding: EdgeInsets.only(right: constraints.maxWidth * 0.04),
                                  child: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
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
                          ),
                          SizedBox(height: constraints.maxHeight * 0.04),

                          // Login Button
                          SizedBox(
                            width: double.infinity,
                            height: constraints.maxHeight * 0.1,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A758F),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                elevation: 2,
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : Text(
                                'Log In',
                                style: TextStyle(
                                  fontSize: constraints.maxWidth * 0.05,
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
                  );
                },
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
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }
}