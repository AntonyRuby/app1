import 'package:app1/screen/login_screen.dart';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  final List<String> defaultCountries;
  final List<String> addedCountries;
  const SplashScreen(
      {super.key,
      required this.defaultCountries,
      required this.addedCountries});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin(context, []);
  }

  Future<void> _navigateToLogin(
      BuildContext context, List<String> countries) async {
    await Future.delayed(const Duration(seconds: 2));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => LoginScreen(
                defaultCountries: widget.defaultCountries,
                addedCountries: widget.addedCountries,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hourglass_empty,
              size: 150,
              color: Colors.blue,
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
