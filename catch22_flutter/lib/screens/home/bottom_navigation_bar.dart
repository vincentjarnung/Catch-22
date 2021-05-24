import 'package:catch22_flutter/models/steps_day.dart';
import 'package:catch22_flutter/screens/home/competition.dart';
import 'package:catch22_flutter/screens/home/home.dart';
import 'package:catch22_flutter/screens/home/sfh_movment.dart';
import 'package:catch22_flutter/screens/home/trophies.dart';
import 'package:catch22_flutter/shared/constants/color_constants.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter/material.dart';

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int selIndex;

  @override
  void initState() {
    super.initState();
    setState(() {
      selIndex = 0;
    });
  }

  void onItemTapped(int index) {
    setState(() {
      selIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final widgetOptions = [Home(), SFHMovment(), Competition(), Trophies()];
    return Scaffold(
      body: Center(
        child: widgetOptions.elementAt(selIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        fixedColor: ColorConstants.kPrimaryColor,
        backgroundColor: ColorConstants.kSecoundaryColor,
        unselectedItemColor: ColorConstants.kSecoundaryColor,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.graphic_eq), label: 'SFH Movment'),
          BottomNavigationBarItem(
              icon: Icon(Icons.people_outline), label: 'Groups'),
          BottomNavigationBarItem(
              icon: Icon(Icons.military_tech_outlined), label: 'Trophies'),
        ],
        currentIndex: selIndex,
        onTap: onItemTapped,
      ),
    );
  }
}
