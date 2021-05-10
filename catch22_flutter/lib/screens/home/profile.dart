import 'package:catch22_flutter/services/auth.dart';
import 'package:flutter/material.dart';

import '../wrapper.dart';

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  AuthService _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: TextButton(
          onPressed: () {
            _auth.signOut().whenComplete(() => Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => Wrapper())));
          },
          child: Text("Logg Out")),
    );
  }
}
