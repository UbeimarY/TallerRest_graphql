import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';

class GraphQLConfig {
  static const String _endpoint = 'https://countries.trevorblades.com/graphql';

  static ValueNotifier<GraphQLClient> get client {
    final HttpLink httpLink = HttpLink(_endpoint);
    return ValueNotifier(
      GraphQLClient(
        link: httpLink,
        cache: GraphQLCache(store: InMemoryStore()),
      ),
    );
  }
}
