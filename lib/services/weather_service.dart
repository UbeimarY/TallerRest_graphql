import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather.dart';

const Map<String, Map<String, double>> _capitalCoords = {
  'Bogotá': {'lat': 4.6097, 'lon': -74.0817},
  'Buenos Aires': {'lat': -34.6037, 'lon': -58.3816},
  'Madrid': {'lat': 40.4168, 'lon': -3.7038},
  'Mexico City': {'lat': 19.4326, 'lon': -99.1332},
  'London': {'lat': 51.5074, 'lon': -0.1278},
  'Paris': {'lat': 48.8566, 'lon': 2.3522},
  'Tokyo': {'lat': 35.6762, 'lon': 139.6503},
  'Beijing': {'lat': 39.9042, 'lon': 116.4074},
  'Washington D.C.': {'lat': 38.9072, 'lon': -77.0369},
  'Berlin': {'lat': 52.5200, 'lon': 13.4050},
  'Rome': {'lat': 41.9028, 'lon': 12.4964},
  'Brasília': {'lat': -15.7801, 'lon': -47.9292},
  'Lima': {'lat': -12.0464, 'lon': -77.0428},
  'Santiago': {'lat': -33.4489, 'lon': -70.6693},
  'Caracas': {'lat': 10.4806, 'lon': -66.9036},
  'Quito': {'lat': -0.1807, 'lon': -78.4678},
  'La Paz': {'lat': -16.5000, 'lon': -68.1500},
  'Asunción': {'lat': -25.2867, 'lon': -57.6470},
  'Montevideo': {'lat': -34.9011, 'lon': -56.1645},
  'Ottawa': {'lat': 45.4215, 'lon': -75.6972},
  'Canberra': {'lat': -35.2809, 'lon': 149.1300},
  'Moscow': {'lat': 55.7558, 'lon': 37.6173},
  'Cairo': {'lat': 30.0444, 'lon': 31.2357},
  'Nairobi': {'lat': -1.2921, 'lon': 36.8219},
  'Pretoria': {'lat': -25.7479, 'lon': 28.2293},
  'Accra': {'lat': 5.6037, 'lon': -0.1870},
  'Abuja': {'lat': 9.0765, 'lon': 7.3986},
  'Addis Ababa': {'lat': 9.0320, 'lon': 38.7469},
  'Kinshasa': {'lat': -4.4419, 'lon': 15.2663},
  'Algiers': {'lat': 36.7372, 'lon': 3.0865},
  'Rabat': {'lat': 34.0209, 'lon': -6.8416},
  'Tunis': {'lat': 36.8065, 'lon': 10.1815},
  'Riyadh': {'lat': 24.7136, 'lon': 46.6753},
  'Tehran': {'lat': 35.6892, 'lon': 51.3890},
  'Baghdad': {'lat': 33.3152, 'lon': 44.3661},
  'Islamabad': {'lat': 33.6844, 'lon': 73.0479},
  'New Delhi': {'lat': 28.6139, 'lon': 77.2090},
  'Dhaka': {'lat': 23.8103, 'lon': 90.4125},
  'Bangkok': {'lat': 13.7563, 'lon': 100.5018},
  'Jakarta': {'lat': -6.2088, 'lon': 106.8456},
  'Kuala Lumpur': {'lat': 3.1390, 'lon': 101.6869},
  'Manila': {'lat': 14.5995, 'lon': 120.9842},
  'Seoul': {'lat': 37.5665, 'lon': 126.9780},
  'Hanoi': {'lat': 21.0285, 'lon': 105.8542},
  'Singapore': {'lat': 1.3521, 'lon': 103.8198},
  'Kathmandu': {'lat': 27.7172, 'lon': 85.3240},
  'Kabul': {'lat': 34.5553, 'lon': 69.2075},
  'Kiev': {'lat': 50.4501, 'lon': 30.5234},
  'Warsaw': {'lat': 52.2297, 'lon': 21.0122},
  'Prague': {'lat': 50.0755, 'lon': 14.4378},
  'Vienna': {'lat': 48.2082, 'lon': 16.3738},
  'Budapest': {'lat': 47.4979, 'lon': 19.0402},
  'Bucharest': {'lat': 44.4268, 'lon': 26.1025},
  'Sofia': {'lat': 42.6977, 'lon': 23.3219},
  'Athens': {'lat': 37.9838, 'lon': 23.7275},
  'Lisbon': {'lat': 38.7167, 'lon': -9.1399},
  'Amsterdam': {'lat': 52.3676, 'lon': 4.9041},
  'Brussels': {'lat': 50.8503, 'lon': 4.3517},
  'Bern': {'lat': 46.9481, 'lon': 7.4474},
  'Stockholm': {'lat': 59.3293, 'lon': 18.0686},
  'Oslo': {'lat': 59.9139, 'lon': 10.7522},
  'Copenhagen': {'lat': 55.6761, 'lon': 12.5683},
  'Helsinki': {'lat': 60.1699, 'lon': 24.9384},
  'Dublin': {'lat': 53.3498, 'lon': -6.2603},
  'Reykjavik': {'lat': 64.1355, 'lon': -21.8954},
  'Wellington': {'lat': -41.2865, 'lon': 174.7762},
};

class WeatherService {
  static const String _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  Future<Weather?> getWeatherForCapital(String capital) async {
    Map<String, double>? coords;
    for (final key in _capitalCoords.keys) {
      if (capital.toLowerCase().contains(key.toLowerCase()) ||
          key.toLowerCase().contains(capital.toLowerCase())) {
        coords = _capitalCoords[key];
        break;
      }
    }
    coords ??= {'lat': 0.0, 'lon': 0.0};
    return getWeatherByCoords(coords['lat']!, coords['lon']!);
  }

  Future<Weather?> getWeatherByCoords(double lat, double lon) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl?latitude=$lat&longitude=$lon'
        '&current=temperature_2m,wind_speed_10m,weather_code'
        '&timezone=auto',
      );
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return Weather.fromJson(
            json.decode(response.body) as Map<String, dynamic>);
      }
    } catch (_) {
      // retorna null
    }
    return null;
  }
}
