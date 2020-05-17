import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/auth.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/orders.dart';
import 'package:shoptempdb/providers/products.dart';
import 'package:shoptempdb/screens/auth_screen.dart';
import 'package:shoptempdb/screens/cart_screen.dart';
import 'package:shoptempdb/screens/manage_product_screen.dart';
import 'package:shoptempdb/screens/orders_screen.dart';
import 'package:shoptempdb/screens/product_detail_screen.dart';
import 'package:shoptempdb/screens/products_overview_screen.dart';
import 'package:shoptempdb/screens/profile_screen.dart';
import 'package:shoptempdb/screens/splash_screen.dart';
import 'package:shoptempdb/screens/user_products_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Products(),
        ),
        ChangeNotifierProvider.value(
          value: Cart(),
        ),
        ChangeNotifierProvider.value(
          value: Orders(),
        ),
        ChangeNotifierProvider.value(
          value: Auth(),
        ),
      ],
      child:

//      Consumer<Auth>(
//        builder: (context, auth, child) => MaterialApp(
//          debugShowCheckedModeBanner: false,
//          title: 'Bepari',
//          theme: ThemeData(
//              primarySwatch: Colors.teal, accentColor: Colors.blueGrey),
//          home: auth.isAuth
//              ? ProductsOverviewScreen()
//              : FutureBuilder(
//                  future: auth.tryAutoLogin(),
//                  builder: (context, authResultSnapshot) =>
//                      authResultSnapshot.connectionState ==
//                              ConnectionState.waiting
//                          ? SplashScreen()
//                          : AuthScreen(),
//                ),
//        ),
//      ),


        MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'MyShop',
          theme: ThemeData(
              primarySwatch: Colors.teal,
              accentColor: Colors.blueGrey
          ),
          home:FutureBuilder(
            
            future:Future.delayed(Duration(seconds: 1)),
            builder: (context, authResultSnapshot) =>
            authResultSnapshot.connectionState ==
                ConnectionState.waiting
                ? SplashScreen()
                : ProductsOverviewScreen(),
          ),
          routes: {
            ProductsOverviewScreen.routeName: (context) => ProductsOverviewScreen(),
            ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
            CartScreen.routeName: (context) =>  CartScreen(),
            OrdersScreen.routeName: (context) =>  OrdersScreen(),
            UserProductsScreen.routeName: (context) =>  UserProductsScreen(),
            ManageProductScreen.routeName: (context) =>  ManageProductScreen(),
            AuthScreen.routeName: (context) => AuthScreen(),
            Profilepage.routeName: (context) =>Profilepage(),
          },
        )
    );
  }
}
