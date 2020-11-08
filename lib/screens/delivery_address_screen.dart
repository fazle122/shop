import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/orders.dart';
import 'package:shoptempdb/providers/product.dart';
import 'package:shoptempdb/providers/products.dart';
import 'package:shoptempdb/providers/shipping_address.dart';
import 'package:shoptempdb/screens/confirm_order_screen.dart';
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

class DeliveryAddressScreen extends StatefulWidget {
  static const routeName = '/delivery_address';

  @override
  _DeliveryAddressScreenState createState() => _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends BaseState<DeliveryAddressScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  AddressItem selectedAddress;
  String selectedAddressId;
  DateTime date = DateTime.now();
  final format = DateFormat('yyyy-MM-dd');
  var _isInit = true;
  var _isLoading = false;
  Map<String, dynamic> product;

  DateTime _deliveryDate;
  TimeOfDay currentTime = TimeOfDay.now();
  // final format = DateFormat('yyyy-MM-dd');
  final timeFormat = DateFormat("HH:mm");
  TextEditingController _noteController  = TextEditingController();
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
    var innerBorder = Border.all(width: 2.0, color: Colors.black.withOpacity(0.3));
    var outerBorder = Border.all(width: 2.0, color: Colors.black.withOpacity(0));
    List<Widget> widgets = [];
    for (AddressItem data in address) {
      widgets.add(
          Padding(
        padding: const EdgeInsets.all(0.0),
        child: Container(
            decoration: BoxDecoration(
                border: outerBorder, borderRadius: BorderRadius.circular(0.0)),
            child: Container(
              decoration: BoxDecoration(
                  border: innerBorder, borderRadius: BorderRadius.circular(0.0)),
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
                      // subtitle: Text(data.phoneNumber),
                      onChanged: (currentAddress) {
                        print("New address ${currentAddress.id}");
                        setSelectedAddress(currentAddress);
                      },
                      selected: selectedAddress == data,
                      activeColor: Colors.green,
                    ),
                    trailing: InkWell(
                      child: Text('Edit',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
                      // icon: Icon(Icons.edit),
                      onTap: () async {
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
          title: Text('Choose address'),
        ),
        drawer: AppDrawer(),
        body: _isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[

                    Container(
                      height: MediaQuery.of(context).size.height * .5 / 6,
                      padding: EdgeInsets.only(left:10.0),
                      child: Row(
                        children: <Widget>[
                          Icon(Icons.add_location),
                          Text('Select Delivery Address',style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),),
                        ],
                      ),
                      // child:  Text('Select Delivery Address'),
                    ),

                    Consumer<ShippingAddress>(
                        builder: (context, shippingData, child) =>
                            Container(
                              padding: EdgeInsets.only(left: 10.0,right: 10.0),
                              height: MediaQuery.of(context).size.height * 1.5 / 6,
                              child: ListView(
                                children: createRadioListUsers(
                                    shippingData.allShippingAddress),
                              ),
                            )),

                    Container(
                        margin: EdgeInsets.only(left: 12.0,top: 20.0,bottom: 20.0),
                        height: MediaQuery.of(context).size.height * .4/ 6,
                        width: 160.0,
                        child: Column(
                          children: <Widget>[
                            MaterialButton(
                              height: 40.0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(0.0),
                                  side: BorderSide(color: Colors.black)),
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
                              textColor: Colors.black,
                              child: Row(
                                children: <Widget>[
                                  Icon(Icons.add_circle_outline),
                                  SizedBox(width: 10.0,),
                                  Text('New Address',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 15.0),)
                                ],
                              ),
                              // color: Theme.of(context).primaryColor,
                              // child: Text("Add new address".toUpperCase(),
                              //     style: TextStyle(fontSize: 14)),
                            ),
                          ],
                        )
                      ),


                    SizedBox(height: 10.0,),
                    Padding(
                      padding: EdgeInsets.only(left: 20.0),
                      child:Text('Preferred delivery date & time'),

                    ),
                    Container(
                      height: 100.0,
                      child: Card(
                          margin: EdgeInsets.all(10.0),
                          child:
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: <Widget>[
                              Container(
                                width:MediaQuery.of(context).size.width * 1.35/3,
                                height: 40.0,
                                child: DateTimeField(
                                  textAlign: TextAlign.start,
                                  format: format,
                                  onChanged: (dt) {
                                    setState(() {
                                      _deliveryDate = dt;
                                    });
                                  },
                                  decoration: InputDecoration(
                                      labelText: 'Select date',
                                      suffixIcon: Icon(
                                        Icons.arrow_drop_down,
                                        size: 40.0,
                                        color: Colors.grey,
                                      ),
                                      contentPadding:
                                      EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(2.0))),
                                  onShowPicker: (context, currentValue) {
                                    return showDatePicker(
                                        context: context,
                                        firstDate: DateTime(1900),
                                        initialDate: currentValue ?? DateTime.now(),
                                        lastDate: DateTime(2100));
                                  },
                                ),
                              ),
                              Container(
                                width:MediaQuery.of(context).size.width * 1.35/3,
                                height: 40.0,
                                child:
                                DateTimeField(
                                  format: timeFormat,
                                  decoration: InputDecoration(
                                      labelText: 'Select time',
                                      suffixIcon: Icon(
                                        Icons.arrow_drop_down,
                                        size: 40.0,
                                        color: Colors.grey,
                                      ),
                                      contentPadding:
                                      EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(2.0))),
                                  onShowPicker: (context, currentValue) async {
                                    final time = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                                      builder: (context, child) => MediaQuery(
                                          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
                                          child: child),
                                    );
                                    return DateTimeField.convert(time);
                                  },
                                ),
                              )
                            ],
                          )
                      ),
                    ),

