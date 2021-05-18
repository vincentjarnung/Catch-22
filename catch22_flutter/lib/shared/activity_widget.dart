import 'package:catch22_flutter/screens/home/activity_view.dart';
import 'package:catch22_flutter/screens/home/activity_comp_view.dart';
import 'package:catch22_flutter/services/database.dart';
import 'package:catch22_flutter/shared/back_img_button_widget.dart';
import 'package:catch22_flutter/shared/constants/color_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ActivityWidget extends StatefulWidget {
  final String code;
  final Image img;
  final Function leaveActivity;
  final Function onClick;

  ActivityWidget(
      {@required this.code,
      @required this.img,
      this.leaveActivity,
      this.onClick});

  @override
  _ActivityWidgetState createState() => _ActivityWidgetState();
}

class _ActivityWidgetState extends State<ActivityWidget> {
  final DatabaseService _db = DatabaseService();
  String title = '';
  String goal = '';
  int _daysLeft = 0;

  Future _getGroupName() async {
    title = await _db
        .getGroupName(widget.code)
        .whenComplete(() => setStateIfMounted(() {}));
  }

  Future _getGroupType() async {
    goal = await _db
        .getGroupType(widget.code)
        .whenComplete(() => setStateIfMounted(() {}));
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  Future _getDaysLeft() async {
    String endDate = await _db
        .getGropEndDate(widget.code)
        .whenComplete(() => setStateIfMounted(() {}));
    print(widget.code);
    print(endDate);
    _daysLeft = DateTime.parse(endDate).difference(DateTime.now()).inDays;
  }

  @override
  void initState() {
    if (!mounted) return;
    super.initState();
    _getGroupName();
    _getGroupType();
    _getDaysLeft();
  }

  List groups = [];
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        print(goal);
        if (goal == 'Goal') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (builder) => ActivityView(
                        code: widget.code,
                        daysLeft: _daysLeft,
                      )));
        } else if (goal == 'Competition') {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (builder) => ActivityCompView(
                        code: widget.code,
                        daysLeft: _daysLeft,
                      )));
        }
      },
      child: Container(
        height: 70,
        width: 340,
        decoration: BoxDecoration(
            color: ColorConstants.kyellow,
            borderRadius: BorderRadius.circular(20.0)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 0, 0),
              child: Column(
                children: [widget.img, Text(goal)],
              ),
            ),
            Expanded(
                child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )),
            _daysLeft > 0
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(0, 20, 10, 0),
                    child: Column(
                      children: [
                        _daysLeft == 1
                            ? Text(_daysLeft.toString() + ' day')
                            : Text(_daysLeft.toString() + ' days'),
                        Text('left')
                      ],
                    ))
                : Text(
                    'Completed',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
            Icon(Icons.arrow_forward_ios),
            SizedBox(
              width: 10,
            )
          ],
        ),
      ),
    );
  }
}
