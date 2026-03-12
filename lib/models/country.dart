class Country {
  final String code;
  final String name;
  final String emoji;
  final String capital;
  final String continent;
  final List<String> languages;
  final String currency;

  Country({
    required this.code,
    required this.name,
    required this.emoji,
    required this.capital,
    required this.continent,
    required this.languages,
    required this.currency,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    final langs = (json['languages'] as List<dynamic>? ?? [])
        .map((l) => l['name'].toString())
        .toList();

    return Country(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      emoji: json['emoji'] ?? '🌐',
      capital: json['capital'] ?? '',
      continent: json['continent']?['name'] ?? '',
      languages: langs,
      currency: json['currency'] ?? '',
    );
  }
}
