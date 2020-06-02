import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/orders.dart';
import 'package:shoptempdb/providers/shipping_address.dart';


class CreateShippingAddressDialog extends StatefulWidget {

  @override
  _CreateShippingAddressDialogState createState() => _CreateShippingAddressDialogState();
}

class _CreateShippingAddressDialogState extends State<CreateShippingAddressDialog>{

  TextEditingController _phoneEditController;
  TextEditingController _mailEditController;
  TextEditingController _addressEditController;

  var _isInit = true;
  var _isLoading = false;

  @override
  void initState(){
//    _phoneEditController.text = '+88-01797512457';
    super.initState();
  }

  @override
  void didChangeDependencies(){
    if(_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<ShippingAddress>(context).fetchAreaList().then((_){
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }


  Widget phoneField(data) {
    return TextField(
      controller: _phoneEditController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        prefixIcon: Icon(Icons.phone),
        hintText: data,
//          border:
//          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
      ),
    );
  }

  Widget mailField(data) {
    return TextField(
      controller: _mailEditController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        prefixIcon: Icon(Icons.mail),
        hintText: data,
//          border:
//          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
      ),
    );
  }

  Widget addressField(data) {
    return TextField(
      controller: _addressEditController,
      keyboardType: TextInputType.multiline,
      minLines: 2,
      maxLines: 3,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        prefixIcon: Icon(Icons.home),
        hintText: data,
//          border:
//          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
      ),
    );
  }

  List<DropdownMenuItem> _menuItems(Map<dynamic, dynamic> items) {
    List<DropdownMenuItem> itemWidgets = List();
    items.forEach((key, value) {
      itemWidgets.add(DropdownMenuItem(
        value: key,
        child: Text(value),
      ));
    });
    return itemWidgets;
  }

  int selectedArea;
  @override
  Widget build(BuildContext context) {
    final shippingAddress = Provider.of<ShippingAddress>(context);
    final cart = Provider.of<Cart>(context);
    return AlertDialog(
      title: Center(child: Text('Shipping Address'),),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            phoneField('+88-01797512457'),
            SizedBox(height: 15.0,),
          DropdownButton(
          isExpanded: true,
          hint: Text('Select area'),
          value: selectedArea,
          onChanged: (newValue) {
            setState(() {
              selectedArea = newValue;
              print(selectedArea);
            });
          },
          items: _menuItems(shippingAddress.getAreaList),
        ),

//            mailField('test@gmail.com'),
            SizedBox(height: 15.0,),
            addressField('76/3, Block-g, Road-2 \nUttora, Dhaka'),
            SizedBox(height: 25.0,),
            Container(
              child: RaisedButton(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    side: BorderSide(color: Colors.grey)),
                onPressed: () {
                  Provider.of<ShippingAddress>(context, listen: false).createShippingAddress(selectedArea,_addressEditController.text);
                  Navigator.of(context).pop();
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