                    SizedBox(height: 10.0,),
                    Padding(
                      padding: EdgeInsets.only(left: 20.0),
                      child:Text('Add order note'),

                    ),

                    Container(
                      height: 100.0,
                      child:Card(
                          margin: EdgeInsets.all(10.0),
                          child: TextFormField(

                            textAlign: TextAlign.left,
                            controller: _noteController,
                            minLines: 3,
                            maxLines: 5,
                            keyboardType: TextInputType.text,
                            decoration: new InputDecoration(
                                hintText: 'Add a note',
                              contentPadding: EdgeInsets.all(10.0),
                              border: InputBorder.none
                              

                            ),
                          )
                      )

                    ),

                    InkWell(
                      child: Container(
                          height: 50.0,
                          color: Theme.of(context).primaryColor,
                          child: Row(
                            children: <Widget>[
                              Container(
                                  width: MediaQuery.of(context).size.width * 5/7,
                                  padding:
                                  EdgeInsets.only(left: 20.0, top: 2.0),
                                  color: Color(0xffFB0084),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                    MainAxisAlignment.center,
                                    children: <Widget>[
                                      Text(' Confirm order',style: TextStyle(fontSize:18.0,fontWeight: FontWeight.bold,color: Colors.white),)
                                    ],
                                  )),
                              Container(
                                height: MediaQuery.of(context).size.height,
                                width:
                                MediaQuery.of(context).size.width * 2 / 7,
                                color: Color(0xffB40060),
                                child: InkWell(
                                  child: Center(
                                    // child: Text('Check out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                                    child: Text((cart.totalAmount + cart.deliveryCharge).toStringAsFixed(2) + ' BDT',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                                  ),
                                  onTap: () {

                                  },
                                ),
                              ),
                            ],
                          )),
                      onTap: (){
                        Navigator.pushNamed(context, ConfirmOrderScreen.routeName);
                      },
                    )
//                     Container(
//                       height: 40.0,
//                       width: 150.0,
//                       child: RaisedButton(
//                         color: Theme.of(context).primaryColor,
//                         textColor: Colors.white,
//                         child: Text("CONFIRM ORDER".toUpperCase(),
//                             style: TextStyle(fontSize: 14)),
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(25.0),
//                             side: BorderSide(color: Colors.grey)),
//                         onPressed: () async {
//                           FocusScope.of(context).requestFocus(new FocusNode());
//                           // cart.addItem(
//                           // cartData.items[i].productId, cartData.items[i].title,
//                           // cartData.items[i].price,cartData.items[i].isNonInventory,
//                           // cartData.items[i].discount,cartData.items[i].discountId,
//                           // cartData.items[i].discountType);
//
//                           if (product != null) {
//                             await cart.addItem(
//                                 product['id'].toString(),
//                                 product['name'],
//                                 product['unit_price'].toDouble(),
//                                 product['is_non_inventory'],
//                                 product['discount'] != null ? product['discount'] : 0.0,
//                                 product['discount_id'],
//                                 product['discount_type']);
//                           }
//                           Future.delayed(Duration(milliseconds: 500), () async {
//                             if (cart.items.length > 0) {
//                               List<Cart> ct = [];
//                               ct = cart.items.map((e) => Cart(id: e.id, cartItem: e)).toList();
//                               Map<String, dynamic> data = Map();
//                               for (int i = 0; i < ct.length; i++) {
//                                 data.putIfAbsent('product_id[$i]', () => ct[i].cartItem.productId);
//                                 data.putIfAbsent('quantity[$i]', () => ct[i].cartItem.quantity);
//                                 data.putIfAbsent('unit_price[$i]', () => ct[i].cartItem.price);
//                                 data.putIfAbsent('is_non_inventory[$i]', () => ct[i].cartItem.isNonInventory);
//                                 data.putIfAbsent('discount[$i]', () => ct[i].cartItem.discount);
//                               }
//                               data.putIfAbsent('customer_shipping_address_id', () => selectedAddressId);
//                               FormData formData = FormData.fromMap(data);
//
//                               if (selectedAddressId != null) {
//                                 setState(() {
//                                   _isLoading = true;
//                                 });
//                                 final response = await Provider.of<Orders>(context, listen: false).addOrder(formData);
//                                 if (response != null) {
//                                   setState(() {
//                                     _isLoading = false;
//                                   });
//                                   await cart.clearCartTable();
//                                   Navigator.of(context).pushNamed(ProductsOverviewScreen.routeName);
//                                   Flushbar(
//                                     duration: Duration(seconds: 10),
//                                     margin: EdgeInsets.only(bottom: 2),
//                                     padding: EdgeInsets.all(10),
//                                     borderRadius: 8,
//                                     backgroundColor: Colors.green.shade400,
//                                     boxShadows: [
//                                       BoxShadow(
//                                         color: Colors.black45,
//                                         offset: Offset(3, 3),
//                                         blurRadius: 3,
//                                       ),
//                                     ],
//                                     // All of the previous Flushbars could be dismissed by swiping down
//                                     // now we want to swipe to the sides
//                                     dismissDirection:
//                                         FlushbarDismissDirection.HORIZONTAL,
//                                     // The default curve is Curves.easeOut
//                                     forwardAnimationCurve:
//                                         Curves.fastLinearToSlowEaseIn,
//                                     title: 'Order confirmation',
//                                     message: response['msg'],
//                                     mainButton: FlatButton(
//                                       child: Text('view order'),
//                                       onPressed: () {
//                                         Navigator.of(context)
//                                             .pushNamed(OrdersScreen.routeName);
//                                       },
//                                     ),
//                                   )..show(context);
// //                          showDialog(
// //                              context: context,
// //                              barrierDismissible: false,
// //                              builder: (ctx) => AlertDialog(
// //                                title: Text('Order confirmation'),
// //                                content: Text(response['msg']),
// //                                actions: <Widget>[
// //                                  FlatButton(
// //                                    child: Text('view order'),
// //                                    onPressed: () {
// //                                      Navigator.of(context).pushNamed(
// //                                          OrdersScreen.routeName);
// //                                    },
// //                                  ),
// //                                  FlatButton(
// //                                    child: Text('create another'),
// //                                    onPressed: () {
// //                                      Navigator.of(context).pushNamed(
// //                                          ProductsOverviewScreen
// //                                              .routeName);
// //                                    },
// //                                  )
// //                                ],
// //                              ));
//                                 } else {
//                                   await cart.removeCartItemRow('1');
//                                   setState(() {
//                                     _isLoading = false;
//                                   });
//                                   Flushbar(
//                                     duration: Duration(seconds: 5),
//                                     margin: EdgeInsets.only(bottom: 2),
//                                     padding: EdgeInsets.all(10),
//                                     borderRadius: 8,
//                                     backgroundColor: Colors.red.shade400,
//                                     boxShadows: [
//                                       BoxShadow(
//                                         color: Colors.black45,
//                                         offset: Offset(3, 3),
//                                         blurRadius: 3,
//                                       ),
//                                     ],
//                                     dismissDirection:
//                                         FlushbarDismissDirection.HORIZONTAL,
//                                     forwardAnimationCurve:
//                                         Curves.fastLinearToSlowEaseIn,
//                                     title: 'Order confirmation',
//                                     message:
//                                         'Something wrong. Please try again',
//                                   )..show(context);
//                                 }
//                               } else {
//                                 _scaffoldKey.currentState.showSnackBar(_snackBar(
//                                     'Please select a delivery address or create new one'));
//                               }
//                             } else {
//                               _scaffoldKey.currentState.showSnackBar(
//                                   _snackBar('Please add item to cart'));
//                             }
//                           });
//                         },
//                       ),
//                     ),
                  ],
                ),
              ));
  }
}
