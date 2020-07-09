import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/auth.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/orders.dart';
import 'package:shoptempdb/screens/auth_screen.dart';
import 'package:shoptempdb/screens/confirm_order_screen.dart';
import 'package:shoptempdb/widgets/cart_item.dart';
import 'package:shoptempdb/widgets/confirm_order_dialog.dart';
import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shoptempdb/screens/test.dart';
import 'package:provider/provider.dart';



class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final auth = Provider.of<Auth>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Your cart'),
      ),
      body: Column(
        children: <Widget>[
          Card(
            margin: EdgeInsets.all(15.0),
            child: Padding(
              padding: EdgeInsets.all(8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    'Total',
                    style: TextStyle(fontSize: 20),
                  ),
                  Spacer(),
                  Chip(
                    label: cart.totalAmount<500 && cart.items.length >0 ?
//                    Text('\$${(cart.totalAmount + 50).toStringAsFixed(2)}',
                    Text('\$${(cart.totalAmount).toStringAsFixed(2)}',
                      style: TextStyle(
                          color:
                          Theme.of(context).primaryTextTheme.title.color),
                    ) :
                    Text('\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                          color:
                          Theme.of(context).primaryTextTheme.title.color),
                    ),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                  FlatButton(
                    textColor: Theme.of(context).primaryColor,
                    child: Text('Order now'),
                    onPressed: () {
                      auth.isAuth?
                      Navigator.of(context).pushNamed(ShippingAddressScreen.routeName,arguments: cart)
                          :Navigator.of(context).pushNamed(AuthScreen.routeName);
//                      showDialog(
//                          context: context,
//                          child: _confirmOrderDialog(context, cart)
////                          child: ConfirmOrderDialog()
//                      );
//                      Provider.of<Orders>(context, listen: false).addOrder(
//                          cart.items.values.toList(), cart.totalAmount);
//                      cart.clear();
                    },
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
//          Expanded(
//            child: cart.items.length > 0 ? ListView.builder(
//                padding: const EdgeInsets.all(10.0),
//                itemCount: cart.items.length,
//                itemBuilder: (context, i) => CartItemWidget(),
//                ):SizedBox(width: 0.0,height: 0.0,)
//          ),
          Expanded(
              child: ListView.builder(
                itemCount: cart.itemCount,
                itemBuilder: (context, i) => CartItemWidget(
                  cart.items.values.toList()[i].id,
                  cart.items.keys.toList()[i],
                  cart.items.values.toList()[i].price,
                  cart.items.values.toList()[i].quantity,
                  cart.items.values.toList()[i].title,
                  cart.items.values.toList()[i].isNonInventory,
                  cart.items.values.toList()[i].discount,
                  cart.items.values.toList()[i].discountId,
                  cart.items.values.toList()[i].discountType,
                ),
              )),
          cart.items.length > 0
              ? Container(
              height: 50.0,
              color: Theme.of(context).primaryColor,
              child: Row(
                children: <Widget>[
                  Container(
                      width: MediaQuery.of(context).size.width * 5 / 7,
                      padding: EdgeInsets.only(left: 20.0,top: 2.0),
                      color: Theme.of(context).primaryColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text('SubTotal: ' +
                              cart.totalAmount.toStringAsFixed(2)),
                          cart.totalAmount>500 ? Text('Delivery charge: 00.00 BDT'):Text('Delivery charge: 50.00 BDT'),
                          cart.totalAmount>500 ?
                          Text(
                            'Total amount : ' +
                                cart.totalAmount.toStringAsFixed(2),
                            style: TextStyle(color: Colors.white),
                          )
                              :Text(
                            'Total amount : ' +
                                (cart.totalAmount + 50.00).toStringAsFixed(2),
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      )),
                  Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width * 2 / 7,
                    color: Theme.of(context).primaryColorDark,
                    child: InkWell(
                      child: Center(
                        child: Text(
                          'Check out',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      onTap: () {
                        auth.isAuth?
                        Navigator.of(context).pushNamed(ShippingAddressScreen.routeName,arguments: cart)
                            :Navigator.of(context).pushNamed(AuthScreen.routeName);
//                            showDialog(
//                                context: context,
//                                child: _confirmOrderDialog(context, cart)
////                                child: ConfirmOrderDialog()
//                            );
                      },
                    ),
                  ),
                ],
              ))
              : SizedBox(
            width: 0.0,
            height: 0.0,
          )
        ],
      ),
    );
  }
}







//class CartScreen extends StatelessWidget {
//  static const routeName = '/cart';
//
//  @override
//  Widget build(BuildContext context) {
//    final cart = Provider.of<Cart>(context);
//    final auth = Provider.of<Auth>(context);
//    return Scaffold(
//      appBar: AppBar(
//        title: Text('Your cart'),
//      ),
//      body: Column(
//        children: <Widget>[
//          Card(
//            margin: EdgeInsets.all(15.0),
//            child: Padding(
//              padding: EdgeInsets.all(8),
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                children: <Widget>[
//                  Text(
//                    'Total',
//                    style: TextStyle(fontSize: 20),
//                  ),
//                  Spacer(),
//                  Chip(
//                    label: cart.totalAmount<500 && cart.items.length >0 ?
////                    Text('\$${(cart.totalAmount + 50).toStringAsFixed(2)}',
//                        Text('\$${(cart.totalAmount).toStringAsFixed(2)}',
//                      style: TextStyle(
//                          color:
//                          Theme.of(context).primaryTextTheme.title.color),
//                    ) :
//                    Text('\$${cart.totalAmount.toStringAsFixed(2)}',
//                      style: TextStyle(
//                          color:
//                              Theme.of(context).primaryTextTheme.title.color),
//                    ),
//                    backgroundColor: Theme.of(context).primaryColor,
//                  ),
//                  FlatButton(
//                    textColor: Theme.of(context).primaryColor,
//                    child: Text('Order now'),
//                    onPressed: () {
//                      auth.isAuth?
//                      Navigator.of(context).pushNamed(ShippingAddressScreen.routeName,arguments: cart)
//                      :Navigator.of(context).pushNamed(AuthScreen.routeName);
////                      showDialog(
////                          context: context,
////                          child: _confirmOrderDialog(context, cart)
//////                          child: ConfirmOrderDialog()
////                      );
////                      Provider.of<Orders>(context, listen: false).addOrder(
////                          cart.items.values.toList(), cart.totalAmount);
////                      cart.clear();
//                    },
//                  )
//                ],
//              ),
//            ),
//          ),
//          SizedBox(
//            height: 10,
//          ),
//          Expanded(
//              child: ListView.builder(
//            itemCount: cart.itemCount,
//            itemBuilder: (context, i) => CartItemWidget(
//              cart.items.values.toList()[i].id,
//              cart.items.keys.toList()[i],
//              cart.items.values.toList()[i].price,
//              cart.items.values.toList()[i].quantity,
//              cart.items.values.toList()[i].title,
//              cart.items.values.toList()[i].isNonInventory,
//              cart.items.values.toList()[i].discount,
//              cart.items.values.toList()[i].discountId,
//              cart.items.values.toList()[i].discountType,
//            ),
//          )),
//          cart.items.length > 0
//              ? Container(
//                  height: 50.0,
//                  color: Theme.of(context).primaryColor,
//                  child: Row(
//                    children: <Widget>[
//                      Container(
//                          width: MediaQuery.of(context).size.width * 5 / 7,
//                          padding: EdgeInsets.only(left: 20.0,top: 5.0),
//                          color: Theme.of(context).primaryColor,
//                          child: Column(
//                            crossAxisAlignment: CrossAxisAlignment.start,
//                            mainAxisAlignment: MainAxisAlignment.start,
//                            children: <Widget>[
//                              Text('SubTotal: ' +
//                                  cart.totalAmount.toStringAsFixed(2)),
//                              cart.totalAmount>500 ? Text('Delivery charge: 00.00 BDT'):Text('Delivery charge: 50.00 BDT'),
//                              cart.totalAmount>500 ?
//                              Text(
//                                'Total amount : ' +
//                                    cart.totalAmount.toStringAsFixed(2),
//                                style: TextStyle(color: Colors.white),
//                              )
//                              :Text(
//                                'Total amount : ' +
//                                    (cart.totalAmount + 50.00).toStringAsFixed(2),
//                                style: TextStyle(color: Colors.white),
//                              ),
//                            ],
//                          )),
//                      Container(
//                        height: MediaQuery.of(context).size.height,
//                        width: MediaQuery.of(context).size.width * 2 / 7,
//                        color: Theme.of(context).primaryColorDark,
//                        child: InkWell(
//                          child: Center(
//                            child: Text(
//                              'Check out',
//                              style: TextStyle(
//                                  color: Colors.white,
//                                  fontWeight: FontWeight.bold),
//                            ),
//                          ),
//                          onTap: () {
//                            auth.isAuth?
//                            Navigator.of(context).pushNamed(ShippingAddressScreen.routeName,arguments: cart)
//                                :Navigator.of(context).pushNamed(AuthScreen.routeName);
////                            showDialog(
////                                context: context,
////                                child: _confirmOrderDialog(context, cart)
//////                                child: ConfirmOrderDialog()
////                            );
//                          },
//                        ),
//                      ),
//                    ],
//                  ))
//              : SizedBox(
//                  width: 0.0,
//                  height: 0.0,
//                )
//        ],
//      ),
//    );
//  }
//}
