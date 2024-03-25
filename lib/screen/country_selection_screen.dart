import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

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
    const String authToken = 'sample_auth_token';
    final String deepLink =
        'myapp://childapp?country=$selectedCountry&token=$authToken&cities=${addedCities?.join(",")}';
    if (await canLaunchUrl(Uri.parse(deepLink))) {
      await launchUrl(Uri.parse(deepLink));
    } else {
      throw 'Could not launch $deepLink';
    }
  }
}
