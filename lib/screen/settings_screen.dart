import 'package:app1/main.dart';
import 'package:app1/screen/add_location_screen.dart';
import 'package:app1/screen/country_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

void _applyContentControl(bool newValue) {
  // Add logic to apply content control based on the new setting
  // For example, hide certain features or content sections if content control is enabled
}
