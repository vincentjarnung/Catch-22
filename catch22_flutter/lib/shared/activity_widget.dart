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
  final String groupType;

  ActivityWidget(
      {@required this.code,
      @required this.img,
      this.leaveActivity,
      this.onClick,
      @required this.groupType});

  @override
  _ActivityWidgetState createState() => _ActivityWidgetState();
}

class _ActivityWidgetState extends State<ActivityWidget> {
  final DatabaseService _db = DatabaseService();
  String title = '';
  Future _getGroupName() async {
    title =
        await _db.getGroupName(widget.code).whenComplete(() => setState(() {}));
  }

  @override
  void initState() {
    super.initState();
    _getGroupName();
  }

  List groups = [];
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onClick,
      child: Container(
        height: 70,
        width: 340,
        decoration: BoxDecoration(
            color: ColorConstants.kyellow,
            borderRadius: BorderRadius.circular(20.0)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(40, 4, 0, 0),
              child: Column(
                children: [widget.img, Text(widget.groupType)],
              ),
            ),
            Expanded(
                child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )),
          ],
        ),
      ),
    );
  }
}
