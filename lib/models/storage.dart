import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/constants/common.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_app/models/user.dart';

class GlobalStorage with ChangeNotifier {
  Locale _locale = Locale(Language.en.name);
  UserInfo _currentUser = defaultUser;
  ValueNotifier<GraphQLClient> _gqlClient = ValueNotifier(
    GraphQLClient(
      link: AuthLink(
        getToken: () async => '',
      ).concat(HttpLink(graphqlServer)),
      cache: GraphQLCache(store: HiveStore()),
    ),
  );

  Locale get locale => _locale;
  UserInfo get currentUser => _currentUser;
  ValueNotifier<GraphQLClient> get gqlClient => _gqlClient;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  void updateCurrentUser(UserInfo currentUser) {
    _currentUser = currentUser;
    notifyListeners();
  }

  void updateGQLClient(String accessToken) {
    final HttpLink httpLink = HttpLink(graphqlServer);

    final AuthLink authLink = AuthLink(
      getToken: () async => 'Beaver $accessToken',
    );

    final Link link = authLink.concat(httpLink);

    _gqlClient = ValueNotifier(
      GraphQLClient(
        link: link,
        cache: GraphQLCache(store: HiveStore()),
      ),
    );
    notifyListeners();
  }
}
