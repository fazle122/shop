import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/orders.dart';
import 'package:shoptempdb/providers/product.dart';
import 'package:shoptempdb/providers/products.dart';
import 'package:shoptempdb/providers/shipping_address.dart';
import 'package:shoptempdb/screens/orders_screen.dart';
import 'package:shoptempdb/screens/products_overview_screen.dart';
import 'package:shoptempdb/screens/test.dart';
import 'package:shoptempdb/widgets/app_drawer.dart';
import 'package:shoptempdb/widgets/create_shippingAddress_dialog.dart';
import 'package:shoptempdb/widgets/order_item.dart';
import 'package:shoptempdb/widgets/shipping_address_item.dart';
import 'package:dio/dio.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:intl/intl.dart';
import 'package:shoptempdb/widgets/update_shippingAddress_dialog.dart';

//import 'package:shoptempdb/widgets/update_shippingAddress_dialog_test.dart';
import 'package:flushbar/flushbar.dart';

import '../base_state.dart';

class ShippingAddressScreen extends StatefulWidget {
  static const routeName = '/shipping_address';

  @override
  _ShippingAddressScreenState createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends BaseState<ShippingAddressScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AddressItem selectedAddress;
  String selectedAddressId;
  DateTime date = DateTime.now();
  final format = DateFormat('yyyy-MM-dd');
  var _isInit = true;
  var _isLoading = false;
  Map<String, dynamic> product;

//  FormData data;

//  @override
//  void initState() {
//    super.initState();
//    data = FormData();
//  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });
      getDeliveryCharge();
      Provider.of<ShippingAddress>(context).fetchShippingAddress().then((_) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  setSelectedAddress(AddressItem address) {
    setState(() {
      selectedAddress = address;
      selectedAddressId = address.id;
    });
  }

  getDeliveryCharge() async {
    final cart = await Provider.of<Cart>(context, listen: false);
    Map<String, dynamic> data = Map();
    data.putIfAbsent('amount', () => cart.totalAmount.toDouble());
    FormData formData = FormData.fromMap(data);
    var response = await Provider.of<Products>(context, listen: false)
        .fetchDeliveryCharge(formData);
    if (response != null) {
      setState(() {
        product = response['data']['product'];
      });
    }
  }

  List<Widget> createRadioListUsers(List<AddressItem> address) {
    var innerBorder =
        Border.all(width: 1.0, color: Colors.grey.withOpacity(0.3));
    var outerBorder = Border.all(width: 3.0, color: Colors.grey.withOpacity(0));
    List<Widget> widgets = [];
    for (AddressItem data in address) {
      widgets.add(Padding(
        padding: const EdgeInsets.all(0.0),
        child: Container(
            decoration: BoxDecoration(
                border: outerBorder, borderRadius: BorderRadius.circular(16)),
            child: Container(
              decoration: BoxDecoration(
                  border: innerBorder, borderRadius: BorderRadius.circular(16)),
              child: Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Theme.of(context).errorColor,
                    child: Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 40,
                    ),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.only(right: 20),
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                  ),
                  confirmDismiss: (direction) {
                    return showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) => AlertDialog(
                              title: Text('Are you sure?'),
                              content:
                                  Text('Do you want to remove this address?'),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('No'),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                ),
                                FlatButton(
                                  child: Text('Yes'),
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                ),
                              ],
                            ));
                  },
                  onDismissed: (direction) async {
                    if (!mounted) return;
                    setState(() {
                      _isLoading = true;
                    });
                    await Provider.of<ShippingAddress>(context, listen: false)
                        .deleteShippingAddress(data.id);
                    if (!mounted) return;
                    setState(() {
                      _isInit = true;
                      _isLoading = false;
                    });
                  },
                  child: ListTile(
                    title: RadioListTile(
                      value: data,
                      groupValue: selectedAddress,
                      title: Text(data.shippingAddress),
                      subtitle: Text(data.phoneNumber),
                      onChanged: (currentAddress) {
                        print("New address ${currentAddress.id}");
                        setSelectedAddress(currentAddress);
                      },
                      selected: selectedAddress == data,
                      activeColor: Colors.green,
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () async {
//                        await showDialog(
//                            context: context,
//                            child: TestWidget(
//                              addressItem: data,
//                            ));
                        await showDialog(
                            context: context,
                            barrierDismissible: false,
                            child: UpdateShippingAddressDialog(
                              addressItem: data,
                            ));
                        if (!mounted) return;
                        setState(() {
                          _isInit = true;
                        });
                      },
                    ),
                  )),
            )

