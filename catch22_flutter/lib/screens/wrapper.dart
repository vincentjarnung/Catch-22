import 'package:catch22_flutter/screens/home/bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:catch22_flutter/screens/home/profile.dart';
import 'package:catch22_flutter/screens/authenticate/register.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<User>(context);
    print(user);
    if (user == null) {
      return Register();
    } else {
      return BottomNavBar();
    }
  }
}
