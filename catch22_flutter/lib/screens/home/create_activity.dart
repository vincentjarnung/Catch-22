import 'package:catch22_flutter/screens/home/bottom_navigation_bar.dart';
import 'package:catch22_flutter/services/auth.dart';
import 'package:catch22_flutter/services/database.dart';
import 'package:catch22_flutter/shared/button_widget.dart';
import 'package:catch22_flutter/shared/change_date_widget.dart';
import 'package:catch22_flutter/shared/constants/color_constants.dart';
import 'package:catch22_flutter/shared/form_textfield_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:flutter_date_pickers/flutter_date_pickers.dart' as dp;
import 'package:catch22_flutter/shared/img_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'dart:math';

class SelectActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AppBar appBar = AppBar(
      title: Text('Select Group Type'),
      centerTitle: true,
    );
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height -
        (MediaQuery.of(context).padding.top + kToolbarHeight);
    print(height);
    return Scaffold(
      appBar: appBar,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(60, 40, 60, 20),
              child: Text(
                'Create a Goal Group to collaborate with your friends to reach a common goal!',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Image.asset(
              'assets/images/goalActivity.png',
              height: 150,
            ),
            ImageButtonWidget(
              width: width - 70,
              icon: Icon(Icons.add),
              text: 'Create a Goal Group',
              onClick: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => GoalActivity()));
              },
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                'or',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(60, 10, 60, 20),
              child: Text(
                'Create a Competition Group to see your freinds data and compete against them!',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            Image.asset(
              'assets/images/compete.png',
              height: 120,
            ),
            SizedBox(
              height: 30,
            ),
            ImageButtonWidget(
              width: width - 70,
              icon: Icon(Icons.add),
              text: 'Create a Competition Group',
              onClick: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => CompetitionActivity()));
              },
            ),
          ],
        ),
      ),
    );
  }
}

class GoalActivity extends StatefulWidget {
  @override
  _GoalActivityState createState() => _GoalActivityState();
}

class _GoalActivityState extends State<GoalActivity> {
  final DatabaseService _db = DatabaseService();

