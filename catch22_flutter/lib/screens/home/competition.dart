import 'package:catch22_flutter/screens/home/create_activity.dart';
import 'package:catch22_flutter/screens/home/activity_view.dart';
import 'package:catch22_flutter/screens/home/join_group.dart';
import 'package:catch22_flutter/services/database.dart';
import 'package:catch22_flutter/shared/activity_widget.dart';
import 'package:catch22_flutter/shared/button_widget.dart';
import 'package:catch22_flutter/shared/img_button_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Competition extends StatefulWidget {
  @override
  _CompetitionState createState() => _CompetitionState();
}

class _CompetitionState extends State<Competition> {
  final DatabaseService _db = DatabaseService();

  @override
  void initState() {
    super.initState();
    if (!mounted) return;
    _updateGroups();
  }

  void _updateGroups() async {
    List groups = await _db.getGroups();
    groups.forEach((group) {
      _db.setMemStep(group);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
        stream: _db.activities,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          List list = snapshot.data['activities'];

          return Scaffold(
            appBar: AppBar(
              leading: Container(),
              title: Text('Groups'),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(60, 10, 60, 20),
                      child: Image.asset(
                        'assets/images/myGroups.png',
                        height: 150,
                      ),
                    ),
                    Text('Your active groups'),
                    Container(
                        height: 280,
                        width: 350,
                        child: ListView.builder(
                          itemCount: list.length,
                          itemBuilder: (context, index) {
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: ActivityWidget(
                                  img: Image.asset(
                                    'assets/images/group.png',
                                    height: 40,
                                    width: 70,
                                  ),
                                  code: list[index],
                                ),
                              ),
                            );
                          },
                        )),
                    SizedBox(
                      height: 10,
                    ),
                    ImageButtonWidget(
                      icon: Icon(Icons.add),
                      text: 'Join Group',
                      width: 200,
                      height: 60,
                      onClick: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => JoinGroup()));
                      },
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ButtonWidget(
                      hasBorder: false,
                      text: 'Create group',
                      width: 200,
                      height: 60,
                      onClick: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SelectActivity()));
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
