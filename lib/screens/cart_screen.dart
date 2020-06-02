import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/orders.dart';
import 'package:shoptempdb/widgets/cart_item.dart';
import 'package:shoptempdb/widgets/confirm_order_dialog.dart';

class CartScreen extends StatelessWidget {
  static const routeName = '/cart';

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
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
                    Text('\$${(cart.totalAmount + 50).toStringAsFixed(2)}',
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
                      showDialog(
                          context: context,
//                          child: _confirmOrderDialog(context, cart)
                          child: ConfirmOrderDialog()
                      );
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
          Expanded(
              child: ListView.builder(
            itemCount: cart.itemCount,
            itemBuilder: (context, i) => CartItemWidget(
              cart.items.values.toList()[i].id,
              cart.items.keys.toList()[i],
              cart.items.values.toList()[i].price,
              cart.items.values.toList()[i].quantity,
              cart.items.values.toList()[i].title,
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
                          padding: EdgeInsets.only(left: 20.0,top: 5.0),
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
                            showDialog(
                                context: context,
//                                child: _confirmOrderDialog(context, cart)
                                child: ConfirmOrderDialog()
                            );
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

  Widget _confirmOrderDialog(BuildContext context, Cart cart) {
    return AlertDialog(
                            title: Center(child: Text('Confirm Address'),),
                            content: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListTile(
                                    leading: Icon(Icons.phone),
                                    title: Text('+88-01797512457'),
                                    onTap: (){
                                    },
                                  ),
                                  Divider(),
                                  ListTile(
                                    leading: Icon(Icons.email),
                                    title: Text('test@gmail.com'),
                                    onTap: (){
                                    },
                                  ),
                                  Divider(),
                                  ListTile(
                                    leading: Icon(Icons.home),
                                    title: Text('76/3, Block-g, Road-2 \nUttora, Dhaka'),
                                    onTap: (){
                                    },
                                  ),
                                  Divider(),
                                  Container(
                                    child: RaisedButton(
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(25.0),
                                          side: BorderSide(color: Colors.grey)),
                                      onPressed: () {
                                        Provider.of<Orders>(context, listen: false).addOrder(
                                            cart.items.values.toList(), cart.totalAmount);
                                        cart.clear();
                                        Navigator.of(context).pop();
                                      },
                                      color: Theme.of(context).primaryColor,
                                      textColor: Colors.white,
                                      child: Text("Confirm".toUpperCase(),
                                          style: TextStyle(fontSize: 14)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
  }
}
