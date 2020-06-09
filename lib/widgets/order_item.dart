import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/orders.dart';


class OrderItemWidget extends StatefulWidget {
  final OrderItem order;

  OrderItemWidget(this.order);

  @override
  _OrderItemState createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItemWidget> {
  var _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(10),
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text('\$${widget.order.invoiceAmount}'),
            subtitle: Text(
              DateFormat('dd/MM/yyyy hh:mm').format(widget.order.dateTime),
            ),
            trailing: IconButton(
              icon: Icon(_expanded ? Icons.expand_less : Icons.expand_more),
              onPressed: () {
                if (!mounted) return;
                setState(() {
                  _expanded = !_expanded;
                });
              },
            ),
          ),
//          _expanded?
//            Container(
//              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
////              height: min(widget.order.products.length * 20.0 + 10, 100),
//              child:
//
//              FutureBuilder(
//                  future: Provider.of<Orders>(context,listen: false).fetchSingleOrder(widget.order.id),
//                  builder: (context,dataSnapshot) {
//                    if(dataSnapshot.connectionState == ConnectionState.waiting) {
//                      return Center(child: CircularProgressIndicator(),);
//                    }else{
//                      if(dataSnapshot.error != null){
//                        return Center(child: Text('error occurred'),);
//                      }else{
//                        return Consumer<Orders>(builder: (context,orderData,child) => ListView(
//                          children: orderData.cartItem
//                              .map(
//                                (item) => Row(
//                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                              children: <Widget>[
//                                Text(
//                                  item.title,
//                                  style: TextStyle(
//                                    fontSize: 18,
//                                    fontWeight: FontWeight.bold,
//                                  ),
//                                ),
//                                Text(
////                                  '${prod.quantity}x \$${prod.price}',
//                                  item.quantity.toString(),
//                                  style: TextStyle(
//                                    fontSize: 18,
//                                    color: Colors.grey,
//                                  ),
//                                )
//                              ],
//                            ),
//                          ).toList(),
//                        ),);
//                      }
//                    }
//                  }
//              )
//
//
//
////              ListView(
////                children: widget.order.products
////                    .map(
////                      (prod) => Row(
////                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
////                    children: <Widget>[
////                      Text(
////                        prod.title,
////                        style: TextStyle(
////                          fontSize: 18,
////                          fontWeight: FontWeight.bold,
////                        ),
////                      ),
////                      Text(
////                        '${prod.quantity}x \$${prod.price}',
////                        style: TextStyle(
////                          fontSize: 18,
////                          color: Colors.grey,
////                        ),
////                      )
////                    ],
////                  ),
////                ).toList(),
////              ),
//            ):SizedBox(width: 0.0,height: 0.0,)
        ],
      ),
    );
  }
}
