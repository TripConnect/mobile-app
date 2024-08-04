import 'package:mobile_app/constants/common.dart';
import 'package:mobile_app/models/storage.dart';
import 'package:mobile_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:mobile_app/screens/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

const signInMutation = """
  mutation SignIn(\$username: String!, \$password: String!) {
    signin(username: \$username, password: \$password) {
      userInfo {
        id
        displayName
        avatar
      }
      token {
        accessToken
        refreshToken
      }
    }
  }
""";

class LoginScreen extends StatefulWidget {

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';

  _signInWithGoogle() {
    print("Feature not implemented");
  }

  @override
  Widget build(BuildContext context) {
    var globalStorage = Provider.of<GlobalStorage>(context);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          color: Colors.white70,
          image: DecorationImage(
            image: AssetImage('assets/images/app-background.jpg'),
            fit: BoxFit.cover, // Adjust as needed
          ),
        ),
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(top: 150, left: 30, right: 30, bottom: 0),
          child: Column(
            children: <Widget>[
               Text(
                 AppLocalizations.of(context)!.sign_up_welcome_message,
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 25
                ),
              ),
              const SizedBox(height: 40),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.username,
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black, width: 0.5), // Optional border color
                        ),
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyanAccent, width: 1), // Focused border color
                            borderRadius: BorderRadius.all(Radius.circular(8))
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.please_enter_your_username_alert;
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _username = value ?? '';
                      },
                      initialValue: _username,
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.password,
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Colors.black, width: 0.5), // Optional border color
                        ),
                        focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.cyanAccent, width: 1), // Focused border color
                            borderRadius: BorderRadius.all(Radius.circular(8))
                        ),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return AppLocalizations.of(context)!.please_enter_your_password_alert;
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _password = value ?? '';
                      },
                      initialValue: _password,
                    ),
                    const SizedBox(height: 30),
                    Mutation(
                      options: MutationOptions(
                        document: gql(signInMutation),
                        onCompleted: (dynamic resultData) {
                          if(resultData != null) {
                            final signInData = SignInResponse.fromJson(resultData['signin']);
                            globalStorage.updateCurrentUser(signInData.userInfo);
                            globalStorage.updateGQLClient(signInData.token.accessToken);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HomeScreen(),
                              ),
                            );
                          }
                        },
                        onError: (error) => print(error),
                      ),
                      builder: (RunMutation runMutation, QueryResult? result) {
                        return SizedBox(
                          width: double.infinity,
                          child: TextButton(
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                _formKey.currentState?.save();
                                runMutation({
                                  'username': _username,
                                  'password': _password,
                                });
                              }
                            },
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 50),
                            ),
                            child: Text(AppLocalizations.of(context)!.signIn),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {},
                          child: Text(
                              AppLocalizations.of(context)!.forgot_password_question,
                              style: const TextStyle(color: Colors.black54)
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Expanded(
                          child: Divider(
                            color: Colors.white30,
                            thickness: 0.6,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          child: Text(AppLocalizations.of(context)!.or_sign_in_with),
                        ),
                        const Expanded(
                          child: Divider(
                            color: Colors.white30,
                            thickness: 0.6,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    TextButton(
                      onPressed: _signInWithGoogle,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 35),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        backgroundColor: Colors.white,
                        side: const BorderSide(width: 0.8, color: Colors.black45),
                      ),
                      child: Image.asset(
                        googleLogoURL,
                        fit: BoxFit.contain,
                        width: 30,
                      ),
                    ),
                    const SizedBox(height: 200),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(AppLocalizations.of(context)!.do_not_have_account_question),
                        TextButton(
                            onPressed: (){},
                            child: Text(AppLocalizations.of(context)!.register_now, style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w700))
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.language,
                          color: Colors.black,
                          size: 20.0,
                        ),
                        const SizedBox(width: 10),
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
            ]
          ),
        ),
      ),
    );
  }
}
