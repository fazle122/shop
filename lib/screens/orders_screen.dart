
import 'package:shoptempdb/base_state.dart';
import 'package:shoptempdb/providers/orders.dart';
import 'package:shoptempdb/screens/order_detail_screen.dart';
import 'package:shoptempdb/screens/products_overview_screen.dart';
import 'package:shoptempdb/widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shoptempdb/widgets/order_fiter_dialog.dart';
import 'package:toast/toast.dart';



class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends BaseState<OrdersScreen> {
  var _isInit = true;
  var _isLoading = false;
  Map<String,dynamic> filters = Map();


  ScrollController _scrollController = new ScrollController();
  int pageCount = 1;
  int lastPage;
  int oldPageCount;
  List<OrderItem> finalOrders = [];
  int lastItemId = 0;
  bool isPerformingRequest = false;

  TextEditingController cancelCommentController;
  TextEditingController deliveryCommentController;
  TextEditingController amountController;
  var pageTitle = 'Pending';

  @override
  void initState() {
    cancelCommentController = TextEditingController();
    deliveryCommentController = TextEditingController();
    amountController = TextEditingController();
    filters['status_array'] = [0];
    super.initState();
  }

  @override
  void didChangeDependencies() {
    final orders = Provider.of<Orders>(context, listen: false);
    if (pageCount == 1) {
      if (_isInit) {
        setState(() {
          _isLoading = true;
        });
        Provider.of<Orders>(context, listen: false).fetchAndSetOrders(filters,pageCount).then((data) {
          setState(() {
            finalOrders = data;
            lastPage = orders.lastPageNo;
            oldPageCount = 0;
            _isLoading = false;
          });
        });
      }
      _isInit = false;
    }
    _scrollController.addListener(() {
        _isInit = true;
        if (pageCount < lastPage) if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          setState(() {
            pageCount += 1;
          });
          getOrderData(orders,filters, pageCount);
        }
    });

