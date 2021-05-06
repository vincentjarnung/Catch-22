import 'package:catch22_flutter/shared/constants/color_constants.dart';
import 'package:flutter/material.dart';

class ImageButtonWidget extends StatelessWidget {
  final Icon icon;
  final String text;
  final Function onClick;
  final double width;
  final double height;

  ImageButtonWidget(
      {this.icon, this.text, this.onClick, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.fromBorderSide(BorderSide.none),
          borderRadius: BorderRadius.circular(30.0),
          color: ColorConstants.kyellow),
      height: height == null ? 60 : height,
      width: width == null ? double.infinity : width,
      child: FlatButton.icon(
        icon: icon,
        splashColor: Colors.yellow[700],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        label: Text(
          text,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        color: Colors.transparent,
        onPressed: onClick,
      ),
    );
  }
}
