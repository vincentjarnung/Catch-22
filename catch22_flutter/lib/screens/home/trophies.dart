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

  @override
  void initState() {
    super.initState();
    if (!mounted) return;

    _getAsas();
  }

  void _getAsas() {
    _achievements().then((value) {
      setState(() {
        _list = value;
      });
    });
  }

  Future<List<Widget>> _achievements() async {
    var data = _db.achievements;
    var futures = await data.then((value) => value.docs.map((doc) async {
          bool isOwned = false;
          String date = ' -';
          var val = await _db.ownAchievementCheck(doc['ref']);
          if (val != null) {
            isOwned = true;
            date = val;
          }
          print(doc['ref']);
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
        }).toList());
    return await Future.wait(futures);
  }

  @override
  Widget build(BuildContext context) {
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
}