    super.didChangeDependencies();
  }

  List<OrderItem> getOrderData(Orders orders,Map<String,dynamic> filters,int pageCount) {
    if(pageCount <= orders.lastPageCount) {

    if (_isInit) {
      if (!isPerformingRequest) {
        setState(() {
          isPerformingRequest = true;
        }
        );
      }
      Provider.of<Orders>(context, listen: false).fetchAndSetOrders(filters,pageCount).then((data) {
        isPerformingRequest = false;
        if (data == null || data.isEmpty) {
          if (finalOrders.isNotEmpty) animateScrollBump();
          if (finalOrders.isEmpty) {
            setState(() {});
          }
        } else {
          setState(() {
            oldPageCount += 1;
            finalOrders.addAll(data);
            lastItemId = data.last.id;
          });
        }

      });
    }
    }

    _isInit = false;
    return finalOrders;
  }



  void animateScrollBump() {
    double edge = 50.0;
    double offsetFromBottom = _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;
    if (offsetFromBottom < edge) {
      _scrollController.animateTo(
          _scrollController.offset - (edge - offsetFromBottom),
          duration: new Duration(milliseconds: 500),
          curve: Curves.easeOut);
    }
  }


  Future<Map<String, dynamic>> _orderFilterDialog() async {
    return showDialog<Map<String, dynamic>>(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => OrderFilterDialog(),
    );
  }


  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Opacity(
          opacity: isPerformingRequest ? 1.0 : 0.0,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }





  @override
  Widget build(BuildContext context) {
    final orders = Provider.of<Orders>(context, listen: false);

    return Scaffold(
        appBar: AppBar(
          title: Text('All orders'),
          actions: <Widget>[
            InkWell(
              child: Container(
                margin: EdgeInsets.all(10.0),
                width: 80.0,
                height: 10.0,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1.0, style: BorderStyle.solid,color: Colors.grey.shade500),
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                  ),
                ),
                child: Center(
                    child: Text(
                      'New Order',
                      style:
                      TextStyle(color: Theme.of(context).primaryColorDark,fontWeight: FontWeight.bold),
                    )),
              ),
              onTap: () {
                Navigator.pushNamed(context, ProductsOverviewScreen.routeName);
              },
            ),
            IconButton(
              icon: Icon(Icons.filter_list),
              onPressed: () async{
                var newFilter = await _orderFilterDialog();
                if(newFilter != null && newFilter.length>0){
                  setState(() {
                    pageCount = 1;
                    finalOrders = [];
                    filters = newFilter;
                    _isInit = true;
                  });
                }
                getOrderData(orders,filters,1);
              },
            ),
//             PopupMenuButton<String>(
//               onSelected: (val) async {
//                 switch (val) {
//                   case 'FILTER':
//                     var newFilter = await _orderFilterDialog();
//                     if(newFilter != null && newFilter.length>0){
//                       setState(() {
//                         pageCount = 1;
//                         finalOrders = [];
//                         filters = newFilter;
//                         _isInit = true;
//                       });
//                     }
//                     getOrderData(orders,filters,1);
//                     break;
//
//                 }
//               },
//               itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
// //                PopupMenuItem<String>(
// //                  value: 'COMPLETED_ORDERS',
// //                  child: Text('Completed orders'),
// //                ),
//                 PopupMenuItem<String>(
//                   value: 'FILTER',
//                   child: Text('Filter'),
//                 )
//               ],
//             ),
          ],
        ),
        drawer: AppDrawer(),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(),)
            : Container(
//          height: MediaQuery.of(context).size.height * 7/10,
          child: Column(
            children: <Widget>[
              Expanded(
                  child: queryItemListDataWidget(context)
              ),

            ],
          ),
        )

    );
  }


  Widget queryItemListDataWidget(BuildContext context) {

    // if (finalOrders.isNotEmpty) //has data & performing/not performing
      return Container(
        child:  finalOrders != null && finalOrders.length > 0
            ? ListView.builder(
          controller: _scrollController,
          itemCount: finalOrders.length +1,
          itemBuilder: (context, i) {
            if(i == finalOrders.length){
              return _buildProgressIndicator();
            }else{
//            return ChangeNotifierProvider.value(value: null,child:Text(''));

              return
                Card(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: Text('Invoice amount: ' + '\$ ${finalOrders[i].invoiceAmount}',style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),),
                        subtitle:Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Flexible(child:Text('Invoice date: ' + DateFormat('EEEE, MMM d, ').format(finalOrders[i].invoiceDate),style: TextStyle(fontSize: 15.0),),),
                            Flexible(child: Text('Delivery date: ' + DateFormat('EEEE, MMM d, ').format(finalOrders[i].delivaryDate.toLocal()),style: TextStyle(fontSize: 12.0),),),
                          ],
                        ),
                        trailing: Container(
                          width: 100,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              finalOrders[i].status == 0 || finalOrders[i].status == 1?IconButton(
                                icon: Icon(Icons.cancel),
                                onPressed: () async {
                                  showDialog(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) =>
                                          AlertDialog(
                                            title: Center(child: Text('Cancel order')),
                                            content: Container(
                                              height: 70,
                                              child: Column(
                                                children: <Widget>[
                                                  Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: <Widget>[
                                                      Text('Comment'),
                                                      SizedBox(width: 10,),
                                                      Container(
                                                        width: 150,
                                                        child: TextFormField(
                                                          keyboardType: TextInputType.multiline,
                                                          maxLines: 2,
                                                          controller: cancelCommentController,
                                                          decoration: InputDecoration(hintText: 'write a comment'),
                                                        ),
                                                      )
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                            actions: <Widget>[

                                              FlatButton(
                                                child: Text('Confirm'),
                                                onPressed: () async{

                                                  var response = await Provider.of<Orders>(context, listen: false).cancelOrder(finalOrders[i].id.toString(), cancelCommentController.text);
                                                  if(response != null){
                                                    Toast.show(response['msg'], context,duration: Toast.LENGTH_LONG,gravity: Toast.BOTTOM);
                                                  }else{
                                                    Toast.show('Something went wrong, please try again.', context,duration: Toast.LENGTH_LONG,gravity: Toast.BOTTOM);

                                                  }
                                                  if (!mounted) return;
                                                  setState(() {
                                                    _isInit = true;
                                                    _isLoading = true;
                                                    cancelCommentController.text = '';
                                                  });
                                                  Provider.of<Orders>(context, listen: false).fetchAndSetOrders(filters,pageCount).then((data) {
                                                    setState(() {
                                                      finalOrders = data;
                                                      _isLoading = false;
                                                    });
                                                  });
                                                  _isInit = false;
                                                  Navigator.of(
                                                      context)
                                                      .pop(true);
                                                },
                                              ),
                                              FlatButton(
                                                child: Text('Cancel'),
                                                onPressed: () {
                                                  Navigator.of(
                                                      context)
                                                      .pop(false);
                                                },
                                              ),
                                            ],
                                          ));
                                },
                              ):
                              SizedBox(width: 0.0,height: 0.0,),
                              // SizedBox(width: 20.0,),
                            ],
                          ),
                        ),
                        onTap: () async {
                          Navigator.of(context).pushNamed(OrderDetailScreen.routeName, arguments: finalOrders[i].id);
                        },
                      ),
                    ],
                  ),
                );
            }
          },
        )
            : Center(
          child: Text('No pending order'),
        ),

      );
    if (isPerformingRequest)
      return Center(
        child: CircularProgressIndicator(),
      );

    return Center(
      child: Text('no order found'),
    );
  }

}



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

