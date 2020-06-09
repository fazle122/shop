import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/orders.dart';
import 'package:shoptempdb/widgets/app_drawer.dart';
import 'package:shoptempdb/widgets/order_item.dart';


class OrdersScreen extends StatelessWidget {

  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('your orders'),),
      drawer: AppDrawer(),
      body: FutureBuilder(
          future: Provider.of<Orders>(context,listen: false).fetchAndSetOrders(),
          builder: (context,dataSnapshot) {
            if(dataSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(),);
            }else{
              if(dataSnapshot.error != null){
                return Center(child: Text('error occurred'),);
              }else{
                return Consumer<Orders>(builder: (context,orderData,child) => ListView.builder(
                  itemCount: orderData.orders.length,
                  itemBuilder: (context,i) => OrderItemWidget(orderData.orders[i]),
                ),);
              }
            }
          }
      ),
    );
  }

}

//class OrdersScreen extends StatelessWidget {
//  static const routeName = '/orders';
//
//  @override
//  Widget build(BuildContext context) {
//    final orderData = Provider.of<Orders>(context);
//
//    return Scaffold(
//        appBar: AppBar(
//          title: Text('My orders'),
//        ),
//        drawer: AppDrawer(),
//        body: orderData.orders.length>0 ?Text('order'):Text('no order')
////
//////        FutureBuilder(
//////            future: Provider.of<Orders>(context,listen: false).fetchAndSetOrders(),
//////            builder: (context,dataSnapshot) {
//////              if(dataSnapshot.connectionState == ConnectionState.waiting) {
//////                return Center(child: CircularProgressIndicator(),);
//////              }else{
//////                if(dataSnapshot.error != null){
//////                  return Center(child: Text('error occurred'),);
//////                }else{
//////                  return Consumer<Orders>(builder: (context,orderData,child) => ListView.builder(
//////                    itemCount: orderData.orders.length,
//////                    itemBuilder: (context,i) => OrderItemWidget(orderData.orders[i]),
//////                  ),);
//////                }
//////              }
//////            }
//////        ),
////
////        Column(
////          children: <Widget>[
////            Expanded(
////              flex: 1,
////              child: Container(
////                width: MediaQuery.of(context).size.width,
////                color: Colors.grey[300],
////                child: Center(child:Text('Pending orders')),
////              ),
////            ),
////            Expanded(
////              flex: 6,
////              child:
////              FutureBuilder(
////                  future: Provider.of<Orders>(context,listen: false).fetchAndSetOrders(),
////                  builder: (context,dataSnapshot) {
////                    if(dataSnapshot.connectionState == ConnectionState.waiting) {
////                      return Center(child: CircularProgressIndicator(),);
////                    }else{
////                      if(dataSnapshot.error != null){
////                        return Center(child: Text('error occurred'),);
////                      }else{
////                        return Consumer<Orders>(builder: (context,orderData,child) => ListView.builder(
////                          itemCount: orderData.orders.length,
////                          itemBuilder: (context,i) => OrderItemWidget(orderData.orders[i]),
////                        ),);
////                      }
////                    }
////                  }
////              ),
//////              orderData.orders.length > 0 ? Container(
//////                child:ListView.builder(
//////                  itemCount: orderData.orders.length,
//////                  itemBuilder: (context, i) =>
//////                      OrderItemWidget(orderData.orders[i]),
//////                ),
//////              ):Container(child: Center(child: Text('No pending orders'),),),
////            ),Expanded(
////              flex: 1,
////              child: Container(
////                width: MediaQuery.of(context).size.width,
////                color: Colors.grey[300],
////                child: Center(child:Text('Previous orders')),
////              ),
////            ),
//////            Expanded(
//////              flex: 10,
//////              child:
//////              FutureBuilder(
//////                  future: Provider.of<Orders>(context,listen: false).fetchAndSetOrders(),
//////                  builder: (context,dataSnapshot) {
//////                    if(dataSnapshot.connectionState == ConnectionState.waiting) {
//////                      return Center(child: CircularProgressIndicator(),);
//////                    }else{
//////                      if(dataSnapshot.error != null){
//////                        return Center(child: Text('error occurred'),);
//////                      }else{
//////                        return Consumer<Orders>(builder: (context,orderData,child) => ListView.builder(
//////                          itemCount: orderData.orders.length,
//////                          itemBuilder: (context,i) => OrderItemWidget(orderData.orders[i]),
//////                        ),);
//////                      }
//////                    }
//////                  }
//////              ),
////////              orderData.orders.length > 0 ? Container(
////////                child:ListView.builder(
////////                  itemCount: orderData.orders.length,
////////                  itemBuilder: (context, i) =>
////////                      OrderItemWidget(orderData.orders[i]),
////////                ),
////////              ):Container(child: Center(child: Text('No previous orders'),),),
//////            ),
////
////
////          ],
////        )
//    );
//  }
//}
