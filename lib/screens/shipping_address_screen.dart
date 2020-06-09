import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/shipping_address.dart';
import 'package:shoptempdb/widgets/app_drawer.dart';
import 'package:shoptempdb/widgets/create_shippingAddress_dialog.dart';
import 'package:shoptempdb/widgets/order_item.dart';
import 'package:shoptempdb/widgets/shipping_address_item.dart';

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
                    child: CreateShippingAddressDialog()
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
                print(selctedAddressId);
              },
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              child: Text("CONFIRM ORDER".toUpperCase(),
                  style: TextStyle(fontSize: 14)),
            ),
          ),
        ],
      ),
//      body: FutureBuilder(
//          future: Provider.of<ShippingAddress>(context,listen: false).fetchShippingAddress(),
//          builder: (context,dataSnapshot) {
//            if(dataSnapshot.connectionState == ConnectionState.waiting) {
//              return Center(child: CircularProgressIndicator(),);
//            }else{
//              if(dataSnapshot.error != null){
//                return Center(child: Text('error occurred'),);
//              }else{
//                return Consumer<ShippingAddress>(builder: (context,addressData,child) =>
//                Column(
//                  children: <Widget>[
//                    Container(
//                      padding: EdgeInsets.all(20.0),
//                      child: Text("Shipping Addresses"),
//                    ),
//                    Column(
//                      children: createRadioListUsers(addressData.allShippingAddress),
//                    ),
//                  ],
//                )
////                    ListView.builder(
////                  itemCount: addressData.allShippingAddress.length,
////                  itemBuilder: (context,i) => ShippingAddressItemWidget(addressData.allShippingAddress[i]),
////                ),
//
//                );
//              }
//            }
//          }
//      ),
    );
  }
}
