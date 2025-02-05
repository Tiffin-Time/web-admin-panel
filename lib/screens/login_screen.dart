import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

typedef LoginSuccessCallback = void Function(bool isAdmin, String userDocId);

class LoginPage extends StatefulWidget {
  final LoginSuccessCallback onLoginSuccess;

  const LoginPage({Key? key, required this.onLoginSuccess}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _companyNameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  void _login() async {
    String inputCompanyName = _companyNameController.text.trim();
    String password = _passwordController.text.trim();

    if (inputCompanyName.isEmpty || password.isEmpty) {
      _showSnackbar("Company name and password cannot be empty", Colors.red);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String searchKey =
        inputCompanyName.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z]+'), '');

    try {
      var querySnapshot = await FirebaseFirestore.instance
          .collection('companyCredentials')
          .where('searchKey', isEqualTo: searchKey)
          .get();

      bool loginSuccessful = false;

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data();
          String userDocId = password;

          if (data['documentId'] == password) {
            bool isAdmin = (searchKey == "admintiffintime");

            widget.onLoginSuccess(isAdmin, userDocId);

            _showSnackbar("Login Successful", Colors.green);
            loginSuccessful = true;
            break;
          }
        }
      }

      if (!loginSuccessful) {
        _showSnackbar("Login Failed: Incorrect credentials", Colors.red);
      }
    } catch (e) {
      _showSnackbar("Error logging in: $e", Colors.red);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontSize: 16)),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600; // Responsive handling

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E88E5), Color(0xFF42A5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 30 : 80),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.admin_panel_settings,
                    size: 80, color: Colors.white),
                const SizedBox(height: 20),
                const Text(
                  'Admin Login',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                _buildTextField(
                  controller: _companyNameController,
                  label: 'Company Name',
                  icon: Icons.business,
                ),
                const SizedBox(height: 20),
                _buildTextField(
                  controller: _passwordController,
                  label: 'Password',
                  icon: Icons.lock,
                  isPassword: true,
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : _buildLoginButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.2),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _login,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.blueAccent,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 50),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: const Text('Login'),
    );
  }
}
