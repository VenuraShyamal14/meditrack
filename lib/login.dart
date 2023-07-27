import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                hintText: 'Email',
              ),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Password',
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _signIn,
              child: Text('Login'),
            ),
            ElevatedButton(
              onPressed: _signUp,
              child: Text('Sign Up'),
            ),
            ElevatedButton(
              onPressed: _signOut,
              child: Text('Logout'),
            ),
            Text(_message),
          ],
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
    } catch (e) {
      setState(() {
        _message = 'Sign up failed: $e';
      });
    }
  }

  // Logout
  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      setState(() {
        _message = 'Logged out';
      });
    } catch (e) {
      setState(() {
        _message = 'Logout failed: $e';
      });
    }
  }
}
