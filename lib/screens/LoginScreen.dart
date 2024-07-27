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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'), backgroundColor: Colors.amber),
      body: Container(
        color: Colors.black87,
        height: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 300, horizontal: 50),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            height: 100,
            child: Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
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
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Mutation(
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
                          return TextButton(
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
                                borderRadius: BorderRadius.circular(18.0),
                              ),
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 50),
                            ),
                            child: const Text('Login'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
