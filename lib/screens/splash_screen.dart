import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/auth.dart';
import 'package:shoptempdb/screens/products_overview_screen.dart';


class SplashScreen extends StatefulWidget {

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

 class _SplashScreenState extends State<SplashScreen>{

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pushNamed(ProductsOverviewScreen.routeName);
    });
  }

//  @override
//  void didChangeDependencies() {
////    Provider.of<Auth>(context).tryAutoLogin().then((_) {
//    Future.delayed(Duration(seconds: 2), () {
//      Navigator.of(context).pushNamed(ProductsOverviewScreen.routeName);
//    });
////    });
//    super.didChangeDependencies();
//  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Bepari',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 20.0),),),
    );

  }

}