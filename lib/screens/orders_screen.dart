import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/orders.dart';
import 'package:shoptempdb/widgets/app_drawer.dart';
import 'package:shoptempdb/widgets/order_item.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    final orderData = Provider.of<Orders>(context);

    return Scaffold(
        appBar: AppBar(
          title: Text('My orders'),
        ),
        drawer: AppDrawer(),
//      body: ListView.builder(
//          itemCount: orderData.orders.length,
//          itemBuilder: (context,i) => OrderItemWidget(orderData.orders[i]),
//      ),


//        body: Column(
//          children: <Widget>[
//            Flexible(
//                child:
//            Container(
//              color: Colors.grey[300],
//              child: Center(child: Text('Pending orders')),
//            )),
//            orderData.orders.length > 0 ? Flexible (
//
//              child:ListView.builder(
//                itemCount: orderData.orders.length,
//                itemBuilder: (context, i) =>
//                    OrderItemWidget(orderData.orders[i]),
//              ),
//            ):Container(height: 20.0,child: Center(child: Text('No pending orders'),),),
//            SizedBox(
//              height: 10.0,
//            ),
//            Flexible(
//                child:
//            Container(
//              color: Colors.grey[300],
//              child: Center(child: Text('Previous orders')),
//            )),
//            orderData.orders.length > 0 ? Flexible (
//
//              child:ListView.builder(
//                itemCount: orderData.orders.length,
//                itemBuilder: (context, i) =>
//                    OrderItemWidget(orderData.orders[i]),
//              ),
//            ):Container(height: 20.0,child: Center(child: Text('No pending orders'),),),
//          ],
//        ));


        body: Column(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.grey[300],
                child: Center(child:Text('Pending orders')),
              ),
            ),
            Expanded(
              flex: 6,
              child: orderData.orders.length > 0 ? Container(
                child:ListView.builder(
                  itemCount: orderData.orders.length,
                  itemBuilder: (context, i) =>
                      OrderItemWidget(orderData.orders[i]),
                ),
              ):Container(child: Center(child: Text('No pending orders'),),),
            ),Expanded(
              flex: 1,
              child: Container(
                width: MediaQuery.of(context).size.width,
                color: Colors.grey[300],
                child: Center(child:Text('Previous orders')),
              ),
            ),Expanded(
              flex: 10,
              child: orderData.orders.length > 0 ? Container(
                child:ListView.builder(
                  itemCount: orderData.orders.length,
                  itemBuilder: (context, i) =>
                      OrderItemWidget(orderData.orders[i]),
                ),
              ):Container(child: Center(child: Text('No previous orders'),),),
            ),


          ],
        ));
  }
}
