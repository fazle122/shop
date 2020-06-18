import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/orders.dart';
import 'package:shoptempdb/providers/shipping_address.dart';
import 'package:shoptempdb/screens/products_overview_screen.dart';
import 'package:shoptempdb/widgets/app_drawer.dart';
import 'package:shoptempdb/widgets/create_shippingAddress_dialog.dart';
import 'package:shoptempdb/widgets/order_item.dart';
import 'package:shoptempdb/widgets/shipping_address_item.dart';
import 'package:dio/dio.dart';


class ShippingAddressScreen extends StatefulWidget {
  static const routeName = '/shipping_address';

  @override
  _ShippingAddressScreenState createState() => _ShippingAddressScreenState();
}

class _ShippingAddressScreenState extends State<ShippingAddressScreen> {
  AddressItem selectedAddress;
  String selctedAddressId;

  @override
  void initState() {
    super.initState();
    Provider.of<ShippingAddress>(context, listen: false).fetchShippingAddress();
  }

  setSelectedAddress(AddressItem address) {
    setState(() {
      selectedAddress = address;
      selctedAddressId = address.id;
    });
  }

  List<Widget> createRadioListUsers(List<AddressItem> address) {
    List<Widget> widgets = [];
    for (AddressItem data in address) {
      widgets.add(
        RadioListTile(
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
      );
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    final shippingData = Provider.of<ShippingAddress>(context);
    final cart = ModalRoute.of(context).settings.arguments as Cart;
    return Scaffold(
      appBar: AppBar(
        title: Text('Shipping address'),
      ),
      drawer: AppDrawer(),
      body: Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(15.0),
            child: Text("Choose Address"),
          ),
          SizedBox(height: 10.0,),
          Container(
            height: 350.0,
            child: ListView(children: createRadioListUsers(shippingData.allShippingAddress),),),
          SizedBox(height: 10.0,),

          Container(
            height: 40.0,
            width: 150.0,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  side: BorderSide(color: Colors.grey)),
              onPressed: () {
                showDialog(
                    context: context,
                    child: CreateShippingAddressDialog(cart:cart)
                );
              },
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              child: Text("Add new address".toUpperCase(),
                  style: TextStyle(fontSize: 14)),
            ),
          ),
          SizedBox(height: 10.0,),
          SizedBox(height:20.0,),
          Container(
            height: 40.0,
            width: 150.0,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  side: BorderSide(color: Colors.grey)),
              onPressed: () {
                FormData data = new FormData();
                List<Cart>  ct = [];
                ct = cart.items.entries.map((e) => Cart(id:e.key,cartItem:e.value)).toList();

                for(int i = 0; i<ct.length; i++){
                  data.add('product_id[$i]', ct[i].cartItem.id);
                  data.add('quantity[$i]', ct[i].cartItem.quantity);
                  data.add('unit_price[$i]', ct[i].cartItem.price);
                  data.add('is_non_inventory[$i]', ct[i].cartItem.isNonInventory);
                  data.add('discount[$i]', ct[i].cartItem.discount);
                }
                data.add('customer_shipping_address_id', selctedAddressId);
                if(selctedAddressId != null) {
                  Provider.of<Orders>(context, listen: false).addOrder(data);
                  cart.clear();
                  Navigator.of(context).pushNamed(
                      ProductsOverviewScreen.routeName);
                }else{
                  Scaffold.of(context).showSnackBar(SnackBar(
                    backgroundColor: Theme.of(context).primaryColor,
                    content: Container(padding: EdgeInsets.only(top: 5.0,bottom: 5.0),
                        child:Text('Please select a deliver address or create new one')),
                    duration: Duration(seconds: 2),
                  ));
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
    );
  }
}
