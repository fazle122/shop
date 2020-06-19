import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/orders.dart';
import 'package:shoptempdb/screens/order_detail_screen.dart';
import 'package:shoptempdb/widgets/app_drawer.dart';
import 'package:shoptempdb/widgets/order_item.dart';
import 'package:intl/intl.dart';

import '../base_state.dart';

///------------with out future builder-----------------------

class CompletedOrdersScreen extends StatefulWidget {
  static const routeName = '/old-orders';

  @override
  _CompletedOrdersScreenState createState() => _CompletedOrdersScreenState();
}

class _CompletedOrdersScreenState extends BaseState<CompletedOrdersScreen> {
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });
      Provider.of<Orders>(context).fetchAndSetOrders().then((_) {
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
        appBar: AppBar(
          title: Text('Previous orders'),
        ),
//        drawer: AppDrawer(),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Consumer<Orders>(
                builder: (context, orderData, child) =>
                    orderData.orders.length > 0
                        ? ListView.builder(
                            itemCount: orderData.orders.length,
                            itemBuilder: (context, i) {
                              return Card(
                                margin: EdgeInsets.all(10),
                                child: Column(
                                  children: <Widget>[
                                    ListTile(
                                      title: Text(
                                          '\$${orderData.orders[i].invoiceAmount}'),
                                      subtitle: Text(
                                        DateFormat('dd/MM/yyyy hh:mm').format(
                                            orderData.orders[i].dateTime),
                                      ),
                                      onTap: () {
                                        Navigator.of(context).pushNamed(
                                            OrderDetailScreen.routeName,
                                            arguments: orderData.orders[i].id);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          )
                        : Center(
                            child: Text('No previous order'),
                          ),
              ));
  }
}
