import 'package:flutter/material.dart';

class SFHMovment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('SFH Movement'),
          centerTitle: true,
          leading: Container(),
        ),
        body: Padding(
          padding: const EdgeInsets.all(9.0),
          child: Image.asset('assets/images/SFHMovement.png'),
        ));
  }
}
