import 'package:mobile_app/models/user.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

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
  final Function(String token) onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

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
    return Scaffold(
      body: Container(
        color: Colors.white70,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.only(top: 150, left: 30, right: 30, bottom: 0),
          child: Column(
            children: <Widget>[
              const Text(
                "Welcome back! Enter to enjoy you journey with everyone",
                style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 25
                ),
              ),
              const SizedBox(height: 30),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Username'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _username = value ?? '';
                      },
                    ),
                    TextFormField(
                      decoration: const InputDecoration(labelText: 'Password'),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _password = value ?? '';
                      },
                    ),
                    const SizedBox(height: 30),
                    Mutation(
                      options: MutationOptions(
                        document: gql(signInMutation),
                        onCompleted: (dynamic resultData) {
                          if(resultData != null) {
                            final signInData = SignInResponse.fromJson(resultData['signin']);
                            print(signInData.token.accessToken);
                            widget.onLoginSuccess(signInData.token.accessToken);
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
                            child: const Text('Login'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 35),
                    const Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.grey,
                            thickness: 0.5,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('Or sign in with'),
                        ),
                        Expanded(
                          child: Divider(
                            color: Colors.grey,
                            thickness: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 35),
                    TextButton(
                      onPressed: _signInWithGoogle,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 35),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        backgroundColor: Colors.transparent,
                        side: const BorderSide(width: 0.8, color: Colors.grey),
                      ),
                      child: Image.network(
                        'https://image.similarpng.com/very-thumbnail/2020/06/Logo-google-icon-PNG.png',
                        fit: BoxFit.contain,
                        width: 30,
                      ),
                    ),
                    const SizedBox(height: 220),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Text("Don't have an account?"),
                        TextButton(
                            onPressed: (){},
                            child: const Text("Register now", style: TextStyle(color: Colors.teal, fontWeight: FontWeight.w700))
                        )
                      ],
                    ),
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
