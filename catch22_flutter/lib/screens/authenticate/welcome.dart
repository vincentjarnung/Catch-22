import 'package:catch22_flutter/screens/authenticate/register.dart';
import 'package:catch22_flutter/screens/authenticate/sign_in.dart';
import 'package:catch22_flutter/shared/button_widget.dart';
import 'package:flutter/material.dart';

class Welcome extends StatefulWidget {
  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                    child: Text(
                  "Welcome",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 45,
                      fontWeight: FontWeight.bold),
                )),
                SizedBox(
                  height: 180,
                ),
                ButtonWidget(
                  text: "Sign In",
                  hasBorder: false,
                  onClick: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignIn()));
                  },
                ),
                SizedBox(
                  height: 40,
                ),
                ButtonWidget(
                  text: "Register",
                  hasBorder: true,
                  onClick: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => Register()));
                  },
                ),
              ],
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Text("Powered by Catch-22"),
            )
          ],
        ),
      ),
    );
  }
}
