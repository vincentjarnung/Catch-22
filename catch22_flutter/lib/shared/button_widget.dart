import 'package:catch22_flutter/shared/constants/color_constants.dart';
import 'package:flutter/material.dart';

class ButtonWidget extends StatelessWidget {
  final bool hasBorder;
  final String text;
  final Function onClick;
  final double width;
  final double height;

  ButtonWidget(
      {@required this.hasBorder,
      this.text,
      this.onClick,
      this.width,
      this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: hasBorder
              ? Border.all(color: Colors.blue, width: 2.0)
              : Border.fromBorderSide(BorderSide.none),
          borderRadius: BorderRadius.circular(10.0),
          color: hasBorder ? Colors.white : ColorConstants.kPrimaryColor),
      height: height == null ? 60 : height,
      width: width == null ? double.infinity : width,
      child: FlatButton(
        splashColor: hasBorder ? Colors.white30 : Colors.yellow[700],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Text(
          text,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        color: Colors.transparent,
        onPressed: onClick,
      ),
    );
  }
}