  int stepGoal = 100000;
  int improvmentGoal = 25;
  bool hasSel = true;
  String actName = '';
  String error = '';
  String code;
  DateTime _firstDate = DateTime.now();
  DateTime _lastDate = DateTime.now().add(Duration(days: 350));
  DateTime _selectedDate = DateTime.now();
  Color selectedDateStyleColor = Colors.black;
  Color selectedSingleDateDecorationColor = ColorConstants.kPrimaryColor;
  Icon _copy;
  StateSetter _setter;

  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _copy = Icon(Icons.copy);
    dp.DatePickerRangeStyles styles = dp.DatePickerRangeStyles(
      selectedDateStyle: Theme.of(context)
          .accentTextTheme
          .bodyText1
          ?.copyWith(color: selectedDateStyleColor),
      selectedSingleDateDecoration: BoxDecoration(
          color: selectedSingleDateDecorationColor, shape: BoxShape.circle),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Goal Group'),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 20, 20, 5),
                child: TextFieldWidget(
                  isEmail: false,
                  isLast: true,
                  obscureText: false,
                  hintText: 'Name Group',
                  onChanged: (val) {
                    actName = val;
                  },
                ),
              ),
              Text(
                error,
                style: TextStyle(color: Colors.red),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 5, 30, 15),
                child: Text(
                  'Set Step Goal',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: 10,
              ),
              ChangeDateWidget(
                  txt: stepGoal.toString(),
                  minus: () {
                    setState(() {
                      stepGoal -= 5000;
                    });
                  },
                  add: () {
                    setState(() {
                      stepGoal += 5000;
                    });
                  }),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  'Select an end date for the Group',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: hasSel ? Colors.black : Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                height: 300,
                width: 300,
                child: dp.DayPicker.single(
                  selectedDate: _selectedDate,
                  onChanged: _onSelectedDateChanged,
                  firstDate: _firstDate,
                  lastDate: _lastDate,
                  datePickerStyles: styles,
                  datePickerLayoutSettings: dp.DatePickerLayoutSettings(
                      maxDayPickerRowCount: 2,
                      showPrevMonthEnd: true,
                      showNextMonthStart: true),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              ImageButtonWidget(
                icon: Icon(Icons.add),
                text: 'Create Group',
                width: 200,
                onClick: () {
                  if (DateFormat('yyyy-MM-dd').format(_selectedDate) ==
                      DateFormat('yyyy-MM-dd').format(DateTime.now())) {
                    setState(() {
                      hasSel = false;
                    });
                  }
                  if (actName == null || actName == '') {
                    setState(() {
                      error = 'Enter a valid group name';
                    });
                  }
                  if (!(actName == null || actName == '') &&
                      !(DateFormat('yyyy-MM-dd').format(_selectedDate) ==
                          DateFormat('yyyy-MM-dd').format(DateTime.now()))) {
                    code = getRandomString(5);
                    _showAlertDialog(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAlertDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: StatefulBuilder(builder: (context, setState) {
              _setter = setState;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      'Congratulations, you have created a new group. Here is the code for inviting others to the group:',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SelectableText(
                          code,
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(width: 10),
                        IconButton(
                            icon: _copy,
                            onPressed: () {
                              _setter(() {
                                _copy = Icon(
                                  Icons.copy,
                                  color: ColorConstants.kPrimaryColor,
                                );
                              });
                              Clipboard.setData(ClipboardData(text: code));
                            })
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ImageButtonWidget(
                      width: 160,
                      height: 30,
                      icon: Icon(Icons.share),
                      text: "Share Code",
                      onClick: () {
                        Share.share(
                            'Join my group on catch-22, here is the code: \n' +
                                code);
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ButtonWidget(
                      text: 'Continue',
                      hasBorder: false,
                      height: 30,
                      width: 120,
                      onClick: () async {
                        print(DateFormat('yyyy-MM-dd').format(_selectedDate));
                        print(stepGoal);
                        print(actName);

                        _db
                            .newActivity(
                                actName,
                                stepGoal,
                                DateFormat('yyyy-MM-dd').format(_selectedDate),
                                code)
                            .whenComplete(() => _db.joinActivity(code));

                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            }),
          );
        });
  }

  void _onSelectedDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      print(DateFormat('yyyy-MM-dd').format(_selectedDate));
    });
  }
}

class CompetitionActivity extends StatefulWidget {
  @override
  _CompetitionActivityState createState() => _CompetitionActivityState();
}

class _CompetitionActivityState extends State<CompetitionActivity> {
  final DatabaseService _db = DatabaseService();

  int stepGoal = 100000;
  int improvmentGoal = 25;
  bool hasSel = true;

  String actName = '';
  String error = '';
  String code;
  DateTime _firstDate = DateTime.now();
  DateTime _lastDate = DateTime.now().add(Duration(days: 350));
  DateTime _selectedDate = DateTime.now();
  StateSetter _setter;
  Icon _copy;
  Color selectedDateStyleColor = Colors.black;
  Color selectedSingleDateDecorationColor = ColorConstants.kPrimaryColor;

  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    _copy = Icon(Icons.copy);
    dp.DatePickerRangeStyles styles = dp.DatePickerRangeStyles(
      selectedDateStyle: Theme.of(context)
          .accentTextTheme
          .bodyText1
          ?.copyWith(color: selectedDateStyleColor),
      selectedSingleDateDecoration: BoxDecoration(
          color: selectedSingleDateDecorationColor, shape: BoxShape.circle),
    );
    return Scaffold(
      appBar: AppBar(
        title: Text('Competition Group'),
        centerTitle: true,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  'Name Your group',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: hasSel ? Colors.black : Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 10, 20, 0),
                child: TextFieldWidget(
                  isEmail: false,
                  isLast: true,
                  obscureText: false,
                  hintText: 'Name Group',
                  onChanged: (val) {
                    actName = val;
                  },
                ),
              ),
              Text(
                error,
                style: TextStyle(color: Colors.red),
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Text(
                  'Select an end date for the Group',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: hasSel ? Colors.black : Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                height: 320,
                width: 300,
                child: dp.DayPicker.single(
                  selectedDate: _selectedDate,
                  onChanged: _onSelectedDateChanged,
                  firstDate: _firstDate,
                  lastDate: _lastDate,
                  datePickerStyles: styles,
                  datePickerLayoutSettings: dp.DatePickerLayoutSettings(
                      maxDayPickerRowCount: 2,
                      showPrevMonthEnd: true,
                      showNextMonthStart: true),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              ImageButtonWidget(
                icon: Icon(Icons.add),
                text: 'Create Group',
                width: 200,
                onClick: () {
                  if (DateFormat('yyyy-MM-dd').format(_selectedDate) ==
                      DateFormat('yyyy-MM-dd').format(DateTime.now())) {
                    setState(() {
                      hasSel = false;
                    });
                  }
                  if (actName == null || actName == '') {
                    setState(() {
                      error = 'Enter a valid group name';
                    });
                  }
                  if (!(actName == null || actName == '') &&
                      !(DateFormat('yyyy-MM-dd').format(_selectedDate) ==
                          DateFormat('yyyy-MM-dd').format(DateTime.now()))) {
                    code = getRandomString(5);
                    _showAlertDialog(context);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAlertDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: StatefulBuilder(builder: (context, setState) {
              _setter = setState;
              return SingleChildScrollView(
                child: Column(
                  children: [
                    Text(
                      'Congratulations, you have created a new group. Here is the code for inviting others to the group:',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 18),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SelectableText(
                          code,
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(width: 10),
                        IconButton(
                            icon: _copy,
                            onPressed: () {
                              _setter(() {
                                _copy = Icon(
                                  Icons.copy,
                                  color: ColorConstants.kPrimaryColor,
                                );
                              });
                              Clipboard.setData(ClipboardData(text: code));
                            })
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ImageButtonWidget(
                      width: 160,
                      height: 30,
                      icon: Icon(Icons.share),
                      text: "Share Code",
                      onClick: () {
                        Share.share(
                            'Join my group on catch-22, here is the code: \n' +
                                code);
                      },
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    ButtonWidget(
                      text: 'Continue',
                      hasBorder: false,
                      height: 30,
                      width: 120,
                      onClick: () async {
                        print(DateFormat('yyyy-MM-dd').format(_selectedDate));
                        print(stepGoal);
                        print(actName);

                        _db
                            .newCompActivity(
                                actName,
                                DateFormat('yyyy-MM-dd').format(_selectedDate),
                                code)
                            .whenComplete(() => _db.joinActivity(code));

                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              );
            }),
          );
        });
  }

  void _onSelectedDateChanged(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      print(DateFormat('yyyy-MM-dd').format(_selectedDate));
    });
  }
}
