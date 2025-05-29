
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth/auth_provider.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  int _selectedIndex = 0;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _forgotEmailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _forgotEmailFocusNode = FocusNode();

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(
        _selectedIndex == 0 ? _emailFocusNode : _forgotEmailFocusNode,
      );
    });
    _initializeFirebase();
  }

  Future<void> _initializeFirebase() async {
    await AuthService.initialize();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Email and password cannot be empty');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final result = await _authService.signInWithEmailPassword(email, password);

      if (result['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('authToken', result['token']!);
        if (mounted) context.go('/dashboard');
      } else {
        _showSnackBar(result['message'] ?? 'Login failed');
      }
    } catch (e) {
      _showSnackBar('Error: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _handleSendCode() async {
    final email = _forgotEmailController.text.trim();

    if (email.isEmpty) {
      _showSnackBar('Please enter your email address');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Send password reset email using Firebase Auth
      await _authService.sendPasswordResetEmail(email);

      _showSnackBar('Password reset email sent to $email', isError: false);

      // Optionally switch back to login form after successful send
      setState(() {
        _selectedIndex = 0;
        _forgotEmailController.clear();
      });
    } catch (e) {
      _showSnackBar('Failed to send reset email: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
            // Left form (Login or Forgot Password)
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
                padding: EdgeInsets.only(
                    top: MediaQuery.of(context).size.height * 0.25,
                    left: 32.0,
                    right: 32.9),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _selectedIndex == 0 ? "Log In" : "Reset Password",
                      style: const TextStyle(
                        fontSize: 37,
                        fontFamily: "Krub",
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _selectedIndex == 0
                          ? "Welcome to RentXpert! Please enter your details"
                          : "Enter your Gmail address to receive a verification code",
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontFamily: "Krub",
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: SingleChildScrollView(
                        clipBehavior: Clip.none,
                        child: _selectedIndex == 0 ? _buildLoginForm() : _buildForgotPasswordForm(),
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

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Email Field
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
          focusNode: _emailFocusNode,
          textInputAction: TextInputAction.next,
          onSubmitted: (_) {
            FocusScope.of(context).requestFocus(_passwordFocusNode);
          },
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
        // Password Field
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
          focusNode: _passwordFocusNode,
          obscureText: !_isPasswordVisible,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            if (!_isLoading) {
              _handleLogin();
            }
          },
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
        // Forgot Password Link
        const SizedBox(height: 16),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              setState(() {
                _selectedIndex = 1;
                _emailController.clear();
                _passwordController.clear();
              });
            },
            child: const Text(
              'Forgot Password?',
              style: TextStyle(
                color: Color(0xFF4A758F),
                fontSize: 14,
                fontFamily: "Krub",
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Login Button
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
    );
  }

  Widget _buildForgotPasswordForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Gmail Field
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            "Gmail",
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
          controller: _forgotEmailController,
          focusNode: _forgotEmailFocusNode,
          textInputAction: TextInputAction.done,
          onSubmitted: (_) {
            if (!_isLoading) {
              _handleSendCode();
            }
          },
          decoration: const InputDecoration(
            labelText: 'Enter your Gmail',
            labelStyle: TextStyle(color: Color(0xFF848484)),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF4A758F), width: 2),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Send Code Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _handleSendCode,
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
              'Send Code',
              style: TextStyle(
                fontSize: 20,
                fontFamily: "Krub",
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        // Back to Login Link
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {
              setState(() {
                _selectedIndex = 0;
                _forgotEmailController.clear();
              });
            },
            child: const Text(
              'Back to Login',
              style: TextStyle(
                color: Color(0xFF4A758F),
                fontSize: 14,
                fontFamily: "Krub",
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _forgotEmailController.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _forgotEmailFocusNode.dispose();
    super.dispose();
  }
}