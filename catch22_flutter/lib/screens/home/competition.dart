import 'package:catch22_flutter/screens/home/create_activity.dart';
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
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _db.groups(),
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          return Scaffold(
            appBar: AppBar(
              leading: Container(),
              title: Text('Groups'),
              centerTitle: true,
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(60, 20, 60, 20),
                    child: Image.asset('assets/images/myGroups.png'),
                  ),
                  Text('Your active groups'),
                  Container(
                    height: 300,
                    width: 350,
                    child: ListView.builder(
                      itemCount: snapshot.data.length,
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
                              titel: snapshot.data[index],
                              groupType: 'Goal',
                              onClick: () {
                                print('click');
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  ImageButtonWidget(
                    icon: Icon(Icons.add),
                    text: 'Join Group',
                    width: 200,
                    height: 60,
                    onClick: () {},
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
                                  builder: (context) => SelectActivity()))
                          .then((value) {
                        setState(() {});
                      });
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }
}
