import 'package:catch22_flutter/screens/wrapper.dart';
import 'package:catch22_flutter/shared/button_widget.dart';
import 'package:catch22_flutter/shared/form_textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:catch22_flutter/services/auth.dart';
import 'package:catch22_flutter/screens/authenticate/sign_in.dart';

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String email = '';
  String password = '';
  String userName = '';
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
                    "Register",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 45,
                        fontWeight: FontWeight.bold),
                  )),
                  SizedBox(
                    height: 140,
                  ),
                  TextFieldWidget(
                      isLast: false,
                      isEmail: false,
                      validator: ((val) =>
                          val.isEmpty ? 'Enter a username' : null),
                      obscureText: false,
                      hintText: "User Name",
                      prefixIconData: Icons.person_outline,
                      onChanged: (val) {
                        setState(() => userName = val);
                      }),
                  SizedBox(
                    height: 10,
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
                    height: 10,
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
                      }),
                  Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 14.0),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  ButtonWidget(
                    text: "Register",
                    hasBorder: false,
                    onClick: () async {
                      if (_formKey.currentState.validate()) {
                        setState(() => loading = true);
                        dynamic result = await _auth.createUser(
                          userName.trimRight(),
                          email.trimRight(),
                          password.trimRight(),
                        );

                        // TODO: Add different error based on result

                        if (result == null) {
                          setState(() {
                            error = "Email or password invalid";
                            loading = false;
                          });
                        } else {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Wrapper()));
                        }
                      }
                    },
                  ),
                  SizedBox(
                    height: 1,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Already have an acount?"),
                      FlatButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => SignIn()));
                          },
                          child: Text(
                            "Sign In",
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
