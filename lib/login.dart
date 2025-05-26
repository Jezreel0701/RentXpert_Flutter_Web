import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:rentxpert_flutter_web/service/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;
  int _selectedIndex = 0; // 0 for login, 1 for forgot password
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _forgotEmailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _forgotEmailFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedIndex == 0) {
        FocusScope.of(context).requestFocus(_emailFocusNode);
      } else {
        FocusScope.of(context).requestFocus(_forgotEmailFocusNode);
      }
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

        // Use go_router for navigation
        if (mounted) {
          context.go('/dashboard');
        }
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleSendCode() async {
    if (_forgotEmailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your Gmail address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Placeholder for API call to send verification code
      // Example: await AdminAuthService.sendResetCode(_forgotEmailController.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification code sent to your email'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
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