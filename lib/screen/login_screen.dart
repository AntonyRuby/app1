import 'package:app1/main.dart';
import 'package:app1/model/user_model.dart';
import 'package:app1/screen/country_selection_screen.dart';
import 'package:app1/screen/settings_screen.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  final List<String> defaultCountries;
  final List<String> addedCountries;
  const LoginScreen(
      {super.key,
      required this.defaultCountries,
      required this.addedCountries});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _passwordVisible = false;

  void _togglePasswordVisibility() {
    setState(() {
      _passwordVisible = !_passwordVisible;
    });
  }

  void _login() {
    String email = _emailController.text;
    String password = _passwordController.text;

    User? user = _authenticateUser(email, password);
    if (user != null) {
      if (user.email == 'admin' && user.password == 'adminpass') {
        // Authenticate admin
        Provider.of<AuthProvider>(context, listen: false).authenticateAdmin();
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SettingsScreen(
              defaultCountries: widget.defaultCountries,
              addedCountries: widget.addedCountries,
            ), // Navigate to admin screen
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CountrySelectionScreen(
              defaultCountries: widget.defaultCountries,
              addedCountries: widget.addedCountries,
            ), // Navigate to user screen
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid email or password')),
      );
    }
  }

  User? _authenticateUser(String email, String password) {
    List<User> authorizedUsers = [
      User(email: 'user', password: 'pass'),
      User(email: 'admin', password: 'adminpass'), // Add admin user
    ];

    return authorizedUsers.firstWhereOrNull(
      (user) => user.email == email && user.password == password,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.email),
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20.0),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock),
                labelText: 'Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _passwordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Colors.grey,
                  ),
                  onPressed: _togglePasswordVisibility,
                ),
              ),
              obscureText: !_passwordVisible,
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}
