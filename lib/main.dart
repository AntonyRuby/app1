import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CountrySelectionScreen(),
    );
  }
}

class CountrySelectionScreen extends StatelessWidget {
  final List<String> countries = ['USA', 'Canada', 'UK', 'UAE'];

  CountrySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Country'),
      ),
      body: ListView.builder(
        itemCount: countries.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(countries[index]),
            onTap: () {
              _launchChildApp(countries[index]);
            },
          );
        },
      ),
    );
  }

  void _launchChildApp(String selectedCountry) async {
    final String deepLink = 'myapp://childapp?country=$selectedCountry';
    if (await canLaunchUrl(Uri.parse(deepLink))) {
      await launchUrl(Uri.parse(deepLink));
    } else {
      throw 'Could not launch $deepLink';
    }
  }
}
