import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/orders.dart';
import 'package:shoptempdb/screens/order_detail_screen.dart';
import 'package:shoptempdb/widgets/app_drawer.dart';
import 'package:shoptempdb/widgets/order_item.dart';
import 'package:intl/intl.dart';


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

class _OrdersScreenState extends State<OrdersScreen>{

  var _isInit = true;
  var _isLoading = false;



  @override
  void didChangeDependencies(){
    if(_isInit) {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });
      Provider.of<Orders>(context).fetchAndSetOrders().then((_){
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('My orders'),),
      drawer: AppDrawer(),
      body:_isLoading? Center(child: CircularProgressIndicator(),)
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

                        setState(() {
                          _isInit = true;
                        });
                      },
                      child: Card(
                        margin: EdgeInsets.all(10),
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              title: Text('\$${orderData.orders[i].invoiceAmount}'),
                              subtitle: Text(
                                DateFormat('dd/MM/yyyy hh:mm').format(orderData.orders[i].dateTime),
                              ),
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
