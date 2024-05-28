// Import necessary packages
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/secrets.dart'; // Import API key (assuming it contains openWeatherAPIKey)
import 'package:weather_app/weather_forcast_hourly.dart'; // Import custom HourlyForecast widget
import 'package:http/http.dart' as http;

// Main widget for the Weather Screen
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  // Future method to fetch current weather data
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      // Specify the city name for which weather data is requested
      String cityName = 'Rajpura';
      
      // Make an HTTP GET request to OpenWeatherMap API
      final res = await http.get(
        Uri.parse('https://api.openweathermap.org/data/2.5/forecast?q=$cityName,in&APPID=$openWeatherAPIKey'),
      );
      
      // Decode the JSON response
      final data = jsonDecode(res.body);

      // Check if the API response indicates an error
      if (data['cod'] != '200') {
        throw 'An unexpected error occurred';
      }

      // Return the decoded data
      return data;
    } catch (e) {
      // Throw any exceptions that occur during the process
      throw e.toString();
    }
  }

  // Build method to create the UI for the Weather Screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar at the top of the screen
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          // Refresh button in the AppBar
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      // Main body of the screen
      body: FutureBuilder(
        // Asynchronously build a widget based on a Future<Map<String, dynamic>>
        future: getCurrentWeather(),
        builder: (context, snapshot) {
          // Check the connection state of the Future
          if (snapshot.connectionState == ConnectionState.waiting) {
            // Display a loading indicator while waiting for data
            return const Center(child: CircularProgressIndicator());
          }

          // Check if there was an error during the Future execution
          if (snapshot.hasError) {
            // Display an error message if there was an error
            return Center(child: Text(snapshot.error.toString()));
          }

          // Extract data from the snapshot
          final data = snapshot.data;
          final currentTemp = data!['list'][0]['main']['temp'];
          final currentSun = data['list'][0]['weather'][0]['main'];
          final humidity = data['list'][0]['main']['humidity'];
          final pressure = data['list'][0]['main']['pressure'];
          final windSpeed = data['list'][0]['wind']['speed'];

          // Return the main UI structure using a Padding widget
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main card displaying current weather information
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Display current temperature
                              Text(
                                '$currentTemp K',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // Display an icon and current weather condition
                              const Icon(
                                Icons.cloud,
                                size: 64,
                              ),
                              Text(
                                currentSun,
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Section for displaying hourly forecast
                const Text(
                  'Hourly Forecast',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16,),
                // ListView to horizontally display hourly forecast data
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: (data['list'] as List?)?.length ?? 0,
                    itemBuilder: (context, index) {
                      // Extract hourly forecast data for each index
                      final hourlyForecastData = data['list']?[index + 1];
                      if (hourlyForecastData != null) {
                        // Parse timestamp and create HourlyForecast widget
                        final time = DateTime.parse(hourlyForecastData['dt_txt']);
                        return HourlyForcast(
                          icon: hourlyForecastData['weather'][0]['main'] == 'Clouds' ||
                                  hourlyForecastData['weather'][0]['main'] == 'Rain'
                              ? Icons.cloud
                              : Icons.sunny,
                          label: DateFormat.Hm().format(time),
                          value: hourlyForecastData['main']['temp'].toString(),
                        );
                      } else {
                        // Handle the case when hourlyForecastData is null (optional)
                        return Container(); // or any other widget or null
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20,),
                // Section for displaying additional information
                const Text(
                  'Additional Information',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20,),
                // Row containing widgets for humidity, wind speed, and pressure
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.water_drop,
                            size: 32,
                          ),
                          const Text(
                            'Humidity',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '$humidity',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(15.0),
                      width: 150,
                      child: Column(
                        children: [
                          const Icon(
                            Icons.air,
                            size: 32,
                          ),
                          const Text(
                            'Wind Speed',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '$windSpeed',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(15.0),
                      width: 110,
                      child: Column(
                        children: [
                          const Icon(
                            Icons.umbrella,
                            size: 32,
                          ),
                          const Text(
                            'Pressure',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '$pressure',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
