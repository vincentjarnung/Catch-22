import 'package:catch22_flutter/charts/steps_chart.dart';
import 'package:catch22_flutter/models/steps_day.dart';
import 'package:catch22_flutter/shared/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'dart:async';

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
        padding: const EdgeInsets.all(90.0),
        child: Center(
            child: Column(
          children: [
            SfRadialGauge(
              axes: <RadialAxis>[
                RadialAxis(
                    minimum: 0,
                    maximum: 8000,
                    showLabels: false,
                    showTicks: false,
                    axisLineStyle: AxisLineStyle(
                      thickness: 0.2,
                      cornerStyle: CornerStyle.bothCurve,
                      color: Color.fromARGB(100, 244, 194, 80),
                      thicknessUnit: GaugeSizeUnit.factor,
                    ),
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                          positionFactor: 0.1,
                          angle: 90,
                          widget: Text(
                            7000.toStringAsFixed(0) + ' / 10000 steps',
                            style: TextStyle(fontSize: 15),
                          ))
                    ],
                    pointers: <GaugePointer>[
                      RangePointer(
                          value: 7000,
                          cornerStyle: CornerStyle.bothCurve,
                          width: 0.2,
                          sizeUnit: GaugeSizeUnit.factor,
                          color: ColorConstants.kPrimaryColor),
                    ]),
              ],
            )
          ],
        )),
      ),
    );
  }
}
