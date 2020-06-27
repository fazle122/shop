import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/orders.dart';
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

  @override
  void didChangeDependencies() {
    if (_isInit) {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });
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
                        builder: (context) => AlertDialog(
                              title: Text('Are you sure?'),
                              content:
                                  Text('Do you want to cancel this order?'),
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
//                        Navigator.pushReplacement(context, MaterialPageRoute(
//                          builder: (context) => TestWidget(addressItem: data,)
//                        ));
                        await showDialog(
                            context: context,
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
                    Container(
                      height: 30.0,
                      color: Colors.grey[300],
                      child: Center(child: Text('Delivery date')),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: 50.0,
//                      padding: EdgeInsets.only(left: 5.0,right: 5.0),
                      child: Row(
                        children: <Widget>[
                          Container(
                            height: 48.0,
                              width: MediaQuery.of(context).size.width * 1/5,
                            color: Theme.of(context).primaryColor,
                            child:IconButton(
                              icon:Icon(Icons.date_range),
                              color: Colors.white,
                              onPressed: (){

                              },
                            )
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width * 4/5,
                            child: DateTimeField(
                              textAlign: TextAlign.start,
                              format: format,
                              onChanged: (dt) {
                                setState(() {
                                  date = dt;
                                });
                              },
                              decoration: InputDecoration(

                                  labelText: 'Select date',
//                        prefixIcon: Icon(
//                          Icons.date_range,
//                          color: Theme.of(context).primaryColorDark,
//                        ),
                                  contentPadding:
                                  EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),

                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.horizontal(left: Radius.zero))
                              ),
                              onShowPicker: (context, currentValue) {
                                return showDatePicker(
                                    context: context,
                                    firstDate: DateTime(1900),
                                    initialDate: currentValue ?? DateTime.now(),
                                    lastDate: DateTime(2100));
                              },
                            ),
                          )
                        ],
                      ),
                    ),


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
                              height: 300.0,
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
                      width: 150.0,
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            side: BorderSide(color: Colors.grey)),
                        onPressed: () {
                          if(cart.items.length > 0) {
                            showDialog(
                                context: context,
                                child: CreateShippingAddressDialog(cart: cart));
                          }else{
                            _scaffoldKey.currentState.showSnackBar(_snackBar('Please add item to cart'));
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
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            side: BorderSide(color: Colors.grey)),
                        onPressed: () async {
                          if (cart.items.length > 0) {
                            FormData data = new FormData();
                            List<Cart> ct = [];
                            ct = cart.items.entries
                                .map((e) => Cart(id: e.key, cartItem: e.value))
                                .toList();

                            for (int i = 0; i < ct.length; i++) {
                              data.add('product_id[$i]', ct[i].cartItem.id);
                              data.add('quantity[$i]', ct[i].cartItem.quantity);
                              data.add('unit_price[$i]', ct[i].cartItem.price);
                              data.add('is_non_inventory[$i]',
                                  ct[i].cartItem.isNonInventory);
                              data.add('discount[$i]', ct[i].cartItem.discount);
                            }
                            data.add('customer_shipping_address_id',
                                selectedAddressId);
                            if (selectedAddressId != null) {
                              setState(() {
                                _isLoading = true;
                              });
                              final response = await Provider.of<Orders>(
                                      context,
                                      listen: false)
                                  .addOrder(data);
                              if (response != null) {
                                setState(() {
                                  _isLoading = false;
                                });
                                cart.clear();
//                    _scaffoldKey.currentState.showSnackBar(_snackBar(response['msg']));
//                    Navigator.of(context).pushNamed(ProductsOverviewScreen.routeName);
                                showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                          title: Text('Order confirmation'),
                                          content: Text(response['msg']),
                                          actions: <Widget>[
                                            FlatButton(
                                              child: Text('view order'),
                                              onPressed: () {
                                                Navigator.of(context).pushNamed(
                                                    OrdersScreen.routeName);
                                              },
                                            ),
                                            FlatButton(
                                              child: Text('create another'),
                                              onPressed: () {
                                                Navigator.of(context).pushNamed(
                                                    ProductsOverviewScreen
                                                        .routeName);
                                              },
                                            )
                                          ],
                                        ));
                              } else {
                                _scaffoldKey.currentState.showSnackBar(
                                    _snackBar(
                                        'Something wrong!!! Please try again'));
                              }
                            } else {
                              _scaffoldKey.currentState.showSnackBar(_snackBar(
                                  'Please select a delivery address or create new one'));
                            }
                          }else{
                            _scaffoldKey.currentState.showSnackBar(_snackBar('Please add item to cart'));
                          }
                        },
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        child: Text("CONFIRM ORDER".toUpperCase(),
                            style: TextStyle(fontSize: 14)),
                      ),
                    ),
                  ],
                ),
              ));
  }
}
