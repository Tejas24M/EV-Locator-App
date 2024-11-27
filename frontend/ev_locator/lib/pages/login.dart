import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ev_locator/main.dart';
import 'package:http/http.dart' as http;
import 'driver_page.dart';

class LoginPage extends StatefulWidget {
  final String? username;
  final String? password;

  // Constructor to accept values passed from the signup page
  const LoginPage({super.key, this.username, this.password});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  String _selectedRole = 'Student'; // Default role
  bool _isSignUp = false; // To toggle between Login and SignUp

  // Function to handle login
  Future<void> _handleLogin() async {
    String url = GlobalConfig().url;
    final String loginUrl = 'http://$url/auth/login';

    if (!_formKey.currentState!.validate()) {
      return; // Form is invalid
    }
    _formKey.currentState!.save(); // Save form data to variables

    final Map<String, String> body = {
      'username': _username,
      'password': _password,
    };

    try {
      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final String role = data['role'];
        GlobalConfig().token = data['token'];
        GlobalConfig().username = _username;

        // Successfully logged in
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful')),
        );

        // Navigate to the correct page based on role
        if (role == 'user') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainPage()), // User's main page
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => DriverPage()), // Driver's page
          );
        }
      } else if (response.statusCode == 401) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid Username or Password')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Function to handle signup
  Future<void> _handleSignUp() async {
    String url = GlobalConfig().url;
    final String signupUrl = 'http://$url/auth/register';

    if (!_formKey.currentState!.validate()) {
      return; // Form is invalid
    }
    _formKey.currentState!.save(); // Save form data to variables

    final String role = _selectedRole == 'Driver' ? 'driver' : 'user';
    final Map<String, String> body = {
      'username': _username,
      'password': _password,
      'clientType': role, // Include role during signup
    };

    try {
      final response = await http.post(
        Uri.parse(signupUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );
      final Map<String, dynamic> data = jsonDecode(response.body);
      print(data);

      if (response.statusCode == 201) {
        // Successfully registered
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Registration successful')),
        );

        // Navigate to login page with the form values preserved
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => LoginPage(
              username: _username,
              password: _password,
            ),
          ),
        );
      }
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${response.statusCode} , $data')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignUp ? 'Sign Up' : 'Login'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) {
                    _username = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  onSaved: (value) {
                    _password = value!;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                if (_isSignUp)
                  DropdownButtonFormField<String>(
                    value: _selectedRole,
                    decoration: InputDecoration(
                      labelText: 'Select Role',
                      border: OutlineInputBorder(),
                    ),
                    items: [
                      DropdownMenuItem<String>(
                        value: 'Student',
                        child: Text('Student'),
                      ),
                      DropdownMenuItem<String>(
                        value: 'Driver',
                        child: Text('Driver'),
                      ),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedRole = value!;
                      });
                    },
                  ),
                SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _isSignUp ? _handleSignUp : _handleLogin,
                    child: Text(_isSignUp ? 'Sign Up' : 'Login'),
                  ),
                ),
                SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _isSignUp = !_isSignUp; // Toggle between login and signup
                      });
                    },
                    child: Text(
                      _isSignUp
                          ? 'Already have an account? Login'
                          : 'Don\'t have an account? Sign Up',
                      style: TextStyle(color: Colors.blue),
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