import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/constants/common.dart';
import 'package:mobile_app/models/user.dart';
import 'package:http/http.dart' as http;

final HttpLink httpLink = HttpLink(
  graphqlServer,
  httpClient: http.Client(),
);

class GlobalStorage with ChangeNotifier {
  Locale _locale = Locale(Language.en.name);
  UserInfo _currentUser = defaultUser;

  final ValueNotifier<GraphQLClient> _gqlClient = ValueNotifier(
    GraphQLClient(
      link: httpLink,
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

  void updateCurrentUser(UserInfo userInfo) {
    _currentUser = userInfo;
    notifyListeners();
  }

}
