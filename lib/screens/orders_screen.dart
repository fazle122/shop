import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/orders.dart';
import 'package:shoptempdb/screens/completed_orders_screen.dart';
import 'package:shoptempdb/screens/order_detail_screen.dart';
import 'package:shoptempdb/widgets/app_drawer.dart';
import 'package:shoptempdb/widgets/order_fiter_dialog.dart';
import 'package:shoptempdb/widgets/order_item.dart';
import 'package:intl/intl.dart';

import '../base_state.dart';


///------------last and working class-----------------------
//class OrdersScreen extends StatelessWidget {
//
//  static const routeName = '/orders';
//
//  @override
//  Widget build(BuildContext context) {
//    return Scaffold(
//      appBar: AppBar(title: Text('My orders'),),
//      drawer: AppDrawer(),
//      body: FutureBuilder(
//          future: Provider.of<Orders>(context).fetchAndSetOrders(),
//          builder: (context,dataSnapshot) {
//            if(dataSnapshot.connectionState == ConnectionState.waiting) {
//              return Center(child: CircularProgressIndicator(),);
//            }else{
//              if(dataSnapshot.error != null){
//                return Center(child: Text('error occurred'),);
//              }else{
//                return Consumer<Orders>(builder: (context,orderData,child) => ListView.builder(
//                  itemCount: orderData.orders.length,
//                  itemBuilder: (context,i) => OrderItemWidget(orderData.orders[i]),
//                ),);
//              }
//            }
//          }
//      ),
//    );
//  }
//
//}




///------------with out future builder-----------------------

class OrdersScreen extends StatefulWidget {

  static const routeName = '/orders';
  @override
  _OrdersScreenState createState() => _OrdersScreenState();

}

class _OrdersScreenState extends BaseState<OrdersScreen>{

  var _isInit = true;
  var _isLoading = false;
  Map<String, dynamic> filters = Map();


  @override
  void didChangeDependencies(){
    if(_isInit) {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });
      Provider.of<Orders>(context).fetchAndSetOrders(filters).then((_){
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  getData(Map<String,dynamic> filters){
    if(_isInit) {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });
      Provider.of<Orders>(context,listen: false).fetchAndSetOrders(filters).then((_){
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
  }

  String convert12(String str) {
    String finalTime;
    int h1 = int.parse(str.substring(0, 1)) - 0;
    int h2 = int.parse(str.substring(1, 2));
    int hh = h1 * 10 + h2;

    String Meridien;
    if (hh < 12) {
      Meridien = " AM";
    } else
      Meridien = " PM";
    hh %= 12;
    if (hh == 0 && Meridien == ' PM') {
      finalTime = '12' + str.substring(2);
    } else {
      finalTime = hh.toString() + str.substring(2);
    }
    finalTime = finalTime + Meridien;
    return finalTime;
  }

  Future<Map<String, dynamic>> _orderFilterDialog() async {
    return showDialog<Map<String, dynamic>>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => OrderFilterDialog(),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Pending orders'),
          actions: <Widget>[
            PopupMenuButton<String>(
              onSelected: (val) async {
                switch (val) {
                  case 'COMPLETED_ORDERS':
                    Navigator.of(context).pushNamed(CompletedOrdersScreen.routeName);
                    break;
                  case 'FILTER':
                    var newFilter = await _orderFilterDialog();
                    if(newFilter != null){
                      setState(() {
                        filters = newFilter;
                        _isInit = true;
                      });
                    }
                    getData(filters);
                    break;

                }
              },
              itemBuilder: (BuildContext context) =>
              <PopupMenuItem<String>>[
                PopupMenuItem<String>(
                  value: 'COMPLETED_ORDERS',
                  child: Text('Completed orders'),
                ),
                PopupMenuItem<String>(
                  value: 'FILTER',
                  child: Text('Filter'),
                ),
              ],
            ),
          ],
        ),
        drawer: AppDrawer(),
        body:
        _isLoading?
        Center(child: CircularProgressIndicator(),)
            : Consumer<Orders>(builder: (context,orderData,child) =>
        orderData.orders.length >0 ?ListView.builder(
          itemCount: orderData.orders.length,
//                  itemBuilder: (context,i) => OrderItemWidget(orderData.orders[i]),
          itemBuilder: (context,i){
            return Dismissible(
//                      key:Key(orderData.orders[i].id.toString()),
              key:UniqueKey(),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Theme.of(context).errorColor,
                child: Icon(Icons.delete,color: Colors.white,size: 40,),
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: 20),
                margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
              ),
              confirmDismiss: (direction){
                return   showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      title: Text('Are you sure?'),
                      content: Text('Do you want to cancel this order?'),
                      actions: <Widget>[
                        FlatButton(child: Text('No'), onPressed: (){Navigator.of(context).pop(false);},),
                        FlatButton(child: Text('Yes'), onPressed: (){Navigator.of(context).pop(true);},),
                      ],
                    )
                );
              },
              onDismissed: (direction) async{
//                        setState(() {
//                          _isLoading = true;
//                        });
                await Provider.of<Orders>(context,listen: false).cancelOrder(orderData.orders[i].id.toString(),'test');
                if (!mounted) return;
                setState(() {
                  _isInit = true;
                });
              },
              child: Card(
                margin: EdgeInsets.all(10),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      title: Text(
                        DateFormat('EEEE, MMM d, ').format(orderData.orders[i].dateTime) +
                            convert12(DateFormat('hh:mm').format(orderData.orders[i].dateTime)),
                      ),
                      subtitle: Text('Total amount: ' +'\$${orderData.orders[i].invoiceAmount}'),

                      onTap: (){
                        Navigator.of(context).pushNamed(OrderDetailScreen.routeName,
                            arguments: orderData.orders[i].id);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ):Center(child: Text('No pending order'),),
        )
    );
  }

}


























///------------old code-----------------------

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
