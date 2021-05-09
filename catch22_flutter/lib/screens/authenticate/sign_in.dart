import 'package:catch22_flutter/screens/authenticate/get_steps.dart';
import 'package:catch22_flutter/screens/authenticate/register.dart';
import 'package:catch22_flutter/screens/wrapper.dart';
import 'package:catch22_flutter/services/auth.dart';
import 'package:catch22_flutter/shared/button_widget.dart';
import 'package:catch22_flutter/shared/form_textfield_widget.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String email = '';
  String password = '';
  String error = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Center(
                      child: Text(
                    "Sign In",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 45,
                        fontWeight: FontWeight.bold),
                  )),
                  SizedBox(
                    height: 180,
                  ),
                  TextFieldWidget(
                      isLast: false,
                      isEmail: true,
                      validator: ((val) =>
                          val.isEmpty ? 'Enter a email' : null),
                      obscureText: false,
                      hintText: "Email",
                      prefixIconData: Icons.email_outlined,
                      onChanged: (val) {
                        setState(() => email = val);
                      }),
                  SizedBox(
                    height: 20,
                  ),
                  TextFieldWidget(
                    isLast: true,
                    isEmail: false,
                    obscureText: true,
                    hintText: "Password",
                    validator: ((val) =>
                        val.isEmpty ? 'Enter a valid password' : null),
                    prefixIconData: Icons.lock_outline,
                    onChanged: (val) {
                      setState(() => password = val);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 14.0),
                    ),
                  ),
                  SizedBox(
                    height: 80,
                  ),
                  ButtonWidget(
                    text: "Sign In",
                    hasBorder: false,
                    onClick: () async {
                      if (_formKey.currentState.validate()) {
                        setState(() => loading = true);
                        dynamic result = await _auth.signIn(
                            email.trimRight(), password.trimRight());

                        // TODO: Add different error based on result

                        if (result == null) {
                          setState(() {
                            error = "Email or password invalid";
                            loading = false;
                          });
                        } else {
                          print('trolololol');
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Wrapper()));
                        }
                      }
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?"),
                      TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Register()));
                          },
                          child: Text(
                            "Register",
                            style: TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline),
                          ))
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text("powered by Catch-22"),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
