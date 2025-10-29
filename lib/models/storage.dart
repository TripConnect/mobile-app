import 'dart:io';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/constants/common.dart';
import 'package:mobile_app/models/user.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/io_client.dart' as http_io;

Future<GraphQLClient> createGraphQLClient() async {
  final dio = Dio();

  final dir = await getApplicationDocumentsDirectory();
  final cookieJar = PersistCookieJar(
    storage: FileStorage("${dir.path}/.cookies/"),
  );
  dio.interceptors.add(CookieManager(cookieJar));

  final ioClient = HttpClient();
  ioClient.badCertificateCallback = (cert, host, port) => true; // Dev only
  dio.httpClientAdapter = IOHttpClientAdapter(createHttpClient: () => ioClient);

  final clientForGraphQL = http_io.IOClient(ioClient);

  final httpLink = HttpLink(
    gqlEndpoint,
    httpClient: clientForGraphQL,
  );

  return GraphQLClient(
    cache: GraphQLCache(),
    link: httpLink,
  );
}

class GlobalStorage with ChangeNotifier {
  Locale _locale = Locale(Language.en.name);
  UserInfo _currentUser = defaultUser;
  ValueNotifier<GraphQLClient> _gqlClient = ValueNotifier(GraphQLClient(
    cache: GraphQLCache(),
    link: HttpLink(gqlEndpoint)
  ));

  Future<void> init() async {
    final client = await createGraphQLClient();
    _gqlClient = ValueNotifier(client);
    notifyListeners();
  }

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
