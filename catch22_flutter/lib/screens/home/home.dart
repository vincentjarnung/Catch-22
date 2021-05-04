import 'package:catch22_flutter/charts/steps_chart.dart';
import 'package:catch22_flutter/models/steps_day.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<StepsDayModel> data = [
    StepsDayModel(date: "1 May", steps: 7600),
    StepsDayModel(date: "2 May", steps: 7000),
    StepsDayModel(date: "3 May", steps: 8000),
    StepsDayModel(date: "4 May", steps: 8200),
    StepsDayModel(date: "5 May", steps: 7600),
    StepsDayModel(date: "6 May", steps: 7000),
    StepsDayModel(date: "7 May", steps: 8000),
    StepsDayModel(date: "8 May", steps: 8200),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
            child: StepsChart(
          data: data,
        )),
      ),
    );
  }
}