//              ListTile(
//                title: RadioListTile(
//                  value: data,
//                  groupValue: selectedAddress,
//                  title: Text(data.shippingAddress),
//                  subtitle: Text(data.phoneNumber),
//                  onChanged: (currentAddress) {
//                    print("New address ${currentAddress.id}");
//                    setSelectedAddress(currentAddress);
//                  },
//                  selected: selectedAddress == data,
//                  activeColor: Colors.green,
//                ),
//                trailing: IconButton(
//                  icon: Icon(Icons.edit),
//                  onPressed: () async {
//                    await showDialog(
//                        context: context,
//                        child: UpdateShippingAddressDialog(
//                          addressItem: data,
//                        ));
//                    if (!mounted) return;
//                    setState(() {
//                      _isInit = true;
//                    });
//                  },
//                ),
//              )),
            ),
      ));
    }
    return widgets;
  }

  Widget _snackBar(String text) {
    return SnackBar(
      backgroundColor: Theme.of(context).primaryColor,
      content: Container(
          padding: EdgeInsets.only(top: 5.0, bottom: 5.0), child: Text(text)),
      duration: Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
//    final shippingData = Provider.of<ShippingAddress>(context);
    final cart = ModalRoute.of(context).settings.arguments as Cart;
    return Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text('Confirm order'),
        ),
        drawer: AppDrawer(),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  children: <Widget>[
//               Container(
//                 height: 30.0,
//                 color: Colors.grey[300],
//                 child: Center(child: Text('Delivery date')),
//               ),
//               SizedBox(
//                 height: 5.0,
//               ),
//               Container(
//                 width: MediaQuery.of(context).size.width,
//                 height: 50.0,
// //                      padding: EdgeInsets.only(left: 5.0,right: 5.0),
//                 child: Row(
//                   children: <Widget>[
//                     Container(
//                         height: 48.0,
//                         width: MediaQuery.of(context).size.width * 1/5,
//                         color: Theme.of(context).primaryColor,
//                         child:IconButton(
//                           icon:Icon(Icons.date_range),
//                           color: Colors.white,
//                           onPressed: (){
//
//                           },
//                         )
//                     ),
//                     Container(
//                       width: MediaQuery.of(context).size.width * 4/5,
//                       child: DateTimeField(
//                         textAlign: TextAlign.start,
//                         format: format,
//                         onChanged: (dt) {
//                           setState(() {
//                             date = dt;
//                           });
//                         },
//                         decoration: InputDecoration(
//
//                             labelText: 'Select date',
// //                        prefixIcon: Icon(
// //                          Icons.date_range,
// //                          color: Theme.of(context).primaryColorDark,
// //                        ),
//                             contentPadding:
//                             EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
//
//                             border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.horizontal(left: Radius.zero))
//                         ),
//                         onShowPicker: (context, currentValue) {
//                           return showDatePicker(
//                               context: context,
//                               firstDate: DateTime(1900),
//                               initialDate: currentValue ?? DateTime.now(),
//                               lastDate: DateTime(2100));
//                         },
//                       ),
//                     )
//                   ],
//                 ),
//               ),

                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      height: 30.0,
                      color: Colors.grey[300],
                      child: Center(child: Text('Previous delivery addresses')),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Consumer<ShippingAddress>(
                        builder: (context, shippingData, child) => Container(
                              height:
                                  MediaQuery.of(context).size.height * 1 / 2,
                              child: ListView(
                                children: createRadioListUsers(
                                    shippingData.allShippingAddress),
                              ),
//                          Consumer<ShippingAddress>(
//                        builder: (context, shippingData, child) => ListView(
//                          children: createRadioListUsers(
//                              shippingData.allShippingAddress),
//                        ),
//                      ),
                            )),
                    SizedBox(
                      height: 10.0,
                    ),
                    Container(
                      height: 40.0,
                      width: 160.0,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            side: BorderSide(color: Colors.grey)),
                        onPressed: () {
                          if (cart.items.length > 0) {
                            showDialog(
                                context: context,
                                barrierDismissible: false,
                                child: CreateShippingAddressDialog(cart: cart));
                          } else {
                            _scaffoldKey.currentState.showSnackBar(
                                _snackBar('Please add item to cart'));
                          }
                        },
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        child: Text("Add new address".toUpperCase(),
                            style: TextStyle(fontSize: 14)),
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    Container(
                      height: 40.0,
                      width: 150.0,
                      child: RaisedButton(
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        child: Text("CONFIRM ORDER".toUpperCase(),
                            style: TextStyle(fontSize: 14)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            side: BorderSide(color: Colors.grey)),
                        onPressed: () async {
                          FocusScope.of(context).requestFocus(new FocusNode());
                          // cart.addItem(
                          // cartData.items[i].productId, cartData.items[i].title,
                          // cartData.items[i].price,cartData.items[i].isNonInventory,
                          // cartData.items[i].discount,cartData.items[i].discountId,
                          // cartData.items[i].discountType);

                          if (product != null) {
                            await cart.addItem(
                                product['id'].toString(),
                                product['name'],
                                product['unit_price'].toDouble(),
                                product['is_non_inventory'],
                                product['discount'] != null ? product['discount'] : 0.0,
                                product['discount_id'],
                                product['discount_type']);
                          }
                          Future.delayed(Duration(milliseconds: 500), () async {
                            if (cart.items.length > 0) {
                              List<Cart> ct = [];
                              ct = cart.items.map((e) => Cart(id: e.id, cartItem: e)).toList();
                              Map<String, dynamic> data = Map();
                              for (int i = 0; i < ct.length; i++) {
                                data.putIfAbsent('product_id[$i]', () => ct[i].cartItem.productId);
                                data.putIfAbsent('quantity[$i]', () => ct[i].cartItem.quantity);
                                data.putIfAbsent('unit_price[$i]', () => ct[i].cartItem.price);
                                data.putIfAbsent('is_non_inventory[$i]', () => ct[i].cartItem.isNonInventory);
                                data.putIfAbsent('discount[$i]', () => ct[i].cartItem.discount);
                              }
                              data.putIfAbsent('customer_shipping_address_id', () => selectedAddressId);
                              FormData formData = FormData.fromMap(data);

                              if (selectedAddressId != null) {
                                setState(() {
                                  _isLoading = true;
                                });
                                final response = await Provider.of<Orders>(context, listen: false).addOrder(formData);
                                if (response != null) {
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  await cart.clearCartTable();
                                  Navigator.of(context).pushNamed(ProductsOverviewScreen.routeName);
                                  Flushbar(
                                    duration: Duration(seconds: 10),
                                    margin: EdgeInsets.only(bottom: 2),
                                    padding: EdgeInsets.all(10),
                                    borderRadius: 8,
                                    backgroundColor: Colors.green.shade400,
                                    boxShadows: [
                                      BoxShadow(
                                        color: Colors.black45,
                                        offset: Offset(3, 3),
                                        blurRadius: 3,
                                      ),
                                    ],
                                    // All of the previous Flushbars could be dismissed by swiping down
                                    // now we want to swipe to the sides
                                    dismissDirection:
                                        FlushbarDismissDirection.HORIZONTAL,
                                    // The default curve is Curves.easeOut
                                    forwardAnimationCurve:
                                        Curves.fastLinearToSlowEaseIn,
                                    title: 'Order confirmation',
                                    message: response['msg'],
                                    mainButton: FlatButton(
                                      child: Text('view order'),
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pushNamed(OrdersScreen.routeName);
                                      },
                                    ),
                                  )..show(context);
//                          showDialog(
//                              context: context,
//                              barrierDismissible: false,
//                              builder: (ctx) => AlertDialog(
//                                title: Text('Order confirmation'),
//                                content: Text(response['msg']),
//                                actions: <Widget>[
//                                  FlatButton(
//                                    child: Text('view order'),
//                                    onPressed: () {
//                                      Navigator.of(context).pushNamed(
//                                          OrdersScreen.routeName);
//                                    },
//                                  ),
//                                  FlatButton(
//                                    child: Text('create another'),
//                                    onPressed: () {
//                                      Navigator.of(context).pushNamed(
//                                          ProductsOverviewScreen
//                                              .routeName);
//                                    },
//                                  )
//                                ],
//                              ));
                                } else {
                                  await cart.removeCartItemRow('1');
                                  setState(() {
                                    _isLoading = false;
                                  });
                                  Flushbar(
                                    duration: Duration(seconds: 5),
                                    margin: EdgeInsets.only(bottom: 2),
                                    padding: EdgeInsets.all(10),
                                    borderRadius: 8,
                                    backgroundColor: Colors.red.shade400,
                                    boxShadows: [
                                      BoxShadow(
                                        color: Colors.black45,
                                        offset: Offset(3, 3),
                                        blurRadius: 3,
                                      ),
                                    ],
                                    dismissDirection:
                                        FlushbarDismissDirection.HORIZONTAL,
                                    forwardAnimationCurve:
                                        Curves.fastLinearToSlowEaseIn,
                                    title: 'Order confirmation',
                                    message:
                                        'Something wrong. Please try again',
                                  )..show(context);
                                }
                              } else {
                                _scaffoldKey.currentState.showSnackBar(_snackBar(
                                    'Please select a delivery address or create new one'));
                              }
                            } else {
                              _scaffoldKey.currentState.showSnackBar(
                                  _snackBar('Please add item to cart'));
                            }
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ));
  }
}
