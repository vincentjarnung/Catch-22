import 'package:catch22_flutter/screens/home/bottom_navigation_bar.dart';
import 'package:catch22_flutter/screens/wrapper.dart';
import 'package:catch22_flutter/services/database.dart';
import 'package:catch22_flutter/shared/button_widget.dart';
import 'package:flutter/material.dart';

class GetSteps extends StatefulWidget {
  @override
  _GetStepsState createState() => _GetStepsState();
}

class _GetStepsState extends State<GetSteps> {
  final DatabaseService _db = DatabaseService();

  void initState() {
    super.initState();
    _db.setSteps();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: 50,
          ),
          Padding(
            padding: const EdgeInsets.all(50.0),
            child: Text(
                'With this app we are not able to get steps from your device we will therefore randomize some stepdata for you.'),
          ),
          ButtonWidget(
            hasBorder: false,
            text: 'Continue',
            onClick: () {
              Navigator.pushReplacement(
                  context, MaterialPageRoute(builder: (context) => Wrapper()));
            },
          )
        ],
      ),
    );
  }
}
