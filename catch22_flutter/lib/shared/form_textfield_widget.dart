import 'package:catch22_flutter/shared/constants/color_constants.dart';
import 'package:flutter/material.dart';

class TextFieldWidget extends StatelessWidget {
  final String hintText;
  final IconData prefixIconData;
  final bool obscureText;
  final Function onChanged;
  final Function validator;
  final bool isEmail;
  final bool isLast;

  //isEmail måste vara
  TextFieldWidget(
      {this.hintText,
      this.prefixIconData,
      this.obscureText,
      this.onChanged,
      //Skriva en Validator class för att kunna lämna specifika meddelande?
      this.validator,
      @required this.isEmail,
      @required this.isLast});

  Color _pcol = ColorConstants.kSecoundaryColor;

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);

    return TextFormField(
      onEditingComplete: isLast ? null : () => node.nextFocus(),
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      validator: validator,
      onChanged: onChanged,
      obscureText: obscureText,
      cursorColor: _pcol,
      style: TextStyle(
        color: _pcol,
        fontSize: 14.0,
      ),
      decoration: InputDecoration(
        labelStyle: TextStyle(color: _pcol),
        focusColor: _pcol,
        filled: true,
        enabledBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _pcol),
        ),
        labelText: hintText,
        prefixIcon: Icon(
          prefixIconData,
          size: 18,
          color: _pcol,
        ),
      ),
    );
  }
}
