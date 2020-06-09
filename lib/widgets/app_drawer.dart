import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/auth.dart';
import 'package:shoptempdb/providers/productCategories.dart';
import 'package:shoptempdb/screens/auth_screen.dart';
import 'package:shoptempdb/screens/orders_screen.dart';
import 'package:shoptempdb/screens/products_overview_screen.dart';
import 'package:shoptempdb/screens/profile_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shoptempdb/screens/test.dart';




class AppDrawer extends StatefulWidget {
  @override
  _AppDrawerState createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer>{
  PageStorageKey _key;
  String token;
  String userId;


//  @override
//  void initState(){
//    super.initState();
//    authenticateUser();
//  }

//  @override
//  void didChangeDependencies(){
//    Provider.of<Auth>(context).tryAutoLogin();
//    super.didChangeDependencies();
//  }

//  void authenticateUser() async {
//    final prefs = await SharedPreferences.getInstance();
//    if (prefs.containsKey('userData')) {
//      final extractedUserData = json.decode(prefs.getString('userData')) as Map<String, Object>;
//      final expiryDate = DateTime.parse(extractedUserData['expiryDate']);
//      if (!mounted) return;
//      setState(() {
//        token = extractedUserData['token'];
//        userId = extractedUserData['userId'];
//      });
//    }
//  }



  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<Auth>(context);
    return Drawer(
      child: ListView(
        children: <Widget>[
        Container(
        height: 140.0,
        width: MediaQuery.of(context).size.width,
        child:
        DrawerHeader(
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,),
            child: Stack(children: <Widget>[

              Positioned(
                  top: 20.0,
                  left: 30.0,
                  child: Column(
                    children: <Widget>[
                      CircleAvatar(
                        radius:30.0,
//                  backgroundImage: NetworkImage(),
                        backgroundImage: AssetImage('assets/profile.png'),
                      ),
                      SizedBox(height: 5.0,),
                      auth.userId != null ? Text(auth.userId):Text('Guest User'),
                    ],
                  )
              ),

              auth.token == null ?Positioned(
                  top: 20.0,
                  right: 30.0,
                  child: Column(
                    children: <Widget>[
                      IconButton(
                        icon: Icon(Icons.exit_to_app,color: Colors.white,size: 25.0,),
                        onPressed: (){
                          Navigator.of(context).pushNamed(AuthScreen.routeName);
                        },
                      ),
//                    SizedBox(height: 5.0,),
                      Text('Login',style: TextStyle(color: Theme.of(context).textSelectionColor),),
                    ],
                  )
              ):SizedBox(width: 0.0,height: 0.0,),
            ]))
      ),
//          AppBar(title: Text('Hello'),automaticallyImplyLeading: false,),
          Divider(),
          ListTile(
            leading: Icon(Icons.shop),
            title: Text('All products'),
            onTap: (){
              Navigator.of(context).pushNamed(ProductsOverviewScreen.routeName);
            },
          ),
          Divider(),
        ExpansionTile(
          key: _key,
          leading: Icon(Icons.category),
          title: new Text('Category'),
          children: <Widget>[
          Container(
            height: 250.0,
            child:
            FutureBuilder(
                future: Provider.of<ProductCategories>(context,listen: false).fetchProductsCategory(),
                builder: (context,dataSnapshot) {
                  if(dataSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator(),);
                  }else{
                    if(dataSnapshot.error != null){
                      return Center(child: Text('error occurred'),);
                    }else{
                      return Consumer<ProductCategories>(builder: (context,catData,child) => ListView.builder(
                        itemCount: catData.getCategories.length,
                        itemBuilder: (context,i) => ListTile(
                          title: Text(catData.getCategories[i].name),
                          onTap: (){
                            Navigator.of(context).pushNamed(ProductsOverviewScreen.routeName,arguments: catData.getCategories[i].id);
                          },
                        ),
                      ),);
                    }
                  }
                }
            ),
          ),

          ],
        ),


          Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Orders'),
            onTap: (){
              Navigator.of(context).pushReplacementNamed(OrdersScreen.routeName);
//              Navigator.of(context).pushReplacementNamed(TestScreen.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.person),
            title: Text('My account'),
            onTap: (){
              Navigator.of(context).pushNamed(Profilepage.routeName);
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.power_settings_new),
            title: Text('Logout'),
            onTap: () async{
              await Provider.of<Auth>(context, listen: false).logout();
              Navigator.of(context).pushNamed(ProductsOverviewScreen.routeName);

            },
          ),
          Divider(),
        ],
      ),
    );
  }

}




