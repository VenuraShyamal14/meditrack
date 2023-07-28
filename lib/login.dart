import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'main.dart'; // Import the main.dart file or replace it with the correct path to your main screen.

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

// Function to perform the logout process
Future<void> logout() async {
  // Clear authentication tokens or session data (for example, using shared preferences)
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.remove('authToken'); // Remove the authentication token from shared preferences

  // You can perform any other cleanup tasks here if needed.

  // After logging out, you might want to navigate the user back to the login screen.
  // This will depend on your app's navigation setup.
}

class _AuthScreenState extends State<AuthScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _message = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Authentication'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                ),
              ),
              SizedBox(height: 24),
              Align(
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _signIn,
                      child: Text('Login'),
                    ),
                    SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: _signUp,
                      child: Text('Sign Up'),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Text(
                _message,
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Login with email and password
  Future<void> _signIn() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      User? user = userCredential.user;
      setState(() {
        _message = 'Logged in as ${user?.email}';
      });
      // Set the isLoggedIn shared preference value to true on successful login
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      // Direct the user to main.dart after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()), // Replace MyApp with your main.dart widget.
      );
    } catch (e) {
      setState(() {
        _message = 'Login failed: $e';
      });
    }
  }

  // Sign up with email and password
  Future<void> _signUp() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      User? user = userCredential.user;
      setState(() {
        _message = 'Registered and logged in as ${user?.email}';
      });
      // Set the isLoggedIn shared preference value to true on successful signup
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      // Direct the user to main.dart after successful signup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()), // Replace MyApp with your main.dart widget.
      );
    } catch (e) {
      setState(() {
        _message = 'Sign up failed: $e';
      });
    }
  }
}
