import 'package:app1/screen/login_screen.dart';
import 'package:app1/screen/settings_screen.dart';
import 'package:app1/screen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsModel extends ChangeNotifier {
  List<String> countries = ['USA', 'Canada', 'UK', 'UAE'];
  bool contentControlEnabled;

  SettingsModel({this.contentControlEnabled = false});

  // Method to toggle content control
  void toggleContentControl() {
    contentControlEnabled = !contentControlEnabled;
    notifyListeners(); // Notify listeners about the change
  }

  void addCountry(String newCountry) {
    countries.add(newCountry);
    notifyListeners(); // Notify listeners about the change
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferences.getInstance();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsModel()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool isAdmin = Provider.of<AuthProvider>(context).isAdminAuthenticated;
    final List<String> defaultCountries = ['USA', 'Canada', 'UK', 'UAE'];
    final List<String> addedCountries = [];

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        hintColor: Colors.blueAccent,
        fontFamily: 'Roboto',
      ),
      home: SplashScreen(
        defaultCountries: defaultCountries,
        addedCountries: addedCountries,
      ),
      routes: {
        '/settings': (context) => isAdmin
            ? SettingsScreen(
                defaultCountries: defaultCountries,
                addedCountries: addedCountries,
              )
            : const UnauthorizedScreen(),
        '/login': (context) => LoginScreen(
              defaultCountries: defaultCountries,
              addedCountries: addedCountries,
            ),
      },
    );
  }
}

// New UnauthorizedScreen
class UnauthorizedScreen extends StatelessWidget {
  const UnauthorizedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Unauthorized access',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

class AuthProvider extends ChangeNotifier {
  bool isAdminAuthenticated = false;

  void authenticateAdmin() {
    isAdminAuthenticated = true;
    notifyListeners();
  }

  void logoutAdmin() {
    isAdminAuthenticated = false;
    notifyListeners();
  }
}
