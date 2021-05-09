import 'dart:math';

import 'package:flutter/material.dart';

class ChangeDateWidget extends StatelessWidget {
  final String txt;
  final Function minus;
  final Function add;
  final Color addColor;

  ChangeDateWidget({@required this.txt, this.minus, this.add, this.addColor});
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
                Icons.remove,
                size: 30,
              ),
              onPressed: minus),
          Text(txt,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
          IconButton(
              icon: Icon(
                Icons.add,
                color: addColor == null ? Colors.black : addColor,
                size: 30,
              ),
              onPressed: add),
        ],
      ),
    );
  }
}
