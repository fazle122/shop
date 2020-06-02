import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shoptempdb/widgets/create_shippingAddress_dialog.dart';

class Profilepage extends StatelessWidget{
  static const routeName = '/profile';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile page'),),
      body: Column(
        children: <Widget>[
          Container(
            height: 30.0,
            color: Colors.grey[300],
            child: Center(child:Text('Shipping address')),
          ),
          ListTile(
            leading: Icon(Icons.phone),
            title: Text('+88-01797512457'),
            onTap: (){
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.location_city),
            title: Text('Mirpur'),
            onTap: (){
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.home),
            title: Text('76/3, Block-g, Road-2 \nUttora, Dhaka'),
            onTap: (){
            },
          ),
          Divider(),
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
              child: Text("Edit info".toUpperCase(),
                  style: TextStyle(fontSize: 14)),
            ),
          ),
          SizedBox(height: 10.0,),
          Container(
            height: 30.0,
            color: Colors.grey[300],
            child: Center(child:Text('password')),
          ),
          ListTile(
            leading: Icon(Icons.vpn_key),
            title: Text('*******'),
            onTap: (){
              Navigator.of(context).pushNamed(Profilepage.routeName);
            },
          ),
          Divider(),
          Container(
            height: 40.0,
            width: 150.0,
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25.0),
                  side: BorderSide(color: Colors.grey)),
              onPressed: () {},
              color: Theme.of(context).primaryColor,
              textColor: Colors.white,
              child: Text("Change password".toUpperCase(),
                  style: TextStyle(fontSize: 14)),
            ),
          ),
        ],
      ),
    );

  }

}