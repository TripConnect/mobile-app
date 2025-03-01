import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/screens/login_screen.dart';
import 'package:provider/provider.dart';
import 'package:mobile_app/models/storage.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Application extends StatelessWidget {
  const Application({super.key});

  @override
  Widget build(BuildContext context) {
    var globalStorage = Provider.of<GlobalStorage>(context);

    return GraphQLProvider(
      client: globalStorage.gqlClient,
      child: MaterialApp(
        theme: ThemeData(fontFamily: 'inter'),
        locale: globalStorage.locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
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
