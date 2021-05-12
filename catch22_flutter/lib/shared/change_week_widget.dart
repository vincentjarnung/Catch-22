import 'dart:math';

import 'package:flutter/material.dart';

class ChangeWeekWidget extends StatelessWidget {
  final String txt;
  final Function minus;
  final Function add;
  final Color addColor;

  ChangeWeekWidget({@required this.txt, this.minus, this.add, this.addColor});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 250,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
                size: 30,
              ),
              onPressed: minus),
          Text(txt,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
          IconButton(
              icon: Icon(
                Icons.arrow_forward_ios,
                color: addColor == null ? Colors.black : addColor,
                size: 30,
              ),
              onPressed: add),
        ],
      ),
    );
  }
}
