import 'package:catch22_flutter/models/steps_day.dart';
import 'package:catch22_flutter/services/database.dart';
import 'package:catch22_flutter/shared/button_widget.dart';
import 'package:catch22_flutter/shared/constants/color_constants.dart';
import 'package:catch22_flutter/shared/img_button_widget.dart';
import 'package:catch22_flutter/shared/leave_group_popup.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';

class ActivityCompView extends StatefulWidget {
  final String code;
  final int daysLeft;

  ActivityCompView({@required this.code, @required this.daysLeft});
  @override
  _ActivityCompViewState createState() => _ActivityCompViewState();
}

class _ActivityCompViewState extends State<ActivityCompView> {
  final DatabaseService _db = DatabaseService();
  List<StepsDayModel> _todayList = [];
  List<StepsDayModel> _allTimeList = [];
  List<String> _users = [];
  bool _ended = false;
  StateSetter _setter;
  Icon _copy;

  String _firstPlace = '-';
  String _secoundPlace = '-';
  String _thirdPlace = '-';

  @override
  void initState() {
    super.initState();
    _getGroupName();
    _members().whenComplete(() => print(_allTimeList.toString() + ' testing'));
  }

  String title = '';

  Future _getGroupName() async {
    title =
        await _db.getGroupName(widget.code).whenComplete(() => setState(() {}));
  }

  Future _members() async {
    var data = _db.viewCompActivity(widget.code);
    await data.then((value) => value.docs.forEach((doc) async {
          print(doc.id);
          await _getTodayScore(doc.id).whenComplete(() => setState(() {
                _todayList.sort((a, b) {
                  return b.steps.compareTo(a.steps);
                });
              }));

          await _getAllTimeScore(doc.id).whenComplete(() => setState(() {
                _allTimeList.sort((a, b) {
                  return b.steps.compareTo(a.steps);
                });

                for (int i = 0; i < _allTimeList.length; i++) {
                  print(_allTimeList[i].steps);
                }

                if (widget.daysLeft <= 0) {
                  _ended = true;

                  for (int i = 0; i < _todayList.length; i++) {
                    _users.add(_todayList[i].date);
                  }
                  try {
                    _firstPlace = _users[0];
                  } catch (e) {}
                  try {
                    _secoundPlace = _users[1];
                  } catch (e) {}
                  try {
                    _thirdPlace = _users[2];
                  } catch (e) {}
                }
              }));
        }));
  }

  Future _getAllTimeScore(String userName) async {
    int totSteps = 0;
    var result = _db.viewCompMemActivity(widget.code, userName);
    await result
        .then((data) => data.docs.forEach((doc) {
              totSteps += doc['steps'];
            }))
        .whenComplete(() => _allTimeList
            .add(StepsDayModel(date: userName, steps: totSteps.toDouble())));
  }

  Future _getTodayScore(String userName) async {
    var result = _db.viewtodayCompMemActivity(widget.code, userName);
    await result.then((doc) => _todayList.add(
        StepsDayModel(date: userName, steps: doc.data()['steps'].toDouble())));
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
                                Clipboard.setData(ClipboardData(
                                  text: widget.code,
                                ));
                              })
                        ],
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
                      SizedBox(
                        height: 10,
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
                comp: true,
              );
            });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    _copy = Icon(Icons.copy);
    double heightOfScreen = MediaQuery.of(context).size.height;
    double widthOfScreen = MediaQuery.of(context).size.width;
    TextStyle header = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
    TextStyle item = TextStyle(fontSize: 18);
    TextStyle itemVal = TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
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
                      child: Text('Leave Group'),
                    ),
                  ])
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: _ended
              ? Column(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(60, 10, 60, 10),
                    child: Image.asset('assets/images/goalCompleted.png'),
                  ),
                  Text(
                    'Challange Completed',
                    style: header,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Column(
                        children: [
                          Text(
                            _secoundPlace,
                            style: item,
                          ),
                          Container(
                            width: 100,
                            height: 40,
                            color: ColorConstants.kyellow,
                            child: Center(
                                child: Text(
                              '2',
                              style: header,
                            )),
                          )
                        ],
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        children: [
                          Text(
                            _firstPlace,
                            style: item,
                          ),
                          Container(
                            width: 100,
                            height: 80,
                            color: ColorConstants.kyellow,
                            child: Center(
                                child: Text(
                              '1',
                              style: header,
                            )),
                          )
                        ],
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Column(
                        children: [
                          Text(
                            _thirdPlace,
                            style: item,
                          ),
                          Container(
                            width: 100,
                            height: 60,
                            color: ColorConstants.kyellow,
                            child: Center(
                                child: Text(
                              '3',
                              style: header,
                            )),
                          )
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Results',
                    style: header,
                  ),
                  Container(
                    height: heightOfScreen * 0.25,
                    width: widthOfScreen * 0.9,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: ColorConstants.kyellow),
                    child: ListView.builder(
                      itemCount: _allTimeList.length,
                      itemBuilder: (context, index) {
                        return Center(
                            child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                (index + 1).toString(),
                                style: itemVal,
                              ),
                              SizedBox(
                                width: 15,
                              ),
                              Text(
                                _allTimeList[index].date,
                                style: item,
                              ),
                              const Spacer(),
                              Text(_allTimeList[index].steps.toInt().toString(),
                                  style: itemVal)
                            ],
                          ),
                        ));
                      },
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ButtonWidget(
                    hasBorder: false,
                    text: 'DONE',
                    width: 150,
                    height: 50,
                    onClick: () {
                      _db.leaveCompGroup(widget.code);
                      Navigator.pop(context);
                    },
                  )
                ])
              : Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    Text('Today', style: header),
                    Container(
                      width: widthOfScreen * 0.9,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: ColorConstants.kyellow),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _todayList.length,
                        itemBuilder: (context, index) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(_todayList[index].date, style: item),
                                  Text(
                                      _todayList[index]
                                          .steps
                                          .toInt()
                                          .toString(),
                                      style: itemVal)
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text('Leaderboard', style: header),
                    Container(
                      width: widthOfScreen * 0.9,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: ColorConstants.kyellow),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _todayList.length,
                        itemBuilder: (context, index) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _allTimeList.length == 0
                                      ? Text('-')
                                      : Text(_allTimeList[index].date,
                                          style: item),
                                  _allTimeList.length == 0
                                      ? Text('-')
                                      : Text(
                                          _allTimeList[index]
                                              .steps
                                              .toInt()
                                              .toString(),
                                          style: itemVal)
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
