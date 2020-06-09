import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/auth.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/orders.dart';
import 'package:shoptempdb/providers/productCategories.dart';
import 'package:shoptempdb/providers/products.dart';
import 'package:shoptempdb/providers/shipping_address.dart';
import 'package:shoptempdb/screens/auth_screen.dart';
import 'package:shoptempdb/screens/cart_screen.dart';
import 'package:shoptempdb/screens/manage_product_screen.dart';
import 'package:shoptempdb/screens/orders_screen.dart';
import 'package:shoptempdb/screens/product_detail_screen.dart';
import 'package:shoptempdb/screens/products_overview_screen.dart';
import 'package:shoptempdb/screens/profile_screen.dart';
import 'package:shoptempdb/screens/shipping_address_screen.dart';
import 'package:shoptempdb/screens/splash_screen.dart';
import 'package:shoptempdb/screens/test.dart';
import 'package:shoptempdb/screens/user_products_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(
            value: Auth(),
          ),
          ChangeNotifierProvider(
            create: (context) => Products(),
          ),
          ChangeNotifierProvider(
            create: (context) => ProductCategories(),
          ),
          ChangeNotifierProvider.value(
            value: Cart(),
          ),

          ChangeNotifierProxyProvider<Auth, ShippingAddress>(
            update: (ctx, auth, previousAddress) => ShippingAddress(
              auth.token,
              auth.userId,
              previousAddress == null ? [] : previousAddress.allShippingAddress,
            ),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
            update: (ctx, auth, previousOrders) => Orders(
              auth.token,
              auth.userId,
              previousOrders == null ? [] : previousOrders.orders,
            ),
          ),
//          ChangeNotifierProvider.value(
//            value: Orders(),
//          ),
        ],
      child:
        Consumer<Auth>(
          builder: (ctx, auth, child) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Bepari',
            theme: ThemeData(primarySwatch: Colors.teal, accentColor: Colors.blueGrey),
            home: SplashScreen(),
//            FutureBuilder(
//              future: auth.tryAutoLogin(),
//              builder: (ctx, authResultSnapshot) => ProductsOverviewScreen(),
//            ),
            routes: {
              ProductsOverviewScreen.routeName: (context) => ProductsOverviewScreen(),
              ProductDetailScreen.routeName: (context) => ProductDetailScreen(),
              CartScreen.routeName: (context) =>  CartScreen(),
              OrdersScreen.routeName: (context) =>  OrdersScreen(),
              AuthScreen.routeName: (context) => AuthScreen(),
              Profilepage.routeName: (context) =>Profilepage(),
              ShippingAddressScreen.routeName: (context) => ShippingAddressScreen(),
//              TestScreen.routeName: (context) =>TestScreen(),
            },
          ),
        )

    );
  }
}
