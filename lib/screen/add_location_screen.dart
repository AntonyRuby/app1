import 'package:flutter/material.dart';

class Country {
  final String name;
  final List<String> cities;

  Country({required this.name, required this.cities});
}

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
