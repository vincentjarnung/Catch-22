import 'package:catch22_flutter/charts/steps_chart.dart';
import 'package:catch22_flutter/models/steps_day.dart';
import 'package:catch22_flutter/services/database.dart';
import 'package:catch22_flutter/shared/back_img_button_widget.dart';
import 'package:catch22_flutter/shared/change_date_widget.dart';
import 'package:catch22_flutter/shared/constants/color_constants.dart';
import 'package:catch22_flutter/shared/img_button_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:intl/intl.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  DatabaseService _db = DatabaseService();

  final List<StepsDayModel> data = [
    StepsDayModel(date: "2021-05-01", steps: 7600),
    StepsDayModel(date: "2021-05-02", steps: 7000),
    StepsDayModel(date: "2021-05-03", steps: 8000),
    StepsDayModel(date: "2021-05-04", steps: 8200),
    StepsDayModel(date: "2021-05-05", steps: 7600),
    StepsDayModel(date: "2021-05-06", steps: 7000),
    StepsDayModel(date: "2021-05-07", steps: 8000),
    StepsDayModel(date: "2021-05-08", steps: 8200),
  ];
  double steps;
  int stepGoal;
  String errorTxt = '';
  DateTime cDate = DateTime.now();
  bool hasData = false;
  StateSetter _setter;
  List<StepsDayModel> chartData = [
    StepsDayModel(date: 'mon', steps: 7600),
    StepsDayModel(date: "tue", steps: 7000),
    StepsDayModel(date: "wed", steps: 8000),
    StepsDayModel(date: "thu", steps: 8200),
    StepsDayModel(date: "fri", steps: 7600),
    StepsDayModel(date: "sat", steps: 7000),
    StepsDayModel(date: "sun", steps: 8000),
    StepsDayModel(date: "mon", steps: 8200),
  ];

  List<StepsDayModel> tester = [];
  List<StepsDayModel> displaySteps = [];

  var formatter = new DateFormat('yyyy-MM-dd');

  void initState() {
    super.initState();
    _getDateAndSteps();
    _getStepGoal();
  }

  void _getSteps(DateTime date) {
    String fDate = formatter.format(date);
    double cSteps;
    print(cDate.toString() + ' 1');
    for (int i = 0; i < tester.length; i++) {
      if (tester[i].date == fDate) {
        cSteps = tester[i].steps;
        hasData = true;
        break;
      }
    }
    setState(() {
      steps = cSteps;
      cDate = date;
      if (steps == null) hasData = false;
      print(hasData);
    });
  }

  void _onSelected(BuildContext context, int item, int stepGoal) {
    int cStepGoal = stepGoal;

    switch (item) {
      case 0:
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                  content: StatefulBuilder(builder: (context, setState) {
                _setter = setState;
                return Container(
                  width: 200,
                  height: 170,
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text('Change Step Goal',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 20)),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 5, 0, 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                  icon: Icon(
                                    Icons.remove,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    _setter(() {
                                      cStepGoal -= 500;
                                    });
                                  }),
                              Text(cStepGoal.toString(),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 25)),
                              IconButton(
                                  icon: Icon(
                                    Icons.add,
                                    size: 30,
                                  ),
                                  onPressed: () {
                                    _setter(() {
                                      cStepGoal += 500;
                                      print(stepGoal);
                                    });
                                  }),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            BackImageButtonWidget(
                              icon: Icon(Icons.cancel),
                              text: 'Back',
                              onClick: () {
                                Navigator.of(context).pop();
                              },
                              width: 100,
                              height: 50,
                            ),
                            ImageButtonWidget(
                              icon: Icon(Icons.done),
                              text: 'Save',
                              onClick: () {
                                _getStepGoal();
                                _db.updateStepGoal(cStepGoal);
                                Navigator.of(context).pop();
                              },
                              width: 100,
                              height: 50,
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                );
              }));
            });
        break;
      case 1:
        break;
    }
  }

  Future _getStepGoal() async {
    Future<DocumentSnapshot> user = _db.user;
    user.then((snapshot) {
      var userDoc = snapshot.data();
      setState(() {
        stepGoal = userDoc['stepGoal'];
        print(stepGoal.toString() + ' Det funkar !!!!!!!!!!!!!!!!!!');
        return stepGoal;
      });
    });
  }

  Future _getDateAndSteps() async {
    Future<QuerySnapshot> steps = _db.steps;
    steps.then((snapshot) {
      snapshot.docs.forEach((doc) {
        tester.add(
            StepsDayModel(date: doc.id, steps: doc.data()['steps'].toDouble()));
      });
      print(tester);
      _getSteps(DateTime.now());
    });
  }

  void _lastWeekData(List<StepsDayModel> data) {
    for (int i = 1; i < tester.length; i++) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text('Home'),
          ),
          actions: <Widget>[
            PopupMenuButton(
                onSelected: (item) => _onSelected(context, item, stepGoal),
                itemBuilder: (context) => [
                      PopupMenuItem<int>(
                        value: 0,
                        child: Text('Change Goal'),
                      ),
                      PopupMenuItem<int>(
                        value: 1,
                        child: Text('Log Out'),
                      ),
                    ])
          ],
        ),
        body: SingleChildScrollView(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 20,
            ),
            Container(
              height: 125,
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
                                fontWeight: FontWeight.bold, fontSize: 20)),
                      )
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: SfLinearGauge(
                      axisTrackStyle:
                          LinearAxisTrackStyle(color: Colors.grey[350]),
                      maximum: stepGoal == null ? 100 : stepGoal.toDouble(),
                      barPointers: [
                        LinearBarPointer(
                          value: hasData ? steps : 0,
                          color: ColorConstants.kSecoundaryColor,
                        )
                      ],
                      showAxisTrack: true,
                      showLabels: false,
                      showTicks: false,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(40, 10, 40, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(''),
                            Text(hasData ? steps.toInt().toString() : '0',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20))
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('GOAL'),
                            Text(stepGoal.toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20))
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            ChangeDateWidget(
                txt: formatter.format(cDate),
                addColor:
                    formatter.format(cDate) == formatter.format(DateTime.now())
                        ? Colors.grey
                        : null,
                minus: () {
                  cDate = DateTime(cDate.year, cDate.month, cDate.day - 1);
                  _getSteps(cDate);
                },
                add: formatter.format(cDate) == formatter.format(DateTime.now())
                    ? null
                    : () {
                        cDate =
                            DateTime(cDate.year, cDate.month, cDate.day + 1);
                        _getSteps(cDate);
                      }),
            SizedBox(
              height: 20,
            ),
            ImageButtonWidget(
              icon: Icon(Icons.add),
              text: 'Add Activity',
              onClick: () {},
              width: 200,
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: 500,
                height: 300,
                child: StepsChart(
                  data: tester,
                ),
              ),
            ),
          ],
        )));
  }
}

abstract class AlertDialogCallback {
  void onPositive(Object object);
  void onNegative();
}
