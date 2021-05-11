import 'package:catch22_flutter/services/database.dart';
import 'package:flutter/material.dart';

class GridListItem extends StatefulWidget {
  final String imgRef;

  GridListItem({@required this.imgRef});
  @override
  _GridListItemState createState() => _GridListItemState();
}

class _GridListItemState extends State<GridListItem> {
  final DatabaseService _db = DatabaseService();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _db.getToolImg(widget.imgRef),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(
              child: CircularProgressIndicator(),
            );
          return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.network(
                snapshot.data,
                height: 100,
                width: 100,
              ));
        });
  }
}
