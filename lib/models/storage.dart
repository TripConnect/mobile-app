import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/models/user.dart';

class Storage with ChangeNotifier {
  late UserInfo _currentUser;
  late ValueNotifier<GraphQLClient> _gqlClient;

  UserInfo get currentUser => _currentUser;
  ValueNotifier<GraphQLClient> get gqlClient => _gqlClient;

  void updateCurrentUser(UserInfo currentUser) {
    _currentUser = currentUser;
    notifyListeners();
  }

  void updateGQLClient(ValueNotifier<GraphQLClient> gqlClient) {
    _gqlClient = gqlClient;
    notifyListeners();
  }
}
