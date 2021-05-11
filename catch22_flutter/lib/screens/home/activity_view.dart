import 'package:catch22_flutter/services/database.dart';
import 'package:catch22_flutter/shared/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class ActivityView extends StatefulWidget {
  final String aName;

  ActivityView({@required this.aName});

  @override
  _ActivityViewState createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  final DatabaseService _db = DatabaseService();
  double totStepGoal;
  double totCurSteps;
  double todayStepGoal;
  double todayCurStep;
  int daysLeft;

  int _getDaysLeft(String end) {
    DateTime endDate = DateTime.parse(end);
    var diff = endDate.difference(DateTime.now()).inDays;
    return diff;
  }

  String _formatNumber(int numb) {
    String s = numb.toString();

    for (int i = 1, n = s.length - 1; i < s.length; i++, n--) {
      print(i);
      if (i % 3 == 0) {
        String sub = s.substring(n);
        s = s.replaceRange(n, s.length, ' ' + sub);
      }
    }
    return s;
  }

  @override
  Widget build(BuildContext context) {
    print(widget.aName);
    double heightOfScreen = MediaQuery.of(context).size.height;
    double widthOfScreen = MediaQuery.of(context).size.width;
    return StreamBuilder(
        stream: _db.viewActivity(widget.aName),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          } else {
            totStepGoal = snapshot.data['goal'].toDouble();
            totCurSteps = snapshot.data['currentSteps'].toDouble();

            daysLeft = _getDaysLeft(snapshot.data['endDate']);
            todayStepGoal = (totStepGoal ~/ daysLeft).toDouble();
            todayCurStep = (totCurSteps ~/ daysLeft).toDouble();
            return Scaffold(
              appBar: AppBar(
                title: Text(widget.aName),
                centerTitle: true,
              ),
              body: SingleChildScrollView(
                  child: Column(
                children: [
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    height: 170,
                    width: 370,
                    decoration: BoxDecoration(
                        color: ColorConstants.kyellow,
                        borderRadius: BorderRadius.all(
                          Radius.circular(30),
                        )),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 10, 0),
                          child: Row(children: [
                            Image.asset(
                              'assets/images/steps.png',
                              width: 30,
                              height: 30,
                              fit: BoxFit.cover,
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Text('Steps',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20)),
                            )
                          ]),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                          child: SfLinearGauge(
                            axisTrackStyle:
                                LinearAxisTrackStyle(color: Colors.grey[350]),
                            maximum: totStepGoal,
                            barPointers: [
                              LinearBarPointer(
                                enableAnimation: false,
                                value: totCurSteps,
                                color: ColorConstants.kSecoundaryColor,
                              )
                            ],
                            showAxisTrack: true,
                            showLabels: false,
                            showTicks: false,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Text(''),
                                  Text(totCurSteps.toInt().toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20))
                                ],
                              ),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('GOAL'),
                                  Text(totStepGoal.toInt().toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20))
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 10, 10),
                          child: Row(
                            children: [
                              Icon(Icons.calendar_today_sharp),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                daysLeft.toString() + ' days left',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: heightOfScreen * 0.09,
                    width: widthOfScreen,
                  ),
                  Container(
                    height: heightOfScreen * 0.3,
                    width: widthOfScreen * 0.8,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: ColorConstants.kyellow, width: 5.0)),
                    child: Column(
                      children: [
                        SizedBox(
                          height: heightOfScreen * 0.03,
                        ),
                        Text(
                          'Goal of the day',
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(
                          height: heightOfScreen * 0.02,
                        ),
                        Text(_formatNumber(todayStepGoal.toInt()) + ' steps',
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: heightOfScreen * 0.03,
                        ),
                        Text(
                          'Steps Taken',
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(
                          height: heightOfScreen * 0.02,
                        ),
                        Text(_formatNumber(todayCurStep.toInt()) + ' steps',
                            style: TextStyle(
                                fontSize: 25, fontWeight: FontWeight.bold)),
                        SizedBox(
                          height: heightOfScreen * 0.02,
                        ),
                      ],
                    ),
                  )
                ],
              )),
            );
          }
        });
  }
}
