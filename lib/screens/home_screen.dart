import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../config/theme.dart';
import '../models/country.dart';
import '../services/country_service.dart';
import '../widgets/country_card.dart';
import '../widgets/shimmer_loader.dart';
import 'country_detail_screen.dart';

const List<Map<String, String>> continents = [
  {'code': 'ALL', 'name': '🌐 All'},
  {'code': 'AF', 'name': '🌍 Africa'},
  {'code': 'AN', 'name': '🧊 Antarctica'},
  {'code': 'AS', 'name': '🌏 Asia'},
  {'code': 'EU', 'name': '🏰 Europe'},
  {'code': 'NA', 'name': '🗽 N. America'},
  {'code': 'OC', 'name': '🏄 Oceania'},
  {'code': 'SA', 'name': '🌿 S. America'},
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _search = '';
  String _continent = 'ALL';
  List<Country> _allCountries = [];
  bool _loading = true;
  String? _error;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadCountries();
  }

  Future<void> _loadCountries() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final client = GraphQLProvider.of(context).value;
      final service = CountryService(client);

      List<Country> countries;
      if (_continent == 'ALL') {
        countries = await service.getAllCountries();
      } else {
        countries = await service.getCountriesByContinent(_continent);
      }

      setState(() {
        _allCountries = countries;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<Country> get _filtered {
    if (_search.isEmpty) return _allCountries;
    final q = _search.toLowerCase();
    return _allCountries
        .where((c) =>
            c.name.toLowerCase().contains(q) ||
            c.capital.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            _buildContinentFilter(),
            _buildCountCount(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🌍', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(width: 12),
              const Text(
                'World Explorer',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Discover countries, capitals & weather',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        style: const TextStyle(color: AppTheme.textPrimary),
        decoration: const InputDecoration(
          hintText: 'Search country or capital...',
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (v) => setState(() => _search = v),
      ),
    );
  }

  Widget _buildContinentFilter() {
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: continents.length,
        itemBuilder: (context, i) {
          final c = continents[i];
          final selected = c['code'] == _continent;
          return GestureDetector(
            onTap: () {
              setState(() => _continent = c['code']!);
              _loadCountries();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: selected ? AppTheme.primary : AppTheme.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppTheme.primary : AppTheme.surface,
                ),
              ),
              child: Text(
                c['name']!,
                style: TextStyle(
                  color: selected ? Colors.white : AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCountCount() {
    if (_loading) return const SizedBox(height: 8);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Text(
        '${_filtered.length} countries found',
        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) return const ShimmerLoader();

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⚠️', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            const Text(
              'Error loading countries',
              style: TextStyle(color: AppTheme.textPrimary, fontSize: 16),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _loadCountries,
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppTheme.primary),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_filtered.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('🔍', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text(
              'No countries found',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCountries,
      color: AppTheme.primary,
      child: ListView.builder(
        itemCount: _filtered.length,
        padding: const EdgeInsets.only(top: 8, bottom: 20),
        itemBuilder: (context, i) => CountryCard(
          country: _filtered[i],
          index: i,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CountryDetailScreen(country: _filtered[i]),
            ),
          ),
        ),
      ),
    );
  }
}
