import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class SplashScreen extends StatelessWidget{
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(child: Text('Bepari',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20.0),),),
    );
  }

}