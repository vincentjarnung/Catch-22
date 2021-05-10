import 'package:catch22_flutter/models/simple_user.dart';
import 'package:catch22_flutter/models/steps_day.dart';
import 'package:catch22_flutter/screens/home/bottom_navigation_bar.dart';
import 'package:catch22_flutter/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'authenticate/welcome.dart';

class Wrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<SimpleUser>(context);
    print(user);
    if (user == null) {
      return Welcome();
    } else {
      return BottomNavBar();
    }
  }
}
