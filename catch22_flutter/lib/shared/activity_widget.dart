import 'package:catch22_flutter/shared/back_img_button_widget.dart';
import 'package:catch22_flutter/shared/constants/color_constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ActivityWidget extends StatelessWidget {
  final String titel;
  final Image img;
  final Function leaveActivity;
  final Function onClick;
  final String groupType;

  ActivityWidget(
      {@required this.titel,
      @required this.img,
      this.leaveActivity,
      this.onClick,
      @required this.groupType});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClick,
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
                children: [img, Text(groupType)],
              ),
            ),
            Expanded(
                child: Text(
              titel,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )),

            /*Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              child: Container(
                decoration: BoxDecoration(
                    border: Border.fromBorderSide(BorderSide.none),
                    borderRadius: BorderRadius.circular(20.0),
                    color: Colors.red[700]),
                height: 70,
                width: 92,
                child: FlatButton.icon(
                  icon: Icon(Icons.cancel),
                  splashColor: Colors.red[900],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  label: Text(
                    'Leave',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  color: Colors.transparent,
                  onPressed: leaveActivity,
                ),
              ),
            )*/
          ],
        ),
      ),
    );
  }
}
