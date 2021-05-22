import 'dart:io';

import 'package:catch22_flutter/charts/steps_chart.dart';
import 'package:catch22_flutter/models/steps_day.dart';
import 'package:catch22_flutter/screens/home/add_activity.dart';
import 'package:catch22_flutter/screens/home/bottom_navigation_bar.dart';
import 'package:catch22_flutter/services/auth.dart';
import 'package:catch22_flutter/services/database.dart';
import 'package:catch22_flutter/shared/back_img_button_widget.dart';
import 'package:catch22_flutter/shared/change_date_widget.dart';
import 'package:catch22_flutter/shared/change_week_widget.dart';
import 'package:catch22_flutter/shared/constants/color_constants.dart';
import 'package:catch22_flutter/shared/img_button_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import '../wrapper.dart';

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final DatabaseService _db = DatabaseService();
  final AuthService _auth = AuthService();

  List<StepsDayModel> tester = [];
  List<StepsDayModel> displaySteps = [];

  Stream<StepCount> _stepCountStream;
  StreamSubscription<StepCount> _subscription;
  String _weekDates = '';
  double _steps = 0;
  double _cSteps = 0;
  int _stepGoal;
  DateTime _cDate = DateTime.now();
  int _week = 0;
  StateSetter _setter;
  int _pSteps = 0;
  int _diff;

  var formatter = new DateFormat('yyyy-MM-dd');

  /*Future _getPermission() async {
    if (Platform.isIOS) {
      var status = await Permission.sensors.status;
      print('IOS!!!');
      if (status.isDenied) {
        print('denied');
        await Permission.sensors.request().whenComplete(() => setState(() {}));
      }
      if (status.isGranted) {
        print('granted');
        _stepCountStream = Pedometer.stepCountStream;
        _stepCountStream.listen(onStepCount, onError: onStepCountError);
      }
    } else {
      var status = await Permission.activityRecognition.status;
      if (status.isDenied) {
        print('denied');
        await Permission.activityRecognition
            .request()
            .whenComplete(() => setState(() {}));
      }
      if (status.isGranted) {
        print('granted');
        _stepCountStream = Pedometer.stepCountStream;
        _subscription =
            _stepCountStream.listen(onStepCount, onError: onStepCountError);
      }
    }
  }

  Future _updateMissingDateSteps() async {
    DateTime now = DateTime.now();
    print(_diff.toString() + ' asdas');
    if (_diff > 0) {
      int loc = _diff;
      for (; _diff > 0; _diff--) {
        String yesterday = DateFormat('yyyy-MM-dd')
            .format(DateTime(now.year, now.month, now.day - (_diff)));
        print(_steps);
        await _db
            .updateSteps((_steps) ~/ (loc), yesterday, true)
            .whenComplete(() => setState(() {}));
      }
    }
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {});
  }

  Future onStepCount(StepCount event) async {
    var savedData = await _db.getWalkedSteps();
    int walkedSteps = 0;
    int todaySteps;
    String lastDate;

    savedData.docs.forEach((element) {
      walkedSteps += element.data()['steps'];
      print(walkedSteps);
      print(element.id);
      lastDate = element.id;
    });

    String todayDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

    _diff =
        DateTime.parse(todayDate).difference(DateTime.parse(lastDate)).inDays -
            1;

    print(walkedSteps.toString() + 'asdasd');

    todaySteps = event.steps - walkedSteps;
    _pSteps = todaySteps;
    print(todaySteps.toString() + 'asdasd');
    setState(() {
      _steps = todaySteps.toDouble() + _cSteps;
    });
    print('first ' + todaySteps.toString());
    return todaySteps;
  }*/

  Future _getStepsD() async {
    return await _db.getDateAndSteps().then((snapshot) => setState(() {
          print('first');
          tester = snapshot;

          for (int i = 0; i < tester.length; i++) {
            print(tester[i].steps);
            print(tester[i].date);
          }
        }));
  }

  void initState() {
    super.initState();
    if (!mounted) return;

    _getStepsD().whenComplete(() {
      _getSteps(DateTime.now());
      //_db.updateSteps(_steps.toInt(), formatter.format(DateTime.now()), true);
      _lastWeekData(tester, DateTime.now());
      _getWeekDates();
    });
    _getStepGoal();
  }

  void _getSteps(DateTime date) {
    String fDate = formatter.format(date);
    for (int i = tester.length - 1; i >= 0; i--) {
      if (tester[i].date == fDate) {
        _cSteps = tester[i].steps;

        break;
      }
    }
    print('secound');
    setState(() {
      if (formatter.format(date) == formatter.format(DateTime.now())) {
        _steps = _pSteps.toDouble() + _cSteps;
      } else {
        _steps = _cSteps;
      }
      _cDate = date;
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
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => BottomNavBar()));
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
        _auth.signOut().whenComplete(() => Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => Wrapper())));
        break;
    }
  }

  Future _getStepGoal() async {
    Future<DocumentSnapshot> user = _db.user;
    user.then((snapshot) {
      var userDoc = snapshot.data();
      setState(() {
        _stepGoal = userDoc['stepGoal'];
        return _stepGoal;
      });
    });
  }

  void _lastWeekData(List<StepsDayModel> data, DateTime date) {
    int change = DateTime.now().difference(date).inDays;

    displaySteps = [];
    int i = data.length - 1 - change;

    for (int n = 6; n >= 0; n--) {
      if (i - n > 0) {
        DateTime days = DateTime(date.year, date.month, date.day - n);
        String dayOfWeek = DateFormat('EEEE').format(days);
        String dayShort = dayOfWeek.substring(0, 3);

        print(days);
        print(data[i - n].steps);

        displaySteps
            .add(StepsDayModel(date: dayShort, steps: data[i - n].steps));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: Container(),
          title: Text('Home'),
          centerTitle: true,
          actions: <Widget>[
            PopupMenuButton(
                onSelected: (item) => _onSelected(context, item, _stepGoal),
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
                      maximum: _stepGoal == null ? 100 : _stepGoal.toDouble(),
                      barPointers: [
                        LinearBarPointer(
                          enableAnimation: false,
                          value: _steps,
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
                            Text(_steps.toInt().toString(),
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 20))
                          ],
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('GOAL'),
                            Text(_stepGoal.toString(),
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
            ChangeWeekWidget(
                txt: Text(
                    formatter.format(_cDate) == formatter.format(DateTime.now())
                        ? 'Today'
                        : formatter.format(_cDate),
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                addColor:
                    formatter.format(_cDate) == formatter.format(DateTime.now())
                        ? Colors.grey
                        : null,
                minus: () {
                  _cDate = DateTime(_cDate.year, _cDate.month, _cDate.day - 1);
                  _getSteps(_cDate);
                },
                add: formatter.format(_cDate) ==
                        formatter.format(DateTime.now())
                    ? null
                    : () {
                        _cDate =
                            DateTime(_cDate.year, _cDate.month, _cDate.day + 1);
                        _getSteps(_cDate);
                      }),
            SizedBox(
              height: 20,
            ),
            ImageButtonWidget(
              icon: Icon(Icons.add),
              text: 'Add Activity',
              onClick: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => AddActivity()));
              },
              width: 200,
              height: 50,
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                width: 500,
                height: 300,
                child: StepsChart(data: displaySteps),
              ),
            ),
            ChangeWeekWidget(
                txt: Text(
                  _weekDates,
                  style: TextStyle(fontSize: 15),
                ),
                addColor: _week == 0 ? Colors.grey : null,
                minusColor:
                    (tester.length - _week - 8) < 0 ? Colors.grey : null,
                minus: (tester.length - _week - 8) < 0
                    ? null
                    : () {
                        _week += 7;
                        DateTime now = DateTime.now();
                        DateTime date =
                            DateTime(now.year, now.month, now.day - _week);
                        setState(() {
                          _getWeekDates();
                          _lastWeekData(tester, date);
                        });
                      },
                add: _week == 0
                    ? null
                    : () {
                        _week -= 7;
                        DateTime now = DateTime.now();
                        DateTime date =
                            DateTime(now.year, now.month, now.day - _week);
                        setState(() {
                          _getWeekDates();
                          _lastWeekData(tester, date);
                        });
                      }),
          ],
        )));
  }

  void _getWeekDates() {
    DateTime now = DateTime.now();
    DateTime startDate = DateTime(now.year, now.month, now.day - _week - 7);
    DateTime endDate =
        DateTime(startDate.year, startDate.month, startDate.day + 7);
    if (endDate.month == startDate.month) {
      _weekDates = DateFormat('dd').format(startDate) +
          ' - ' +
          DateFormat('dd MMMM').format(endDate);
    } else {
      _weekDates = DateFormat('dd MMMM').format(startDate) +
          ' - ' +
          DateFormat('dd MMMM').format(endDate);
    }
  }
}
