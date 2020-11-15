import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/auth.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/screens/products_overview_screen.dart';
import 'package:shoptempdb/screens/delivery_address_screen.dart';


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
    Provider.of<Cart>(context,listen: false).fetchAndSetCartItems();
//    Future.delayed(Duration(seconds: 2), () {
//      Navigator.of(context).pushReplacementNamed(ProductsOverviewScreen.routeName);
//    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return
      Material(
      color: Colors.white,
      child: Center(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 2,
                child: Container(
                  padding: EdgeInsets.only(top: 100.0),
                  child: Image(
                    width: 200.0,
                    image: AssetImage(
                      'assets/splash-screen.png',
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: EdgeInsets.only(top: 100.0),
                  child: Text(
                    'version 1.0',
                    style: TextStyle(color: Colors.black38),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
    //   Scaffold(
    //   body: Center(
    //     child: Text(
    //       'Bepari',
    //       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
    //     ),
    //   ),
    // );
  }
}
