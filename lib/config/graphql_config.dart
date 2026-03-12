import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLConfig {
  static const String _endpoint = 'https://countries.trevorblades.com/graphql';

  static ValueNotifier<GraphQLClient> get client {
    final httpLink = HttpLink(_endpoint);

    return ValueNotifier(
      GraphQLClient(
        link: httpLink,
        cache: GraphQLCache(store: InMemoryStore()),
      ),
    );
  }
}
