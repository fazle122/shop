import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/auth.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/screens/products_overview_screen.dart';
import 'package:shoptempdb/screens/shipping_address_screen.dart';


//class SplashScreen extends StatelessWidget{
//  @override
//  Widget build(BuildContext context) {
//
//    return Scaffold(
//      body: Center(child: Text('Loading...'),),
//    );
//  }
//
//}



class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pushReplacementNamed(ProductsOverviewScreen.routeName);
    });
  }

  @override
  void didChangeDependencies() {
    Provider.of<Auth>(context).tryAutoLogin();
//    Future.delayed(Duration(seconds: 2), () {
//      Navigator.of(context).pushReplacementNamed(ProductsOverviewScreen.routeName);
//    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Bepari',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
        ),
      ),
    );
  }
}
