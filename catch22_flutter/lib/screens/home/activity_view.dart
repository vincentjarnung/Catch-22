import 'package:catch22_flutter/services/database.dart';
import 'package:catch22_flutter/shared/button_widget.dart';
import 'package:catch22_flutter/shared/leave_group_popup.dart';
import 'package:catch22_flutter/shared/constants/color_constants.dart';
import 'package:catch22_flutter/shared/img_button_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class ActivityView extends StatefulWidget {
  final String code;
  final int daysLeft;

  ActivityView({@required this.code, @required this.daysLeft});

  @override
  _ActivityViewState createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  final DatabaseService _db = DatabaseService();
  double totStepGoal;
  double totCurSteps;
  double todayStepGoal;
  double todayCurStep = 0;
  String title = '';
  StateSetter _setter;
  Icon _copy;
  String _nowDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  Future _getGroupName() async {
    title =
        await _db.getGroupName(widget.code).whenComplete(() => setState(() {}));
  }

  @override
  void initState() {
    super.initState();
    _getGroupName();
    _getTodaySteps().whenComplete(() => setState(() {}));
  }

  String _formatNumber(int numb) {
    String s = numb.toString();

    for (int i = 1, n = s.length - 1; i < s.length; i++, n--) {
      if (i % 3 == 0) {
        String sub = s.substring(n);
        s = s.replaceRange(n, s.length, ' ' + sub);
      }
    }
    return s;
  }

  void _onSelected(BuildContext context, int item) {
    switch (item) {
      case 0:
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: StatefulBuilder(builder: (context, setState) {
                  _setter = setState;
                  return SingleChildScrollView(
                      child: Column(
                    children: [
                      Text(
                        'Share Code',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SelectableText(
                            widget.code,
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
                                Clipboard.setData(
                                    ClipboardData(text: widget.code));
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
                          Share.share(widget.code);
                        },
                      ),
                    ],
                  ));
                }),
              );
            });
        break;
      case 1:
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return LeaveGroupPopup(
                code: widget.code,
                comp: false,
              );
            });
        break;
    }
  }

  Future _getTodaySteps() async {
    var users = await _db.userStepsToday(widget.code);

    users.docs.forEach((doc) async {
      var userTodaySteps = await FirebaseFirestore.instance
          .collection('activities')
          .doc(widget.code)
          .collection('members')
          .doc(doc.id)
          .collection('steps')
          .doc(_nowDate)
          .get();

      todayCurStep += userTodaySteps.data()['steps'];
    });
  }

  @override
  Widget build(BuildContext context) {
    _copy = Icon(
      Icons.copy_outlined,
      color: Colors.black,
    );
    print(widget.code);
    double heightOfScreen = MediaQuery.of(context).size.height;
    double widthOfScreen = MediaQuery.of(context).size.width;
    return StreamBuilder(
        stream: _db.viewActivity(widget.code),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          } else {
            totStepGoal = snapshot.data['goal'].toDouble();
            totCurSteps = snapshot.data['currentSteps'].toDouble();
            bool didWin = false;
            if (totCurSteps >= totStepGoal) {
              didWin = true;
            }

            if (widget.daysLeft > 0) {
              todayStepGoal = (totStepGoal ~/ widget.daysLeft).toDouble();
            }

            return Scaffold(
                appBar: AppBar(
                  title: Text(title),
                  centerTitle: true,
                  actions: <Widget>[
                    PopupMenuButton(
                        onSelected: (item) => _onSelected(context, item),
                        itemBuilder: (context) => [
                              PopupMenuItem<int>(
                                value: 0,
                                child: Text('View Code'),
                              ),
                              PopupMenuItem<int>(
                                value: 1,
                                child: Text('Leave Group'),
                              ),
                            ])
                  ],
                ),
                body: widget.daysLeft <= 0
                    ? Column(
                        children: [
                          const Spacer(flex: 2),
                          Padding(
                              padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                              child: didWin
                                  ? Image.asset(
                                      'assets/images/goalCompleted.png')
                                  : Image.asset(
                                      'assets/images/goalNotCompleted.png')),
                          SizedBox(
                            height: 10,
                          ),
                          didWin
                              ? Text(
                                  'GOAL COMPLETED',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                )
                              : Text(
                                  'GOAL NOT COMPLETED',
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            _formatNumber(totStepGoal.toInt()) + ' steps',
                            style: TextStyle(fontSize: 18),
                          ),
                          const Spacer(
                            flex: 2,
                          ),
                          ButtonWidget(
                            hasBorder: false,
                            text: 'DONE',
                            width: 150,
                            height: 50,
                            onClick: () {
                              _db.leaveGroup(widget.code);
                              Navigator.pop(context);
                            },
                          ),
                          SizedBox(
                            height: 20,
                          ),

                          /*Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: ImageButtonWidget(
                            icon: Icon(Icons.refresh),
                            text: 'RECREATE GROUP',
                            height: 50,
                            width: 220,
                            onClick: () {},
                          ),
                        ),*/
                        ],
                      )
                    : SingleChildScrollView(
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
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 10, 10, 0),
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
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 10, 20, 0),
                                  child: SfLinearGauge(
                                    axisTrackStyle: LinearAxisTrackStyle(
                                        color: Colors.grey[350]),
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
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 10, 20, 0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Text(''),
                                          Text(
                                              _formatNumber(totCurSteps.toInt())
                                                  .toString(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20))
                                        ],
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('GOAL'),
                                          Text(
                                              _formatNumber(totStepGoal.toInt())
                                                  .toString(),
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20))
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(20, 20, 10, 10),
                                  child: Row(
                                    children: [
                                      Icon(Icons.calendar_today_sharp),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Text(
                                        widget.daysLeft.toString() +
                                            ' days left',
                                        style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold),
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
                            height: heightOfScreen * 0.35,
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
                                Text(
                                    _formatNumber(todayStepGoal.toInt()) +
                                        ' steps',
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold)),
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
                                Text(
                                    _formatNumber(todayCurStep.toInt()) +
                                        ' steps',
                                    style: TextStyle(
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold)),
                                SizedBox(
                                  height: heightOfScreen * 0.02,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 0, 10, 0),
                                  child: SfLinearGauge(
                                    axisTrackStyle: LinearAxisTrackStyle(
                                        color: Colors.white,
                                        thickness: heightOfScreen * 0.05,
                                        edgeStyle: LinearEdgeStyle.bothCurve,
                                        borderColor: ColorConstants.kyellow,
                                        borderWidth: 5),
                                    maximum: todayStepGoal,
                                    barPointers: [
                                      LinearBarPointer(
                                        enableAnimation: false,
                                        value: todayCurStep,
                                        color: ColorConstants.kyellow,
                                        thickness: heightOfScreen * 0.050,
                                        edgeStyle: LinearEdgeStyle.bothCurve,
                                        child: Center(
                                            child: ((todayCurStep /
                                                            todayStepGoal) *
                                                        100) >
                                                    7
                                                ? Text(
                                                    ((todayCurStep /
                                                                    todayStepGoal) *
                                                                100)
                                                            .toStringAsFixed(
                                                                0) +
                                                        '%',
                                                    style: TextStyle(
                                                        fontSize: 15,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  )
                                                : null),
                                      )
                                    ],
                                    showAxisTrack: true,
                                    showLabels: false,
                                    showTicks: false,
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      )));
          }
        });
  }
}
