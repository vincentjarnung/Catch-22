import 'package:catch22_flutter/models/steps_day.dart';
import 'package:catch22_flutter/shared/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class StepsChart extends StatelessWidget {
  final List<StepsDayModel> data;
  StepsChart({@required this.data});
  @override
  Widget build(BuildContext context) {
    List<charts.Series<StepsDayModel, String>> series = [
      charts.Series(
          id: "Steps",
          data: data,
          domainFn: (StepsDayModel series, _) => series.date,
          measureFn: (StepsDayModel series, _) => series.steps)
      //colorFn: (StepsDayModel series, _) => ColorConstants.kPrimaryColor,
    ];
    return charts.BarChart(
      series,
      animate: true,
    );
  }
}
