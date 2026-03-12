import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/theme.dart';
import '../models/country.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';
import '../widgets/weather_card.dart';

class CountryDetailScreen extends StatefulWidget {
  final Country country;

  const CountryDetailScreen({super.key, required this.country});

  @override
  State<CountryDetailScreen> createState() => _CountryDetailScreenState();
}

class _CountryDetailScreenState extends State<CountryDetailScreen> {
  Weather? _weather;
  bool _weatherLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    if (widget.country.capital.isEmpty) {
      setState(() => _weatherLoading = false);
      return;
    }
    final weather =
        await WeatherService().getWeatherForCapital(widget.country.capital);
    setState(() {
      _weather = weather;
      _weatherLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.country;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(c),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                _buildWeatherSection(c),
                const SizedBox(height: 24),
                _buildInfoSection(c),
                const SizedBox(height: 24),
                _buildLanguagesSection(c),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(Country c) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppTheme.background,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primary.withValues(alpha: 0.6),
                AppTheme.background,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Text(
                  c.emoji,
                  style: const TextStyle(fontSize: 80),
                ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                Text(
                  c.name,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 200.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeatherSection(Country c) {
    if (c.capital.isEmpty) return const SizedBox.shrink();

    if (_weatherLoading) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        height: 120,
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(24),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    if (_weather == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.card,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            const Text('🌐', style: TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weather unavailable',
                  style: TextStyle(
                      color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Capital: ${c.capital}',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      );
    }

    return WeatherCard(weather: _weather!, capital: c.capital);
  }

  Widget _buildInfoSection(Country c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Country Info',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _infoGrid(c),
        ],
      ),
    );
  }

  Widget _infoGrid(Country c) {
    final items = [
      {
        'icon': '🏙️',
        'label': 'Capital',
        'value': c.capital.isEmpty ? 'N/A' : c.capital
      },
      {'icon': '🌎', 'label': 'Continent', 'value': c.continent},
      {
        'icon': '💱',
        'label': 'Currency',
        'value': c.currency.isEmpty ? 'N/A' : c.currency
      },
      {'icon': '🏷️', 'label': 'Code', 'value': c.code},
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.2,
      children: items
          .asMap()
          .entries
          .map(
            (e) => _infoTile(
              e.value['icon']!,
              e.value['label']!,
              e.value['value']!,
              e.key,
            ),
          )
          .toList(),
    );
  }

  Widget _infoTile(String icon, String label, String value, int idx) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 10,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: idx * 80))
        .fadeIn()
        .slideY(begin: 0.2, end: 0);
  }

  Widget _buildLanguagesSection(Country c) {
    if (c.languages.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🗣️ Languages',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: c.languages
                .asMap()
                .entries
                .map(
                  (e) => Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primary.withValues(alpha: 0.2),
                          AppTheme.secondary.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      e.value,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                      .animate(delay: Duration(milliseconds: e.key * 60))
                      .fadeIn()
                      .scale(begin: const Offset(0.8, 0.8)),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}
