import 'package:catch22_flutter/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:catch22_flutter/shared/grid_list_time.dart';

class Trophies extends StatefulWidget {
  @override
  _TrophiesState createState() => _TrophiesState();
}

class _TrophiesState extends State<Trophies> {
  final DatabaseService _db = DatabaseService();

  List<Widget> getAllItems(AsyncSnapshot<QuerySnapshot> snapshot) {
    return snapshot.data.docs
        .map<Widget>((doc) => new GridListItem(
              imgRef: doc['ref'],
            ))
        .toList();
  }

  List<Widget> getUserItems(AsyncSnapshot<QuerySnapshot> snap) {
    return snap.data.docs
        .map<Widget>((doc) => new GridListItem(
              imgRef: doc['ref'],
            ))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    double maxWidth = MediaQuery.of(context).size.width;
    double maxHeight = MediaQuery.of(context).size.height -
        (MediaQuery.of(context).padding.top + kToolbarHeight);
    return StreamBuilder(
        stream: _db.achievements,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          } else {
            return Scaffold(
              appBar: AppBar(
                title: Text('Trophies'),
                centerTitle: true,
              ),
              body: Stack(
                children: [
                  GridView.count(
                    crossAxisCount: 3,
                    children: getAllItems(snapshot),
                  ),
                  Container(
                    width: maxWidth,
                    height: maxHeight,
                    color: Color.fromRGBO(0, 0, 0, 0.5),
                  ),
                  StreamBuilder(
                      stream: _db.userAchievements,
                      builder: (context, snap) {
                        print(getUserItems(snap));
                        if (!snap.hasData) {
                          return CircularProgressIndicator();
                        } else {
                          return GridView.count(
                            crossAxisCount: 3,
                            children: getUserItems(snap),
                          );
                        }
                      }),
                ],
              ),
            );
          }
        });
  }
}
