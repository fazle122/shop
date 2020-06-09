//import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
//import 'package:shoptempdb/providers/products.dart';
//import 'package:shoptempdb/screens/manage_product_screen.dart';
//import 'package:shoptempdb/widgets/app_drawer.dart';
//import 'package:shoptempdb/widgets/user_product_item.dart';
//
//class UserProductsScreen extends StatelessWidget {
//  static const routeName = '/user-products';
//
//  @override
//  Widget build(BuildContext context) {
//    final productsData = Provider.of<Products>(context);
//    return Scaffold(
//      appBar: AppBar(
//        title: Text('Your Products'),
//        actions: <Widget>[
//          IconButton(icon: Icon(Icons.add), onPressed: () {
//            Navigator.of(context).pushNamed(ManageProductScreen.routeName);
//          },)
//        ],
//      ),
//      drawer: AppDrawer(),
//      body:Padding(
//        padding: EdgeInsets.all(8),
//        child: ListView.builder(
//          itemCount: productsData.items.length,
//          itemBuilder: (context,i) => Column(
//            children: <Widget>[
//              UserProductItem(
//                  productsData.items[i].id,
//                  productsData.items[i].title,
//                  productsData.items[i].imageUrl
//              ),
//              Divider(),
//            ],
//          ),
//        ),
//      ),
//    );
//  }
//
//
//}