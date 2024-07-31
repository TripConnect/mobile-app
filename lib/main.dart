import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/models/storage.dart';
import 'package:mobile_app/screens/home_screen.dart';
import 'package:mobile_app/screens/login_screen.dart';
import 'package:mobile_app/screens/profile_screen.dart';
import 'package:mobile_app/models/user.dart';
import 'package:mobile_app/constants/common.dart';
import 'package:provider/provider.dart';

const graphqlServer = '$baseURL/graphql';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();

  runApp(
    ChangeNotifierProvider(
      create: (context) => Storage(),
        child: const Application()
    )
  );
}

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    var globalStorage = Provider.of<Storage>(context);

    return GraphQLProvider(
      client: globalStorage.gqlClient,
      child: MaterialApp(
        builder: (context, child) {
          return SafeArea(child: child!);
        },
        initialRoute: "/login",
        routes: {
          '/login': (context) => const LoginScreen(),
        },
      ),
    );
  }
}
