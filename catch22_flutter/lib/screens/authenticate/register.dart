import 'package:catch22_flutter/screens/authenticate/get_steps.dart';
import 'package:catch22_flutter/services/database.dart';
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
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  String email = '';
  String password = '';
  String userName = '';
  String error = '';
  int stepGoal = 7500;

  void initState() {
    super.initState();
  }

  void _addSteps() {
    setState(() {
      stepGoal += 500;
    });
  }

  void _minusSteps() {
    setState(() {
      stepGoal -= 500;
    });
  }

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
                    height: 100,
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
                    padding: const EdgeInsets.fromLTRB(18.0, 18, 18, 5),
                    child: Text(
                      error,
                      style: TextStyle(color: Colors.red, fontSize: 14.0),
                    ),
                  ),
                  Text('Set Step Goal (This can be changed later)'),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            _minusSteps();
                          }),
                      Text(stepGoal.toString(),
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20)),
                      IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () {
                            _addSteps();
                          }),
                    ],
                  ),
                  SizedBox(
                    height: 20,
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
                          stepGoal,
                        );
                        _db.setSteps();
                        // TODO: Add different error based on result

                        if (result == null) {
                          setState(() {
                            error = "Email or password invalid";
                            loading = false;
                          });
                        } else {
                          print('Trolololololol');
                          /*Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignIn()));*/
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
                      TextButton(
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
