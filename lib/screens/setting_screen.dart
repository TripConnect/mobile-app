import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:mobile_app/constants/common.dart';
import 'package:mobile_app/models/storage.dart';
import 'package:provider/provider.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<StatefulWidget> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  final FlutterLocalization localization = FlutterLocalization.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(paddingMedium),
        child: Column(
          children: <Widget>[
           Row(
             children: [
              const Icon(
                Icons.language,
                color: Colors.black,
                size: 40.0,
              ),
               const SizedBox(width: 20),
               DropdownButton<Locale>(
                  value: Localizations.localeOf(context),
                  onChanged: (Locale? newLocale) {
                    if (newLocale != null) {
                      print(newLocale);
                      Provider.of<GlobalStorage>(context, listen: false).setLocale(newLocale);
                    }
                  },
                  items: [
                    DropdownMenuItem(
                      value: Locale(Language.en.code),
                      child: Text(Language.en.text),
                    ),
                    DropdownMenuItem(
                      value: Locale(Language.vi.code),
                      child: Text(Language.vi.text),
                    ),
                  ],
               ),
             ],
           )
          ],
        ),
      ),
    );
  }
}