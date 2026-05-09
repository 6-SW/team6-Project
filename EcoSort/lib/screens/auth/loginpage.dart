import 'package:flutter/material.dart';
import '../../api/api_service.dart';
import '../home/homepage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController employeeIDController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  Future<void> _handleLogin(
      String employeeID, String password, BuildContext context) async {
    if (employeeID.isEmpty || password.isEmpty) {
      _showSnackBar(context, 'Please enter valid credentials.');
      return;
    }

    try {
      final response = await ApiService.login(employeeID, password);
      if (response['Status_Code'] == 200 &&
          response['Message'] ==
              'GetUserData Mobile API Executed Successfully.' &&
          response['Response_Body'][0]['Doc_Msg'] != 'Invalid Password') {
        final String message = response['Message'];
        final Map<String, dynamic> userData = response['Response_Body'][0];

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HomePage(
              message: message,
              userData: userData,
            ),
          ),
        );
      } else {
        _showSnackBar(context, 'Invalid credentials. Please try again.');
      }
    } catch (e) {
      _showSnackBar(context, 'An error occurred: $e');
    }
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Welcome back!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Log in to continue',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: employeeIDController,
                  decoration: InputDecoration(
                    hintText: 'User Name',
                    filled: true,
                    prefixIcon: const Icon(Icons.person, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    filled: true,
                    prefixIcon: const Icon(Icons.lock, color: Colors.grey),
                    suffixIcon: IconButton(
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _handleLogin(
                      employeeIDController.text,
                      passwordController.text,
                      context,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 100,
                      vertical: 15,
                    ),
                  ),
                  child: const Text(
                    'Log In',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
