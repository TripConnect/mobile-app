import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/models/storage.dart';
import 'package:mobile_app/screens/home_screen.dart';
import 'package:mobile_app/screens/login_screen.dart';
import 'package:mobile_app/screens/ProfileScreen.dart';
import 'package:mobile_app/models/user.dart';
import 'package:mobile_app/constants/common.dart';
import 'package:provider/provider.dart';

const graphqlServer = '$baseURL/graphql';

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

  runApp(
    ChangeNotifierProvider(
      create: (context) => Storage(),
        child: Application(client: client)
    )
  );
}

class Application extends StatelessWidget {
  final ValueNotifier<GraphQLClient> client;

  Application({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        builder: (context, child) {
          return SafeArea(child: child!);
        },
        initialRoute: "/login",
        routes: {
          '/login': (context) => LoginScreen(
              onSignInSuccess: (UserInfo userInfo, Token token) {
                updateClientWithToken(context, client, userInfo, token);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
              }
          ),
        },
      ),
    );
  }
}

void updateClientWithToken(
    BuildContext context, ValueNotifier<GraphQLClient> client, UserInfo userInfo, Token token) {
  final HttpLink httpLink = HttpLink(graphqlServer);
  final AuthLink authLink = AuthLink(
    getToken: () async => 'Bearer ${token.accessToken}',
  );
  final Link newLink = authLink.concat(httpLink);
  client.value = GraphQLClient(
    link: newLink,
    cache: GraphQLCache(store: HiveStore()),
  );

  var appData = Provider.of<Storage>(context);
  appData.updateCurrentUser(userInfo);
  appData.updateGQLClient(client);
}