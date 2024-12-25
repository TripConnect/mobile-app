import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/constants/common.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_app/models/user.dart';

final HttpLink httpLink = HttpLink(graphqlServer);

class GlobalStorage with ChangeNotifier {
  Locale _locale = Locale(Language.en.name);
  UserInfo _currentUser = defaultUser;
  Token? _token;
  ValueNotifier<GraphQLClient> _gqlClient = ValueNotifier(
    GraphQLClient(
      link: AuthLink(
        getToken: () async => '',
      ).concat(httpLink),
      cache: GraphQLCache(store: HiveStore()),
    ),
  );

  Locale get locale => _locale;
  UserInfo get currentUser => _currentUser;
  Token? get token => _token;
  ValueNotifier<GraphQLClient> get gqlClient => _gqlClient;

  void setLocale(Locale locale) {
    _locale = locale;
    notifyListeners();
  }

  void updateCurrentUser(UserInfo currentUser) {
    _currentUser = currentUser;
    notifyListeners();
  }

  void updateGQLClient(Token token) {
    _token = token;


    final AuthLink authLink = AuthLink(
      getToken: () async => 'Beaver ${token.accessToken}',
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
