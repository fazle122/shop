
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
          ],
        ),
        drawer: AppDrawer(),
        body: _isLoading
            ? Center(child: CircularProgressIndicator(),)
            : Container(
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


  String _getStatus(var statusCode){
    switch(statusCode){
      case '0':
        return 'Draft';
      case '1':
        return 'Cancelled';
      case '2':
        return 'In Delivery';
      case '3':
        return 'Delivered';
      case '4':
        return 'Partially Paid';
      case '5':
        return 'Fully Paid';
      case 'not-delivered':
        return 'Not-delivered';
      case 'delivered':
        return 'Delivered';
      default:
        return '';
    }
  }

  Widget queryItemListDataWidget(BuildContext context) {
      return Container(
        child:  finalOrders != null && finalOrders.length > 0
            ? ListView.builder(
          controller: _scrollController,
          itemCount: finalOrders.length +1,
          itemBuilder: (context, i) {
            if(i == finalOrders.length){
              return _buildProgressIndicator();
            }else{

              return
                Card(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        title: Text('Invoice amount: ' + 'BDT ${finalOrders[i].invoiceAmount}',style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),),
                        subtitle:Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Flexible(child:Text('Invoice date: ' + DateFormat('EEEE, MMM d, ').format(finalOrders[i].invoiceDate),style: TextStyle(fontSize: 15.0),),),
                            Flexible(child: Text('Delivery date: ' + DateFormat('EEEE, MMM d, ').format(finalOrders[i].delivaryDate.toLocal()),style: TextStyle(fontSize: 12.0),),),
                            Flexible(child: Text('Status: ' + _getStatus(finalOrders[i].status.toString()),style: TextStyle(fontSize: 12.0),),),
                          ],
                        ),
                        trailing: Container(
                          width: 80,
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
