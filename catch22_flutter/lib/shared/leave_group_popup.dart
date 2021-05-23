import 'package:catch22_flutter/screens/wrapper.dart';
import 'package:catch22_flutter/services/auth.dart';
import 'package:catch22_flutter/services/database.dart';
import 'package:flutter/material.dart';

import 'back_img_button_widget.dart';
import 'img_button_widget.dart';

class LeaveGroupPopup extends StatelessWidget {
  final String code;
  final bool comp;

  LeaveGroupPopup({@required this.code, @required this.comp});
  final DatabaseService _db = DatabaseService();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Are you sure that you want to leave this group?',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                      text: 'Yes',
                      onClick: () {
                        if (comp) {
                          _db.leaveCompGroup(code);
                        } else {
                          _db.leaveGroup(code);
                        }
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      width: 100,
                      height: 50,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
