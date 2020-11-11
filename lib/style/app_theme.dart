import 'package:flutter/material.dart';

class AppTheme {
  static themeBepari() {
    return ThemeData(

      // primaryColor: Color(0xFF008165),
      // primaryColorDark: Color(0xFFC9C9C9),
      primarySwatch: Colors.teal,
      accentColor: Colors.blueGrey,
      fontFamily: 'Josephin Sans',

      // buttonTheme: ButtonThemeData(
      //   disabledColor: Color(0xFFAFB1B3),
      //   buttonColor: Color(0xff00529C),
      //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.0))
      // ),
      //




    );
  }

  static RoundedRectangleBorder roundedBorderDecoration([double radius = 3.0]) {
    return RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
  }
}
