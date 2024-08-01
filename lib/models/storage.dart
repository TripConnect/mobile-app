import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/constants/common.dart';
import 'package:mobile_app/main.dart';
import 'package:mobile_app/models/user.dart';

class Storage with ChangeNotifier {
  UserInfo _currentUser = UserInfo(
      id: "00000000-0000-0000-0000-000000000000",
      displayName: "Unknown",
      avatar: defaultUserAvatar
  );
  ValueNotifier<GraphQLClient> _gqlClient = ValueNotifier(
    GraphQLClient(
      link: AuthLink(
        getToken: () async => 'Beaver DEFAULT',
      ).concat(HttpLink(graphqlServer)),
      cache: GraphQLCache(store: HiveStore()),
    ),
  );

  UserInfo get currentUser => _currentUser;
  ValueNotifier<GraphQLClient> get gqlClient => _gqlClient;

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
