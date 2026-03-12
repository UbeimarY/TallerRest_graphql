import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/country.dart';

class CountryService {
  final GraphQLClient _client;

  CountryService(this._client);

  // Query para obtener todos los países
  static const String _getAllCountriesQuery = '''
    query GetAllCountries {
      countries {
        code
        name
        emoji
        capital
        currency
        continent {
          name
        }
        languages {
          name
        }
      }
    }
  ''';

  // Query para obtener países por continente
  static const String _getByContinent = '''
    query GetByContinent(\$filter: CountryFilterInput) {
      countries(filter: \$filter) {
        code
        name
        emoji
        capital
        currency
        continent {
          name
        }
        languages {
          name
        }
      }
    }
  ''';

  Future<List<Country>> getAllCountries() async {
    final result = await _client.query(
      QueryOptions(
        document: gql(_getAllCountriesQuery),
        fetchPolicy: FetchPolicy.cacheFirst,
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final data = result.data?['countries'] as List<dynamic>? ?? [];
    return data.map((c) => Country.fromJson(c)).toList();
  }

  Future<List<Country>> getCountriesByContinent(String continentCode) async {
    final result = await _client.query(
      QueryOptions(
        document: gql(_getByContinent),
        variables: {
          'filter': {
            'continent': {'eq': continentCode}
          }
        },
      ),
    );

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final data = result.data?['countries'] as List<dynamic>? ?? [];
    return data.map((c) => Country.fromJson(c)).toList();
  }
}
