import 'package:catch22_flutter/services/database.dart';
import 'package:flutter/material.dart';

class ViewAchievements extends StatefulWidget {
  final String title;
  final String description;
  final String ref;
  final bool isOwned;
  final String date;

  ViewAchievements(
      {@required this.title,
      @required this.description,
      @required this.ref,
      @required this.isOwned,
      @required this.date});
  @override
  _ViewAchievementsState createState() => _ViewAchievementsState();
}

class _ViewAchievementsState extends State<ViewAchievements> {
  final DatabaseService _db = DatabaseService();
  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = TextStyle(color: Colors.white, fontSize: 25);
    TextStyle txtStyle = TextStyle(color: Colors.grey[300], fontSize: 18);
    double maxWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text('Achievement'),
        centerTitle: true,
      ),
      backgroundColor: Colors.grey[700],
      body: FutureBuilder(
          future: _db.getAchiImg(widget.ref),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return Center(
                child: CircularProgressIndicator(),
              );
            return Column(children: [
              SizedBox(
                height: 80,
              ),
              Center(
                child: widget.isOwned
                    ? Image.network(
                        snapshot.data,
                        width: 170,
                      )
                    : Image.asset(
                        'assets/images/lock.png',
                        width: 150,
                      ),
              ),
              SizedBox(
                height: 40,
                width: maxWidth,
              ),
              Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.isOwned
                          ? widget.title
                          : 'This achievement is locked',
                      style: titleStyle,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Achieved: ' + widget.date,
                      style: txtStyle,
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Description:',
                      style: txtStyle,
                    ),
                    Text(
                      widget.description,
                      style: titleStyle,
                    ),
                  ],
                ),
              ),
            ]);
          }),
    );
  }
}