// class OrdersScreen extends StatefulWidget {
//
//   static const routeName = '/orders';
//   @override
//   _OrdersScreenState createState() => _OrdersScreenState();
//
// }
//
// class _OrdersScreenState extends BaseState<OrdersScreen>{
//
//   var _isInit = true;
//   var _isLoading = false;
//   Map<String, dynamic> filters = Map();
//
//
//   @override
//   void didChangeDependencies(){
//     if(_isInit) {
//       if (!mounted) return;
//       setState(() {
//         _isLoading = true;
//       });
//       Provider.of<Orders>(context).fetchAndSetOrders(filters).then((_){
//         if (!mounted) return;
//         setState(() {
//           _isLoading = false;
//         });
//       });
//     }
//     _isInit = false;
//     super.didChangeDependencies();
//   }
//
//   getData(Map<String,dynamic> filters){
//     if(_isInit) {
//       if (!mounted) return;
//       setState(() {
//         _isLoading = true;
//       });
//       Provider.of<Orders>(context,listen: false).fetchAndSetOrders(filters).then((_){
//         if (!mounted) return;
//         setState(() {
//           _isLoading = false;
//         });
//       });
//     }
//     _isInit = false;
//   }
//
//   String convert12(String str) {
//     String finalTime;
//     int h1 = int.parse(str.substring(0, 1)) - 0;
//     int h2 = int.parse(str.substring(1, 2));
//     int hh = h1 * 10 + h2;
//
//     String Meridien;
//     if (hh < 12) {
//       Meridien = " AM";
//     } else
//       Meridien = " PM";
//     hh %= 12;
//     if (hh == 0 && Meridien == ' PM') {
//       finalTime = '12' + str.substring(2);
//     } else {
//       finalTime = hh.toString() + str.substring(2);
//     }
//     finalTime = finalTime + Meridien;
//     return finalTime;
//   }
//
//   Future<Map<String, dynamic>> _orderFilterDialog() async {
//     return showDialog<Map<String, dynamic>>(
//       barrierDismissible: false,
//       context: context,
//       builder: (BuildContext context) => OrderFilterDialog(),
//     );
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           title: Text('Pending orders'),
//           actions: <Widget>[
//             PopupMenuButton<String>(
//               onSelected: (val) async {
//                 switch (val) {
//                   // case 'COMPLETED_ORDERS':
//                   //   Navigator.of(context).pushNamed(CompletedOrdersScreen.routeName);
//                   //   break;
//                   case 'FILTER':
//                     var newFilter = await _orderFilterDialog();
//                     if(newFilter != null){
//                       setState(() {
//                         filters = newFilter;
//                         _isInit = true;
//                       });
//                     }
//                     getData(filters);
//                     break;
//
//                 }
//               },
//               itemBuilder: (BuildContext context) =>
//               <PopupMenuItem<String>>[
//                 // PopupMenuItem<String>(
//                 //   value: 'COMPLETED_ORDERS',
//                 //   child: Text('Completed orders'),
//                 // ),
//                 PopupMenuItem<String>(
//                   value: 'FILTER',
//                   child: Text('Filter'),
//                 ),
//               ],
//             ),
//           ],
//         ),
//         drawer: AppDrawer(),
//         body:
//         _isLoading?
//         Center(child: CircularProgressIndicator(),)
//             : Consumer<Orders>(builder: (context,orderData,child) =>
//         orderData.orders.length >0 ?ListView.builder(
//           itemCount: orderData.orders.length,
// //                  itemBuilder: (context,i) => OrderItemWidget(orderData.orders[i]),
//           itemBuilder: (context,i){
//             return Dismissible(
// //                      key:Key(orderData.orders[i].id.toString()),
//               key:UniqueKey(),
//               direction: DismissDirection.endToStart,
//               background: Container(
//                 color: Theme.of(context).errorColor,
//                 child: Icon(Icons.delete,color: Colors.white,size: 40,),
//                 alignment: Alignment.centerRight,
//                 padding: EdgeInsets.only(right: 20),
//                 margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
//               ),
//               confirmDismiss: (direction){
//                 return   showDialog(
//                     context: context,
//                     barrierDismissible: false,
//                     builder: (context) => AlertDialog(
//                       title: Text('Are you sure?'),
//                       content: Text('Do you want to cancel this order?'),
//                       actions: <Widget>[
//                         FlatButton(child: Text('No'), onPressed: (){Navigator.of(context).pop(false);},),
//                         FlatButton(child: Text('Yes'), onPressed: (){Navigator.of(context).pop(true);},),
//                       ],
//                     )
//                 );
//               },
//               onDismissed: (direction) async{
// //                        setState(() {
// //                          _isLoading = true;
// //                        });
//                 await Provider.of<Orders>(context,listen: false).cancelOrder(orderData.orders[i].id.toString(),'test');
//                 if (!mounted) return;
//                 setState(() {
//                   _isInit = true;
//                 });
//               },
//               child: Card(
//                 margin: EdgeInsets.all(10),
//                 child: Column(
//                   children: <Widget>[
//                     ListTile(
//                       title: Text(
//                         DateFormat('EEEE, MMM d, ').format(orderData.orders[i].dateTime) +
//                             convert12(DateFormat('hh:mm').format(orderData.orders[i].dateTime)),
//                       ),
//                       subtitle: Text('Total amount: ' +'\$${orderData.orders[i].invoiceAmount}'),
//
//                       onTap: (){
//                         Navigator.of(context).pushNamed(OrderDetailScreen.routeName,
//                             arguments: orderData.orders[i].id);
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           },
//         ):Center(child: Text('No pending order'),),
//         )
//     );
//   }
//
// }


























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
