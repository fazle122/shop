import 'package:flutter/material.dart';
import 'package:shoptempdb/screens/auth_screen.dart';
import 'package:shoptempdb/screens/orders_screen.dart';
import 'package:shoptempdb/screens/products_overview_screen.dart';
import 'package:shoptempdb/screens/profile_screen.dart';
import 'package:shoptempdb/screens/user_products_screen.dart';


class AppDrawer extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
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
                      Text('Guest User',style: TextStyle(color: Theme.of(context).textSelectionColor),),
                    ],
                  )
              ),
              Positioned(
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
              ),
            ]))
//        DrawerHeader(
//            child: Text('Categories', style: TextStyle(color: Colors.white)),
//            decoration: BoxDecoration(
//                color: Theme.of(context).primaryColor
//            ),
//            margin: EdgeInsets.all(0.0),
//            padding: EdgeInsets.all(0.0)
//        ),
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

              leading: Icon(Icons.category),
              title: new Text('Category'),
              backgroundColor: Theme.of(context).accentColor.withOpacity(0.025),
              children: <Widget>[
                new ListTile(
                  leading: Icon(Icons.local_grocery_store),
                  title: const Text('Food'),
                  onTap: () {
                    Navigator.of(context).pushNamed(ProductsOverviewScreen.routeName,arguments: 'Food');
                  },
                ),
                new ListTile(
                  leading: Icon(Icons.local_grocery_store),
                  title: const Text('Grocery'),
                  onTap: () {
                    Navigator.of(context).pushNamed(ProductsOverviewScreen.routeName,arguments: 'Grocery');
                  },
                ),
              ]
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.payment),
            title: Text('Orders'),
            onTap: (){
              Navigator.of(context).pushReplacementNamed(OrdersScreen.routeName);
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
            onTap: (){
              Navigator.of(context).pushNamed(AuthScreen.routeName);
            },
          ),
          Divider(),
        ],
      ),
    );
  }

}




