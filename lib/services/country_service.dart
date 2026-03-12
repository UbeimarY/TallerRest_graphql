import 'package:graphql_flutter/graphql_flutter.dart';
import '../models/country.dart';

class CountryService {
  final GraphQLClient _client;

  CountryService(this._client);

  static const String _getAllCountriesQuery = r'''
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

  static const String _getByContinent = r'''
    query GetByContinent($filter: CountryFilterInput) {
      countries(filter: $filter) {
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
    return data
        .map((c) => Country.fromJson(c as Map<String, dynamic>))
        .toList();
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
    return data
        .map((c) => Country.fromJson(c as Map<String, dynamic>))
        .toList();
  }
}
