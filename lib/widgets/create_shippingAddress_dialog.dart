import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/orders.dart';
import 'package:shoptempdb/providers/shipping_address.dart';
import 'package:dio/dio.dart';
import 'package:shoptempdb/screens/products_overview_screen.dart';


class CreateShippingAddressDialog extends StatefulWidget {
  final Cart cart;
  CreateShippingAddressDialog({this.cart});

  @override
  _CreateShippingAddressDialogState createState() => _CreateShippingAddressDialogState();
}

class _CreateShippingAddressDialogState extends State<CreateShippingAddressDialog>{

  TextEditingController _phoneEditController;
  TextEditingController _addressEditController;
  String selectedArea;
  String selectedDistrict;

  var _isInit = true;
  var _isLoading = false;

  @override
  void initState(){
    _phoneEditController = TextEditingController();
    _addressEditController = TextEditingController();
    super.initState();
  }

  @override
  void didChangeDependencies(){
    if(_isInit) {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });
      Provider.of<ShippingAddress>(context).fetchDistrictList().then((_){
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      });
//      Provider.of<ShippingAddress>(context).fetchAreaList().then((_){
//        if (!mounted) return;
//        setState(() {
//          _isLoading = false;
//        });
//      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }


  Widget phoneField() {
    return TextField(
      controller: _phoneEditController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        suffixIcon: Icon(Icons.phone),
        hintText: 'Phone number',
//          border:
//          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
      ),
    );
  }


  Widget addressField() {
    return TextField(
      controller: _addressEditController,
      keyboardType: TextInputType.multiline,
      minLines: 2,
      maxLines: 3,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        suffixIcon: Icon(Icons.home),
        hintText: 'Home address',
//          border:
//          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final shippingAddress = Provider.of<ShippingAddress>(context);
    Map<String,dynamic> district = shippingAddress.allDistricts;
    Map<String,dynamic> areas = Map();
    return AlertDialog(
      title: Center(child: Text('Shipping Address'),),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            phoneField(),
//            Container(
//              child: Row(
//                  children: <Widget>[
//                    Expanded(child: phoneField(),),
//                    Icon()
//                  ],
//              ),
//            ),
            SizedBox(height: 15.0,),
            DistrictDropDown(),
            SizedBox(height: 15.0,),
            AreaDropDown(),
            SizedBox(height: 15.0,),
            addressField(),
            SizedBox(height: 25.0,),
            Container(
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    side: BorderSide(color: Colors.grey)),
                onPressed: () {
                  if(widget.cart.items.length <=0) {
                    print(shippingAddress.selectedDistrict);
                    print(shippingAddress.selectedArea);
                    print(_phoneEditController.text);
                    print(_addressEditController.text);
                    Provider.of<ShippingAddress>(context, listen: false)
                        .createShippingAddress(
                      shippingAddress.selectedArea.toString(),
                      _addressEditController.text,
                      _phoneEditController.text,
                    );
                    Navigator.of(context).pop();
                  }else{
                    FormData data = new FormData();
                    List<Cart>  ct = [];
                    ct = widget.cart.items.entries.map((e) => Cart(id:e.key,cartItem:e.value)).toList();

                    for(int i = 0; i<ct.length; i++){
                      data.add('product_id[$i]', ct[i].cartItem.id);
                      data.add('quantity[$i]', ct[i].cartItem.quantity);
                      data.add('unit_price[$i]', ct[i].cartItem.price);
                      data.add('is_non_inventory[$i]', ct[i].cartItem.isNonInventory);
                      data.add('discount[$i]', ct[i].cartItem.discount);
                    }
                    data.add('area_id', shippingAddress.selectedArea.toString());
                    data.add('shipping_address_line', _addressEditController.text);
                    data.add('mobile_no', _phoneEditController.text);
                    Provider.of<Orders>(context, listen: false).addOrder(data);
                    widget.cart.clear();
                    Navigator.of(context).pushNamed(ProductsOverviewScreen.routeName);
//                    if(selctedAddressId != null) {
//                      Provider.of<Orders>(context, listen: false).addOrder(data);
//                      widget.cart.clear();
//                      Navigator.of(context).pushNamed(ProductsOverviewScreen.routeName);
//                    }else{
//                      Scaffold.of(context).showSnackBar(SnackBar(
//                        backgroundColor: Theme.of(context).primaryColor,
//                        content: Container(padding: EdgeInsets.only(top: 5.0,bottom: 5.0),
//                            child:Text('Please select a deliver address or create new one')),
//                        duration: Duration(seconds: 2),
//                      ));
//                    }
                  }
                },
                color: Theme.of(context).primaryColor,
                textColor: Colors.white,
                child: Text("Confirm".toUpperCase(),
                    style: TextStyle(fontSize: 14)),
              ),
            )
          ],
        ),
      ),
    );
  }

}


class DistrictDropDown extends StatelessWidget {

  String selectedDistrict;
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

  @override
  Widget build(final BuildContext context) {
    final shippingAddress = Provider.of<ShippingAddress>(context);

    Map<String,dynamic> district = shippingAddress.allDistricts;
    return Consumer<ShippingAddress>(
      builder: (
          final BuildContext context,
          final ShippingAddress address,
          final Widget child,
          ) {
        return DropdownButton(
          isExpanded: true,
          icon: Icon(Icons.location_city),
          hint: Text('Select district'),
          value: shippingAddress.selectedDistrict,
          onChanged: (newValue) {
            shippingAddress.selectedDistrict = newValue;
            shippingAddress.selectedArea = null;
          },
          items: _districtMenuItems(district),
        );
      },
    );
  }
}

class AreaDropDown extends StatelessWidget {

  String selectedArea;
  List<DropdownMenuItem> _districtMenuItems(Map<String, dynamic> items) {
    List<DropdownMenuItem> itemWidgets = List();
    items.forEach((key, value) {
      itemWidgets.add(DropdownMenuItem(
        value: key,
        child: Text(value),
      ));
    });
    return itemWidgets;
  }

  @override
  Widget build(final BuildContext context) {
    final shippingAddress = Provider.of<ShippingAddress>(context);
    Map<String,dynamic> district = shippingAddress.allAreas;
    return Consumer<ShippingAddress>(
      builder: (
          final BuildContext context,
          final ShippingAddress address,
          final Widget child,
          ) {
        return DropdownButton(

          isExpanded: true,
          icon: Icon(Icons.local_gas_station),
          hint: Text('Select area'),
          value: shippingAddress.selectedArea,
          onChanged: (newValue) {
            shippingAddress.selectedArea = newValue;
          },
          items: _districtMenuItems(district),
        );
      },
    );
  }
}