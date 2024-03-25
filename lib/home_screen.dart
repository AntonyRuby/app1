import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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

class User {
  final String email;
  final String password;

  User({required this.email, required this.password});
}

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

class CountrySelectionScreen extends StatelessWidget {
  final List<String> defaultCountries;
  final List<String> addedCountries;

  const CountrySelectionScreen({
    super.key,
    required this.defaultCountries,
    required this.addedCountries,
  });

  @override
  Widget build(BuildContext context) {
    List<String> allCountries = [...defaultCountries, ...addedCountries];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Country'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: allCountries.length,
        itemBuilder: (context, index) {
          return Card(
            elevation: 2.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.blue,
                child: Icon(
                  Icons.location_on,
                  color: Colors.white,
                ),
              ),
              title: Text(
                allCountries[index],
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                _launchChildApp(context, allCountries[index]);
              },
            ),
          );
        },
      ),
    );
  }

  void _launchChildApp(BuildContext context, String selectedCountry) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Retrieve the added cities for the selected country
    List<String>? addedCities = prefs.getStringList(selectedCountry);

    // Launch App 2 with selected country and added cities
    final String authToken = 'sample_auth_token';
    final String deepLink =
        'myapp://childapp?country=$selectedCountry&token=$authToken&cities=${addedCities?.join(",")}';
    if (await canLaunchUrl(Uri.parse(deepLink))) {
      await launchUrl(Uri.parse(deepLink));
    } else {
      throw 'Could not launch $deepLink';
    }
  }
}

class SettingsScreen extends StatelessWidget {
  final List<String> defaultCountries;
  final List<String> addedCountries;

  const SettingsScreen({
    super.key,
    required this.defaultCountries,
    required this.addedCountries,
  });

  // Method to update the list of countries after adding a new location
  void _updateCountryList(BuildContext context, Country newCountry,
      List<String> defaultCountries, List<String> addedCountries) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Retrieve the list of added cities for the new country
    List<String>? addedCities = prefs.getStringList(newCountry.name) ?? [];
    // Add the new city to the list of added cities
    addedCities.addAll(newCountry.cities);
    // Store the updated list of cities for the country
    prefs.setStringList(newCountry.name, addedCities);

    // Update the addedCountries list in MyApp widget
    addedCountries.add(newCountry.name);

    // Notify the CountrySelectionScreen to update with the new list of countries
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => CountrySelectionScreen(
          defaultCountries: defaultCountries,
          addedCountries: addedCountries,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Logout the admin user
              Provider.of<AuthProvider>(context, listen: false).logoutAdmin();
              // Navigate back to the login screen
              // Navigator.popUntil(context, ModalRoute.withName('/login'));
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login', // Replace '/login' with the route name of your login screen
                (route) => false, // Remove all routes until the login screen
              );
            },
          ),
        ],
      ),
      body: Consumer<SettingsModel>(
        builder: (context, settings, child) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Content Control',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SwitchListTile(
                  title: const Text('Enable Content Control'),
                  value: settings.contentControlEnabled,
                  onChanged: (newValue) {
                    // Update the setting via SettingsModel
                    settings.toggleContentControl();
                    _applyContentControl(newValue);
                  },
                ),
                const SizedBox(height: 20.0),
                // Form for adding countries and cities
                Expanded(
                  child: AddLocationForm(
                    onUpdateCountryList: (newCountry) => _updateCountryList(
                        context, newCountry, defaultCountries, addedCountries),
                    defaultCountries: defaultCountries,
                    addedCountries: addedCountries,
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

// AddLocationForm widget for administrators to add countries and cities
class AddLocationForm extends StatefulWidget {
  final Function(Country) onUpdateCountryList;
  final List<String> defaultCountries;
  final List<String> addedCountries;

  const AddLocationForm(
      {super.key,
      required this.onUpdateCountryList,
      required this.defaultCountries,
      required this.addedCountries});

  @override
  _AddLocationFormState createState() => _AddLocationFormState();
}

class _AddLocationFormState extends State<AddLocationForm> {
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  List<Country> countries = [];

  void _submitForm() {
    // Retrieve entered data from controllers
    String newCountryName = _countryController.text.trim();
    String newCityName = _cityController.text.trim();

    // Create a new country object
    Country newCountry = Country(name: newCountryName, cities: [newCityName]);

    // Add the new country to the list of countries
    setState(() {
      countries.add(newCountry);
    });

    // Notify the parent widget about the new country
    widget.onUpdateCountryList(newCountry);

    // Clear text fields after submission
    _countryController.clear();
    _cityController.clear();
  }

  @override
  Widget build(BuildContext context) {
    List<String> allCountries = [
      ...widget.defaultCountries,
      ...widget.addedCountries
    ];

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Add Location',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextField(
            controller: _countryController,
            decoration: const InputDecoration(
              labelText: 'Country',
              hintText: 'Enter country name',
            ),
          ),
          TextField(
            controller: _cityController,
            decoration: const InputDecoration(
              labelText: 'City',
              hintText: 'Enter city name',
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitForm,
            child: const Text('Submit'),
          ),
          const SizedBox(height: 20),
          const Text(
            'Added Locations:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: allCountries.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5.0),
                  child: ListTile(
                    title: Text(
                      allCountries[index],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: countries
                          .where(
                              (country) => country.name == allCountries[index])
                          .expand((country) =>
                              country.cities.map((city) => Text('- $city')))
                          .toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Country {
  final String name;
  final List<String> cities;

  Country({required this.name, required this.cities});
}

void _applyContentControl(bool newValue) {
  // Add logic to apply content control based on the new setting
  // For example, hide certain features or content sections if content control is enabled
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
