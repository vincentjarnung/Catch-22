import 'package:catch22_flutter/services/auth.dart';
import 'package:catch22_flutter/services/database.dart';
import 'package:catch22_flutter/shared/button_widget.dart';
import 'package:catch22_flutter/shared/form_textfield_widget.dart';
import 'package:catch22_flutter/shared/img_button_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class JoinGroup extends StatefulWidget {
  @override
  _JoinGroupState createState() => _JoinGroupState();
}

class _JoinGroupState extends State<JoinGroup> {
  final DatabaseService _db = DatabaseService();

  String code = '';
  String error = '';

  String aName;
  bool exists;
  bool isComp;

  Future codeExist(String code) async {
    await FirebaseFirestore.instance
        .collection('activities')
        .where('code', isEqualTo: code)
        .get()
        .then((snapshot) {
      snapshot.docs.forEach((value) {
        aName = value.id;
        isComp = false;
      });
    }).whenComplete(() => FirebaseFirestore.instance
            .collection('activitiesComp')
            .where('code', isEqualTo: code)
            .get()
            .then((snap) => snap.docs.forEach((val) {
                  aName = val.id;
                  isComp = true;
                })));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
          appBar: AppBar(
            title: Text('Join Group'),
            centerTitle: true,
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(40, 40, 40, 40),
                  child: Text(
                    'Type in the code of the group you want to join!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                Image.asset(
                  'assets/images/company.png',
                  width: 250,
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: TextFieldWidget(
                    isEmail: false,
                    isLast: true,
                    obscureText: false,
                    hintText: 'Code',
                    onChanged: (val) {
                      code = val;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                    error,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
                ImageButtonWidget(
                  icon: Icon(Icons.search),
                  text: 'Search',
                  width: 200,
                  height: 50,
                  onClick: () {
                    setState(() {
                      error = '';
                    });
                    if (code == null) {
                      setState(() {
                        error = 'Enter a code';
                      });
                    } else {
                      codeExist(code).whenComplete(() {
                        if (aName != null) {
                          print(code);
                          if (isComp) {
                            print(isComp);
                            _db
                                .setCompMem(code)
                                .whenComplete(() => _db.joinActivity(code))
                                .whenComplete(() => _showAlertDialog(context));
                          } else {
                            _db.setMem(code).whenComplete(() => _db
                                .joinActivity(code)
                                .whenComplete(() => _showAlertDialog(context)));
                          }
                        } else {
                          setState(() {
                            error = 'No group found';
                          });
                        }
                      });
                    }
                  },
                )
              ],
            ),
          )),
    );
  }

  void _showAlertDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Container(
              width: 200,
              height: 100,
              child: Column(
                children: [
                  Text(
                    'Congratulations, you have have joined "' + aName + '"',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ButtonWidget(
                    text: 'Continue',
                    hasBorder: false,
                    height: 30,
                    width: 120,
                    onClick: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}
