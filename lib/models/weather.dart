class Weather {
  final double temperature;
  final double windSpeed;
  final int weatherCode;
  final String description;
  final String icon;

  Weather({
    required this.temperature,
    required this.windSpeed,
    required this.weatherCode,
    required this.description,
    required this.icon,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    final code = current['weather_code'] as int? ?? 0;
    return Weather(
      temperature: (current['temperature_2m'] as num).toDouble(),
      windSpeed: (current['wind_speed_10m'] as num).toDouble(),
      weatherCode: code,
      description: _getDescription(code),
      icon: _getIcon(code),
    );
  }

  static String _getDescription(int code) {
    if (code == 0) return 'Clear Sky';
    if (code <= 3) return 'Partly Cloudy';
    if (code <= 49) return 'Foggy';
    if (code <= 69) return 'Rainy';
    if (code <= 79) return 'Snowy';
    if (code <= 99) return 'Thunderstorm';
    return 'Unknown';
  }

  static String _getIcon(int code) {
    if (code == 0) return '☀️';
    if (code <= 3) return '⛅';
    if (code <= 49) return '🌫️';
    if (code <= 69) return '🌧️';
    if (code <= 79) return '❄️';
    if (code <= 99) return '⛈️';
    return '🌐';
  }
}
