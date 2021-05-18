import 'package:catch22_flutter/services/database.dart';
import 'package:flutter/material.dart';

class GridListItem extends StatefulWidget {
  final String imgRef;
  final bool owned;
  final Function onClick;

  GridListItem({@required this.imgRef, @required this.owned, this.onClick});
  @override
  _GridListItemState createState() => _GridListItemState();
}

class _GridListItemState extends State<GridListItem> {
  final DatabaseService _db = DatabaseService();
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _db.getAchiImg(widget.imgRef),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(
              child: CircularProgressIndicator(),
            );
          return GestureDetector(
            onTap: widget.onClick,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: !widget.owned
                  ? ColorFiltered(
                      colorFilter:
                          ColorFilter.mode(Colors.grey, BlendMode.modulate),
                      child: Image.network(
                        snapshot.data,
                        height: 100,
                        width: 100,
                      ),
                    )
                  : Image.network(
                      snapshot.data,
                      height: 100,
                      width: 100,
                    ),
            ),
          );
        });
  }
}
