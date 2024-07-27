import 'package:flutter/material.dart';
import 'package:first_app/screens/LoginScreen.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

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

  const Application({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return GraphQLProvider(
      client: client,
      child: MaterialApp(
        home: SafeArea(
          child: LoginScreen(
            onLoginSuccess: (token) {
              updateClientWithToken(client, token);
            },
          ),
        ),
      ),
    );
  }
}

void updateClientWithToken(ValueNotifier<GraphQLClient> client, String token) {
  final HttpLink httpLink = HttpLink(graphqlServer);

  final AuthLink authLink = AuthLink(
    getToken: () async => 'Bearer $token',
  );

  final Link newLink = authLink.concat(httpLink);

  client.value = GraphQLClient(
    link: newLink,
    cache: GraphQLCache(store: HiveStore()),
  );
}