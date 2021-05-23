import 'dart:math';

import 'package:catch22_flutter/models/steps_day.dart';
import 'package:charts_flutter/flutter.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:charts_flutter/src/text_element.dart' as styletext;
import 'package:charts_flutter/src/text_style.dart' as style;

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
        measureFn: (StepsDayModel series, _) => series.steps,
        colorFn: (StepsDayModel series, _) =>
            charts.MaterialPalette.yellow.shadeDefault,
      )
    ];
    return charts.BarChart(
      series,
      animate: true,
      behaviors: [
        LinePointHighlighter(symbolRenderer: CustomCircleSymbolRenderer())
      ],
      selectionModels: [
        SelectionModelConfig(changedListener: (SelectionModel model) {
          if (model.hasDatumSelection) {
            final value =
                model.selectedSeries[0].measureFn(model.selectedDatum[0].index);
            CustomCircleSymbolRenderer.value = value.toInt().toString();
            print(model.selectedSeries[0]
                .measureFn(model.selectedDatum[0].index));
          }
        })
      ],
    );
  }
}

class CustomCircleSymbolRenderer extends CircleSymbolRenderer {
  static String value;
  @override
  void paint(ChartCanvas canvas, Rectangle<num> bounds,
      {List<int> dashPattern,
      Color fillColor,
      FillPatternType fillPattern,
      Color strokeColor,
      double strokeWidthPx}) {
    super.paint(canvas, bounds,
        dashPattern: dashPattern,
        fillColor: fillColor,
        fillPattern: fillPattern,
        strokeColor: strokeColor,
        strokeWidthPx: strokeWidthPx);
    canvas.drawRect(
        Rectangle(bounds.left - 5, bounds.top - 30, bounds.width + 38,
            bounds.height + 10),
        fill: Color.fromHex(code: '#F6D863'));
    var textStyle = style.TextStyle();
    textStyle.color = Color.black;
    textStyle.fontSize = 15;
    canvas.drawText(styletext.TextElement("$value", style: textStyle),
        (bounds.left).round(), (bounds.top - 28).round());
  }
}
