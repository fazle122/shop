import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/orders.dart';
import 'package:shoptempdb/widgets/app_drawer.dart';
import 'package:shoptempdb/widgets/order_item.dart';
import 'package:intl/intl.dart';


class OrderDetailScreen extends StatelessWidget {

  static const routeName = '/order-detail';

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
//                    Text(orderDetailData.singOrderItem.totalDue.toString()),);
                Column(
                  children: <Widget>[
                    Card(
                      margin: EdgeInsets.all(15.0),
                      child: Padding(
                        padding: EdgeInsets.all(8),
                        child: ListTile(
//                          title: Text('Total amount:  ' + 'BDT\$${(orderDetailData.singOrderItem.totalDue.toString())}'),
                          title: Text('Total amount:  ' + orderDetailData.singOrderItem.totalDue.toString() + ' BDT'),
                          subtitle: Text(
                            DateFormat('EEEE, MMM d, ').format(orderDetailData.singOrderItem.dateTime) +
                                convert12(DateFormat('hh:mm').format(orderDetailData.singOrderItem.dateTime)),
                          ),
                        )
//                        Row(
//                          mainAxisAlignment: MainAxisAlignment.center,
//                          children: <Widget>[
//                            Text(
//                              'Total amount:',
//                              style: TextStyle(fontSize: 20),
//                            ),
//                            Spacer(),
//                            Chip(
//                              label:
//                              Text('\$${(orderDetailData.singOrderItem.totalDue.toString())}',
//                                style: TextStyle(
//                                    color:
//                                    Theme.of(context).primaryTextTheme.title.color),
//                              ),
//                              backgroundColor: Theme.of(context).primaryColor,
//                            ),
//                          ],
//                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Expanded(
                        child: ListView.builder(
                          itemCount: orderDetailData.singOrderItem.invoiceItem.length,
                          itemBuilder: (context, i) => ListTile(
                            title: Text('Item name:' + orderDetailData.singOrderItem.invoiceItem[i].productName),
                            subtitle: ListTile(
                              title: Text('Quantity:'  + orderDetailData.singOrderItem.invoiceItem[i].quantity.toString()),
                              subtitle: Text(
                                  'price:' + orderDetailData.singOrderItem.invoiceItem[i].quantity.toString() + 'x'
                                      + orderDetailData.singOrderItem.invoiceItem[i].unitPrice.toString()  + ' = '
                                      + (orderDetailData.singOrderItem.invoiceItem[i].quantity * orderDetailData.singOrderItem.invoiceItem[i].unitPrice).toString()
                                      + ' BDT'

                              ),
                            ),
                          ),
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

