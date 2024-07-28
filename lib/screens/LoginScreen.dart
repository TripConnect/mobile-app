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
  final Function(UserInfo userInfo, Token token) onSignInSuccess;

  const LoginScreen({super.key, required this.onSignInSuccess});

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
              const Text(
                "Welcome back! Enter to enjoy you journey with everyone",
                style: TextStyle(
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
                        hintText: 'Username',
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
                          return 'Please enter your username';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _username = value ?? '';
                      },
                      initialValue: "sadboy1999",
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: 'Password',
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
                          return 'Please enter your password';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _password = value ?? '';
                      },
                      initialValue: "123456789",
                    ),
                    const SizedBox(height: 30),
                    Mutation(
                      options: MutationOptions(
                        document: gql(signInMutation),
                        onCompleted: (dynamic resultData) {
                          if(resultData != null) {
                            final signInData = SignInResponse.fromJson(resultData['signin']);
                            print(signInData.token.accessToken);
                            widget.onSignInSuccess(signInData.userInfo, signInData.token);
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
                            child: const Text('Sign In'),
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
                          child: const Text(
                              "Forgot password?",
                              style: TextStyle(color: Colors.black54)
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Colors.white30,
                            thickness: 0.6,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text('Or sign in with'),
                        ),
                        Expanded(
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
                        'assets/images/google-logo.png',
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
