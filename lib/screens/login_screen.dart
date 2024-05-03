import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

typedef LoginSuccessCallback = void Function(bool isAdmin, String userDocId);

class LoginPage extends StatefulWidget {
  final LoginSuccessCallback onLoginSuccess;
  // final String? userDocId;

  const LoginPage({Key? key, required this.onLoginSuccess}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _companyNameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    String inputCompanyName = _companyNameController.text.trim();
    String password = _passwordController.text.trim();

    // Check if the company name or password fields are empty
    if (inputCompanyName.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Company name and password cannot be empty"),
        backgroundColor: Colors.red,
      ));
      return; // Stop the function if any field is empty
    }

    // Create a search key from the input, similar to how 'searchKey' is stored in Firestore
    String searchKey =
        inputCompanyName.toLowerCase().replaceAll(RegExp(r'[^a-zA-Z]+'), '');

    try {
      // Query Firestore for documents where 'searchKey' matches the generated key
      var querySnapshot = await FirebaseFirestore.instance
          .collection('companyCredentials')
          .where('searchKey', isEqualTo: searchKey)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        bool loginSuccessful = false;
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> data = doc.data();

          // Use password directly as the userDocId
          String userDocId = password;

          // Check if the entered password matches the stored document ID (password)
          if (data['documentId'] == password) {
            bool isAdmin = (searchKey == "admintiffintime");

            // Pass isAdmin and userDocId (password) to the callback
            widget.onLoginSuccess(isAdmin, userDocId);

            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Login Successful"),
              backgroundColor: Colors.green,
            ));
            loginSuccessful = true;
            break;
          }
        }

        if (!loginSuccessful) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Login Failed: Incorrect password"),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text("No such company found"),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error logging in: $e"),
        backgroundColor: Colors.red,
      ));
      print("Login error: $e"); // More detailed logging for troubleshooting
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
        // Centers the login form on the screen
        child: SingleChildScrollView(
          // Allows the form to scroll
          padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.1), // Responsive horizontal padding
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 40),
              const Text('Please enter your login details',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              TextField(
                controller: _companyNameController,
                decoration: const InputDecoration(
                  labelText: 'Company Name',
                  border: OutlineInputBorder(),
                  prefixIcon:
                      Icon(Icons.business), // Adding an icon to the text field
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefixIcon:
                      Icon(Icons.lock), // Adding an icon to the text field
                ),
                obscureText: true,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueAccent,
                  minimumSize:
                      const Size(double.infinity, 50), // Set the text color
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
