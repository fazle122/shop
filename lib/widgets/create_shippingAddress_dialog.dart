import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/orders.dart';
import 'package:shoptempdb/providers/products.dart';
import 'package:shoptempdb/providers/shipping_address.dart';
import 'package:dio/dio.dart';
import 'package:shoptempdb/screens/orders_screen.dart';
import 'package:shoptempdb/screens/products_overview_screen.dart';
import 'package:flushbar/flushbar.dart';




class CreateShippingAddressDialog extends StatefulWidget {
  final Cart cart;

  CreateShippingAddressDialog({this.cart});

  @override
  _CreateShippingAddressDialogState createState() =>
      _CreateShippingAddressDialogState();
}

class _CreateShippingAddressDialogState
    extends State<CreateShippingAddressDialog> {
  final _form = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController _phoneEditController;
  TextEditingController _addressEditController;
  String selectedArea;
  String selectedDistrict;

  var _isInit = true;
  var _isLoading = false;
  String mobileNumber;
  String homeAddress;
  Map<String, dynamic> product;


  @override
  void initState() {
    _phoneEditController = TextEditingController();
    _addressEditController = TextEditingController();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });
      getDeliveryCharge();
      Provider.of<ShippingAddress>(context).fetchDistrictList().then((_) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
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


  Widget phoneField() {
    return TextFormField(
      autofocus: true,
      keyboardType: TextInputType.number,
//      controller: _phoneEditController,
      validator: (value) {
        if (value.isEmpty) {
          return 'please enter mobile number';
        }else if(value.length > 11 || value.length < 11){
          return 'please provide a valid mobile number';
        }
        return null;
      },
      onSaved: (value) {
        mobileNumber = value;
      },
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.phone_android,
          color: Theme.of(context).primaryColorDark,
        ),
        hintText: 'Mobile number',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
  }

  Widget addressField() {
    return TextFormField(
      autofocus: false,
      keyboardType: TextInputType.multiline,
      maxLines: 2,
//      controller: _addressEditController,
      validator: (value) {
        if (value.isEmpty) {
          return 'please enter your home address';
        }
        return null;
      },
      onSaved: (value){
        homeAddress = value;
      },
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.home,
          color: Theme.of(context).primaryColorDark,
        ),
        hintText: 'Home address',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
  }

  Future<void> _saveForm(var shippingAddress,Cart cart) async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    // if (product != null) {
    //   await cart.addItem(
    //       product['id'].toString(),
    //       product['name'],
    //       product['unit_price'].toDouble(),
    //       product['is_non_inventory'],
    //       product['discount'] != null ? product['discount'] : 0.0,
    //       product['discount_id'],
    //       product['discount_type']);
    // }
    // Future.delayed(Duration(milliseconds: 500), () async {
      if (cart.items.length > 0) {
        List<Cart> ct = [];
        ct = cart.items.map((e) => Cart(id: e.id, cartItem: e)).toList();

        Map<String,dynamic> dt = Map();
        for (int i = 0; i < ct.length; i++) {
          dt.putIfAbsent('product_id[$i]', ()=>ct[i].cartItem.productId);
          dt.putIfAbsent('quantity[$i]', ()=>ct[i].cartItem.quantity);
          dt.putIfAbsent('unit_price[$i]', ()=>ct[i].cartItem.price);
          dt.putIfAbsent('is_non_inventory[$i]', ()=>ct[i].cartItem.isNonInventory);
          dt.putIfAbsent('discount[$i]', ()=>ct[i].cartItem.discount);
        }
        dt.putIfAbsent('city',()=>shippingAddress.selectedDistrict);
        dt.putIfAbsent('area_id', ()=>shippingAddress.selectedArea.toString());
        dt.putIfAbsent('shipping_address_line', ()=>homeAddress);
        dt.putIfAbsent('mobile_no', ()=>mobileNumber);

        FormData data = FormData.fromMap(dt);

        setState(() {
          _isLoading = true;
        });
        final response = await Provider.of<Orders>(context, listen: false).addOrder(data);
        if (response != null) {
          setState(() {
            _isLoading = false;
          });
          widget.cart.clearCartTable();
          shippingAddress.selectedDistrict = null;
          shippingAddress.selectedArea = null;
          Navigator.of(context).pushNamed(
              ProductsOverviewScreen
                  .routeName);
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
            dismissDirection: FlushbarDismissDirection.HORIZONTAL,
            // The default curve is Curves.easeOut
            forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
            title: 'Order confirmation',
            message: response['msg'],
            mainButton: FlatButton(
              child: Text('view order'),
              onPressed: () {
                Navigator.of(context).pushNamed(
                    OrdersScreen.routeName);
              },
            ),

          )..show(context);
//      showDialog(
////            useRootNavigator: false,
//          barrierDismissible: false,
//          context: context,
//          builder: (ctx) => AlertDialog(
//            title: Text('Order confirmation'),
//            content: Text(response['msg']),
//            actions: <Widget>[
//              FlatButton(
//                child: Text('view order'),
//                onPressed: () {
//                  Navigator.of(context).pushNamed(
//                      OrdersScreen.routeName);
//                },
//              ),
//              FlatButton(
//                child: Text('create another'),
//                onPressed: () {
//                  Navigator.of(context).pushNamed(
//                      ProductsOverviewScreen
//                          .routeName);
//                },
//              )
//            ],
//          ));
        }
        else {
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
            dismissDirection: FlushbarDismissDirection.HORIZONTAL,
            forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
            title: 'Order confirmation',
            message: 'Something wrong. Please try again',
          )..show(context);
//      showDialog(
//          context: context,
//          barrierDismissible: false,
//          builder: (ctx) => AlertDialog(
//            title: Text('Order confirmation'),
//            content: Text(
//                'something went wrong!!! Please try again'),
//            actions: <Widget>[
//              FlatButton(
//                child: Text('ok'),
//                onPressed: () {
//                  Navigator.of(context).pushNamed(
//                      ProductsOverviewScreen
//                          .routeName);
//                },
//              ),
//            ],
//          ));
        }
      }else{
        _scaffoldKey.currentState.showSnackBar(
            _snackBar('Please add item to cart'));
      }
    // });

  }

  Widget _snackBar(String text) {
    return SnackBar(
      backgroundColor: Theme.of(context).primaryColor,
      content: Container(
          padding: EdgeInsets.only(top: 5.0, bottom: 5.0), child: Text(text)),
      duration: Duration(seconds: 2),
    );
  }

  Future<bool> _onBackPressed() {
    final shippingAddress = Provider.of<ShippingAddress>(context,listen: false);
    setState(() {
      shippingAddress.selectedDistrict = null;
    });
    Navigator.of(context).pop();

  }

  @override
  Widget build(BuildContext context) {
    final shippingAddress = Provider.of<ShippingAddress>(context);
    final cart = Provider.of<Cart>(context,listen: false);
    Map<String, dynamic> district = shippingAddress.allDistricts;
    Map<String, dynamic> areas = Map();
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: AlertDialog(
        title: Center(
          child: Text('Delivery Address'),
        ),
        content: SingleChildScrollView(
            child: _isLoading
                ? Center(
              child: CircularProgressIndicator(),
            )
                :
            Form(key:_form,
              child:Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  phoneField(),
                  SizedBox(
                    height: 15.0,
                  ),
//                  DistrictDropDown(),
                  districtDropdown(shippingAddress,shippingAddress.allDistricts),
                  SizedBox(
                    height: 15.0,
                  ),
//                  AreaDropDown(),
                  areaDropdown(shippingAddress,shippingAddress.allAreas),
                  SizedBox(
                    height: 15.0,
                  ),
                  addressField(),
                  SizedBox(
                    height: 25.0,
                  ),
                  Container(
                    child: RaisedButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                          side: BorderSide(color: Colors.grey)),

//                onPressed: () async {
//                  if (widget.cart.items.length <= 0) {
//                    print(shippingAddress.selectedDistrict);
//                    print(shippingAddress.selectedArea);
//                    print(_phoneEditController.text);
//                    print(_addressEditController.text);
//                    Provider.of<ShippingAddress>(context, listen: false)
//                        .createShippingAddress(
//                      shippingAddress.selectedArea.toString(),
//                      _addressEditController.text,
//                      _phoneEditController.text,
//                    );
//                    Navigator.of(context).pop();
//                  } else {
//                    FormData data = new FormData();
//                    List<Cart> ct = [];
//                    ct = widget.cart.items.entries
//                        .map((e) => Cart(id: e.key, cartItem: e.value))
//                        .toList();
//
//                    for (int i = 0; i < ct.length; i++) {
//                      data.add('product_id[$i]', ct[i].cartItem.id);
//                      data.add('quantity[$i]', ct[i].cartItem.quantity);
//                      data.add('unit_price[$i]', ct[i].cartItem.price);
//                      data.add('is_non_inventory[$i]',
//                          ct[i].cartItem.isNonInventory);
//                      data.add('discount[$i]', ct[i].cartItem.discount);
//                    }
//                    data.add('area_id',
//                        shippingAddress.selectedArea.toString());
//                    data.add('shipping_address_line',
//                        _addressEditController.text);
//                    data.add('mobile_no', _phoneEditController.text);
//
//                    if (shippingAddress.selectedArea == null ||
//                        _addressEditController.text == null ||
//                        _addressEditController.text == '' ||
//                        _addressEditController.text.isEmpty ||
//                        _phoneEditController.text == null ||
//                        _phoneEditController.text == '' ||
//                        _phoneEditController.text.isEmpty) {
//                      showDialog(
//                          context: context,
//                          builder: (ctx) => AlertDialog(
//                            title: Text('Required data confirmation'),
//                            content: Text(
//                                'Please provide all necessary data'),
//                            actions: <Widget>[
//                              FlatButton(
//                                child: Text('ok'),
//                                onPressed: () {
//                                  Navigator.of(context).pop();
//                                },
//                              ),
//                            ],
//                          ));
//                    } else {
//                      setState(() {
//                        _isLoading = true;
//                      });
//                      final response = await Provider.of<Orders>(context,
//                          listen: false)
//                          .addOrder(data);
//                      if (response != null) {
//                        setState(() {
//                          _isLoading = false;
//                        });
//                        widget.cart.clear();
//                        shippingAddress.selectedDistrict = null;
//                        shippingAddress.selectedArea = null;
//                        showDialog(
//                            context: context,
//                            builder: (ctx) => AlertDialog(
//                              title: Text('Order confirmation'),
//                              content: Text(response['msg']),
//                              actions: <Widget>[
//                                FlatButton(
//                                  child: Text('view order'),
//                                  onPressed: () {
//                                    Navigator.of(context).pushNamed(
//                                        OrdersScreen.routeName);
//                                  },
//                                ),
//                                FlatButton(
//                                  child: Text('create another'),
//                                  onPressed: () {
//                                    Navigator.of(context).pushNamed(
//                                        ProductsOverviewScreen
//                                            .routeName);
//                                  },
//                                )
//                              ],
//                            ));
//                      } else {
//                        showDialog(
//                            context: context,
//                            builder: (ctx) => AlertDialog(
//                              title: Text('Order confirmation'),
//                              content: Text(
//                                  'something went wrong!!! Please try again'),
//                              actions: <Widget>[
//                                FlatButton(
//                                  child: Text('ok'),
//                                  onPressed: () {
//                                    Navigator.of(context).pushNamed(
//                                        ProductsOverviewScreen
//                                            .routeName);
//                                  },
//                                ),
//                              ],
//                            ));
//                      }
//                    }
//                  }
//                },
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      child: Text("Confirm".toUpperCase(),
                          style: TextStyle(fontSize: 14)),
                      onPressed: () async{
                        FocusScope.of(context).requestFocus(new FocusNode());
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
                          await _saveForm(shippingAddress, cart);
                        });
                      },
                    ),
                  )
                ],
              ),)

        ),
      ),
    );
  }

  List<DropdownMenuItem> _districtMenuItems(Map<String, dynamic> items) {
    List<DropdownMenuItem> itemWidgets = List();
    items.forEach((key, value) {
      itemWidgets.add(DropdownMenuItem(
        value: value,
        child: Text(value),
      ));
    });
    return itemWidgets;
  }

  List<DropdownMenuItem> _areaMenuItems(Map<String, dynamic> items) {
    List<DropdownMenuItem> itemWidgets = List();
    items.forEach((key, value) {
      itemWidgets.add(DropdownMenuItem(
        value: key,
        child: Text(value),
      ));
    });
    return itemWidgets;
  }

  Widget districtDropdown(var shippingAddress,Map<String, dynamic> district){
    return Consumer<ShippingAddress>(
      builder: (
          final BuildContext context,
          final ShippingAddress address,
          final Widget child,
          ) {
        return DropdownButtonFormField(

          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.location_city,
              color: Theme.of(context).primaryColor,
            ),
            border: OutlineInputBorder(),
//                enabledBorder: UnderlineInputBorder(
//                    borderSide: BorderSide(color: Colors.white))
          ),
          hint: Text('Select district'),
          value: shippingAddress.selectedDistrict,
          onSaved: (value){
            shippingAddress.selectedDistrict = value;
          },
          validator: (value){
            if (value == null) {
              return 'please choose district';
            }
            return null;
          },
          onChanged: (newValue) {
            shippingAddress.selectedDistrict = newValue;
            shippingAddress.selectedArea = null;
          },
          items: _districtMenuItems(district),
        );
//        return Stack(
//          children: <Widget>[
//            Container(
//                decoration: ShapeDecoration(
//                  shape: RoundedRectangleBorder(
//                    side: BorderSide(width: 1.0, style: BorderStyle.solid),
//                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
//                  ),
//                ),
//                padding: EdgeInsets.only(left: 44.0, right: 10.0),
////              margin: EdgeInsets.only(left: 16.0, right: 16.0),
//                child: DropdownButtonFormField(
//
//                  isExpanded: true,
////                icon: Icon(Icons.location_city),
//                  hint: Text('Select district'),
//                  value: shippingAddress.selectedDistrict,
//                  onSaved: (value){
//                    shippingAddress.selectedDistrict = value;
//                  },
//                  validator: (value){
//                    if (value == null) {
//                      return 'please choose district';
//                    }
//                    return null;
//                  },
//                  onChanged: (newValue) {
//                    shippingAddress.selectedDistrict = newValue;
//                    shippingAddress.selectedArea = null;
//                  },
//                  items: _districtMenuItems(district),
//                )),
//            Container(
//              padding: EdgeInsets.only(top: 24.0, left: 12.0),
//              child: Icon(
//                Icons.location_city,
//                color: Theme.of(context).primaryColor,
////              size: 20.0,
//              ),
//            ),
//          ],
//        );
      },
    );
  }

  Widget areaDropdown(var shippingAddress,Map<String, dynamic> areas){
    return Consumer<ShippingAddress>(
      builder: (
          final BuildContext context,
          final ShippingAddress address,
          final Widget child,
          ) {
        return DropdownButtonFormField(
          isExpanded: true,
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.local_gas_station,
              color: Theme.of(context).primaryColor,
            ),
            border: OutlineInputBorder(),
//                enabledBorder: UnderlineInputBorder(
//                    borderSide: BorderSide(color: Colors.white))
          ),
          hint: Text('Select area'),
          value: shippingAddress.selectedArea,
          onSaved: (value){
            shippingAddress.selectedArea = value;

          },
          validator: (value){
            if (value == null) {
              return 'please choose area';
            }
            return null;
          },
          onChanged: (newValue) {
            shippingAddress.selectedArea = newValue;
          },
          items: _areaMenuItems(areas),
        );
//        return Stack(
//          children: <Widget>[
//            Container(
//                decoration: ShapeDecoration(
//                  shape: RoundedRectangleBorder(
//                    side: BorderSide(width: 1.0, style: BorderStyle.solid),
//                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
//                  ),
//                ),
//                padding: EdgeInsets.only(left: 44.0, right: 10.0),
////              margin: EdgeInsets.only(left: 16.0, right: 16.0),
//                child: DropdownButtonFormField(
//                  isExpanded: true,
////                icon: Icon(Icons.local_gas_station),
//                  hint: Text('Select area'),
//                  value: shippingAddress.selectedArea,
//                  onSaved: (value){
//                    shippingAddress.selectedArea = value;
//
//                  },
//                  validator: (value){
//                    if (value == null) {
//                      return 'please choose area';
//                    }
//                    return null;
//                  },
//                  onChanged: (newValue) {
//                    shippingAddress.selectedArea = newValue;
//                  },
//                  items: _areaMenuItems(areas),
//                )),
//            Container(
//              margin: EdgeInsets.only(top: 24.0, left: 12.0),
//              child: Icon(
//                Icons.local_gas_station,
//                color: Theme.of(context).primaryColor,
////              size: 20.0,
//              ),
//            ),
//          ],
//        );
      },
    );
  }
}

