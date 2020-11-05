import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/orders.dart';
import 'package:shoptempdb/widgets/app_drawer.dart';
import 'package:shoptempdb/widgets/order_item.dart';
import 'package:intl/intl.dart';


class OrderDetailScreen extends StatelessWidget {

  static const routeName = '/order-detail';


  double _fetchDeliveryCharge(double invoiceAmount,List<InvoiceItem> item){
    var itemSubTotal = 0.0;
    var delCharge = 0.0;
    item.forEach((item){
      itemSubTotal += item.unitPrice.toDouble() * item.quantity;
    });

    delCharge = invoiceAmount - itemSubTotal;
    return delCharge;
  }

  double _fetchItemTotal(List<InvoiceItem> item){
    var itemSubTotal = 0.0;
    item.forEach((item){
      itemSubTotal += item.unitPrice.toDouble() * item.quantity;
    });

    return itemSubTotal;
  }


  @override
  Widget build(BuildContext context) {

    final orderId = ModalRoute.of(context).settings.arguments as int;
    return Scaffold(
        appBar: AppBar(title: Text('Order detail'),),
        body: FutureBuilder(
          future:Provider.of<Orders>(context,listen:false).fetchSingleOrder(orderId),
          builder: (context,snapshot){
            if(snapshot.connectionState == ConnectionState.waiting){
              return Center(child: CircularProgressIndicator(),);
            }else{
              if(snapshot.error != null){
                return Center(child: Text('error occurred'),);
              }else{
                return Consumer<Orders>(builder: (context,orderDetailData,child) =>
                Column(
                  children: <Widget>[
                    Card(
                      margin: EdgeInsets.all(15.0),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: ListTile(
                          title:
                          Padding(
                            padding: EdgeInsets.only(bottom: 10.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Text('Total invoice amount: ' + orderDetailData.singOrderItem.invoiceAmount.toString() + ' BDT',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18.0),),
                                Text('Due: ' + orderDetailData.singOrderItem.totalDue.toString() + ' BDT'),
                                // Text('Subtotal: ' + _fetchItemTotal(orderDetailData.singOrderItem.invoiceItem).toString() + ' BDT'),
                                // Text('Delivery charge: ' + _fetchDeliveryCharge(orderDetailData.singOrderItem.invoiceAmount,orderDetailData.singOrderItem.invoiceItem).toString() + ' BDT'),

                              ],
                            ) ,
                          ),
                            subtitle: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Flexible(child:Text('Invoice date: ' + DateFormat('EEEE, MMM d, ').format(orderDetailData.singOrderItem.invoiceDate),style: TextStyle(fontSize: 15.0),),),
                                // Flexible(child: Text('Invoice created: ' + DateFormat('EEEE, MMM d, hh:mm aaa').format(orderDetailData.singOrderItem.createdAt.toLocal()),style: TextStyle(fontSize: 12.0),),),

                              ],
                            )
                        )
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                        child: ListView.builder(
                          itemCount: orderDetailData.singOrderItem.invoiceItem.length,
                          itemBuilder: (context, i) =>
                              Card(
                                shape: StadiumBorder(
                                  side: BorderSide(
                                    color: Colors.grey[200],
                                    width: 2.0,
                                  ),
                                ),
                                margin: EdgeInsets.all(10),
                                child: Column(
                                  children: <Widget>[
                                    orderDetailData.singOrderItem.invoiceItem[i].productID == 1 ?
                                    ListTile(
                                        title: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text(orderDetailData.singOrderItem.invoiceItem[i].productName),
                                            SizedBox(width: 20.0,),
                                            Text('\$${(double.parse(orderDetailData.singOrderItem.invoiceItem[i].unitPrice.toString()))}'),
                                          ],
                                        )
                                    ):
                                    ListTile(
                                        title: Center(child:Text(orderDetailData.singOrderItem.invoiceItem[i].productName)),
                                        subtitle: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: <Widget>[
                                            Text('Quantity : ' + orderDetailData.singOrderItem.invoiceItem[i].quantity.toString()),
                                            SizedBox(width: 30.0,),
                                            Text('Total : \$${(double.parse(orderDetailData.singOrderItem.invoiceItem[i].unitPrice.toString()) * double.parse(orderDetailData.singOrderItem.invoiceItem[i].quantity.toString()))}'),
                                          ],
                                        )
                                    ),
                                  ],
                                ),
                              )
                        )
                    ),
                  ],
                ));
              }
            }
          },
        )
    );
  }
}

