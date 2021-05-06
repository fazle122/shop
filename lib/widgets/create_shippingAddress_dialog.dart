import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/products.dart';
import 'package:shoptempdb/providers/shipping_address.dart';
import 'package:dio/dio.dart';
import 'package:shoptempdb/widgets/dropdown_widget.dart';
import 'package:toast/toast.dart';
import 'package:velocity_x/velocity_x.dart';




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

  String selectedArea;
  String selectedDistrict;

  var _isInit = true;
  var _isLoading = false;
  String mobileNumber;
  String homeAddress;
  Map<String, dynamic> product;



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
    // Future.delayed(Duration(milliseconds: 500), () async {
      if (cart.items.length > 0) {
        List<Cart> ct = [];
        ct = cart.items.map((e) => Cart(id: e.id, cartItem: e)).toList();

        Map<String,dynamic> dt = Map();
        dt.putIfAbsent('city',()=>shippingAddress.selectedDistrict);
        dt.putIfAbsent('area_id', ()=>shippingAddress.selectedArea.toString());
        dt.putIfAbsent('shipping_address_line', ()=>homeAddress);
        dt.putIfAbsent('mobile_no', ()=>mobileNumber);

        //// shippingAddress.selectedDistrict = null;
        //// shippingAddress.selectedArea = null;
        //// Navigator.of(context).pop(dt);


        ///new code///
        var response = await Provider.of<ShippingAddress>(context, listen: false).createShippingAddress(
          shippingAddress.selectedArea.toString(),
          shippingAddress.selectedDistrict,
          homeAddress,
          mobileNumber,
        );
        if(response != null){
          var id = response['data']['customer_shipping_address']['id'];
          shippingAddress.selectedDistrict = null;
          shippingAddress.selectedArea = null;
          Navigator.of(context).pop(id);
        }else{
          // Toast.show('Something went wrong, please try again', context,gravity: Toast.BOTTOM,duration: Toast.LENGTH_LONG);
          context.showToast(
            msg: 'Something went wrong, please try again.',
            showTime: 5000,
            position: VxToastPosition.bottom,
            bgColor: Colors.red,
            textColor: Colors.white,

          );
        }

        /// end ///

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
                  districtDropdown(shippingAddress,shippingAddress.allDistricts),
                  // DropdownWidget(
                  //   icon: Icons.location_city,
                  //   items: shippingAddress.allDistricts,
                  //   itemCallBack: (String value) {
                  //     shippingAddress.selectedDistrict = value;
                  //     shippingAddress.selectedArea = null;
                  //   },
                  //   currentItem: shippingAddress.selectedDistrict,
                  //   errorMessage: 'please choose district',
                  //   hintText: 'Select district',),
                  SizedBox(
                    height: 15.0,
                  ),
                  areaDropdown(shippingAddress,shippingAddress.allAreas),
                  // DropdownWidget(
                  //   icon: Icons.local_gas_station,
                  //   items: shippingAddress.allAreas,
                  //   itemCallBack: (String value) {
                  //     shippingAddress.selectedArea = value;
                  //   },
                  //   currentItem: shippingAddress.selectedArea,
                  //   errorMessage: 'please choose area',
                  //   hintText: 'Select area',),
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
                      color: Theme.of(context).primaryColor,
                      textColor: Colors.white,
                      child: Text("Confirm".toUpperCase(),
                          style: TextStyle(fontSize: 14)),
                      onPressed: () async{
                        FocusScope.of(context).requestFocus(new FocusNode());
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
      },
    );
  }
}

