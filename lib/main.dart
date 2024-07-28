import 'package:flutter/material.dart';
import 'package:mobile_app/models/user.dart';
import 'package:mobile_app/screens/LoginScreen.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/screens/ProfileScreen.dart';

const graphqlServer = 'http://10.0.2.2:3107/graphql';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();

  final HttpLink httpLink = HttpLink(graphqlServer);

  final AuthLink authLink = AuthLink(
    getToken: () async => '',
  );

  final Link link = authLink.concat(httpLink);

  ValueNotifier<GraphQLClient> client = ValueNotifier(
    GraphQLClient(
      link: link,
      cache: GraphQLCache(store: HiveStore()),
    ),
  );

  runApp(Application(client: client));
}

class Application extends StatelessWidget {
  final ValueNotifier<GraphQLClient> client;
  late UserInfo _userInfo;

  Application({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        initialRoute: "/login",
        routes: {
          '/login': (context) => LoginScreen(
              onSignInSuccess: (UserInfo userInfo, Token token) {
                updateClientWithToken(client, token);
                _userInfo = userInfo;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(userInfo: userInfo),
                  ),
                );
              }
          ),
          '/profile': (context) => ProfileScreen(userInfo: _userInfo),
        },
        // home: SafeArea(
        //   child: LoginScreen(
        //     onSignInSuccess: (token) {
        //       updateClientWithToken(client, token);
        //     },
        //   ),
        // ),
      ),
    );
  }
}

void updateClientWithToken(ValueNotifier<GraphQLClient> client, Token token) {
  final HttpLink httpLink = HttpLink(graphqlServer);

  final AuthLink authLink = AuthLink(
    getToken: () async => 'Bearer ${token.accessToken}',
  );

  final Link newLink = authLink.concat(httpLink);

  client.value = GraphQLClient(
    link: newLink,
    cache: GraphQLCache(store: HiveStore()),
  );
}