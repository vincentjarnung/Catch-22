import 'package:catch22_flutter/services/database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:catch22_flutter/shared/grid_list_time.dart';
import 'package:catch22_flutter/screens/home/view_achievement.dart';

class Trophies extends StatefulWidget {
  @override
  _TrophiesState createState() => _TrophiesState();
}

class _TrophiesState extends State<Trophies> {
  final DatabaseService _db = DatabaseService();
  List<Widget> _list = [];

  Future<List<Widget>> _getAllItems(
      AsyncSnapshot<QuerySnapshot> snapshot) async {
    var futures = snapshot.data.docs.map((doc) async {
      bool isOwned = false;
      String date = ' -';
      var val = await _db.ownAchievementCheck(doc['ref']);
      if (val != null) {
        isOwned = true;
        date = val;
      }

      return GridListItem(
        imgRef: doc['ref'],
        owned: isOwned,
        onClick: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ViewAchievements(
                      title: doc['title'],
                      description: doc['description'],
                      ref: doc['ref'],
                      isOwned: isOwned,
                      date: date)));
          print(doc['ref'].toString() +
              ' ' +
              doc['title'].toString() +
              ' ' +
              doc['description'].toString());
        },
      );
    }).toList();
    return await Future.wait(futures);
  }

  _getListWidgets(snapshot) {
    _getAllItems(snapshot).then((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        _list = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double maxWidth = MediaQuery.of(context).size.width;
    double maxHeight = MediaQuery.of(context).size.height -
        (MediaQuery.of(context).padding.top + kToolbarHeight);
    return FutureBuilder(
        future: _db.achievements,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          } else {
            _getListWidgets(snapshot);
            return Scaffold(
              appBar: AppBar(
                title: Text('Trophies'),
                centerTitle: true,
                leading: Container(),
              ),
              backgroundColor: Color.fromRGBO(0, 0, 0, 0.5),
              body: Stack(
                children: [
                  GridView.count(
                    crossAxisCount: 3,
                    children: _list,
                  ),
                ],
              ),
            );
          }
        });
  }
}
