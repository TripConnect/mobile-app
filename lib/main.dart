import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/application.dart';
import 'package:mobile_app/models/storage.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final globalStorage = GlobalStorage();

  await initHiveForFlutter();
  await globalStorage.init();

  runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => globalStorage)
        ],
        child: const Application()
    )
  );
}


