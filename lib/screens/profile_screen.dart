import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/shipping_address.dart';
import 'package:shoptempdb/screens/profile_update_screen.dart';
import 'package:shoptempdb/widgets/app_drawer.dart';
import 'package:shoptempdb/widgets/create_shippingAddress_dialog.dart';
import 'package:shoptempdb/widgets/profile_update_dialog.dart';

import '../base_state.dart';





///------------last and working class-----------------------
//class ProfilePage extends StatelessWidget {
//  static const routeName = '/profile';
//
//  Future<void> _getProfileInfo(BuildContext context) async {
//    await Provider.of<ShippingAddress>(context, listen: false).fetchProfileInfo();
//  }
//
//
//  @override
//  Widget build(BuildContext context) {
//    final profileInfo = Provider.of<ShippingAddress>(context, listen: false);
//    return Scaffold(
//        appBar: AppBar(
//          title: Text('Profile page'),
//        ),
//        drawer: AppDrawer(),
//        body: FutureBuilder(
//          future: _getProfileInfo(context),
//          builder: (context,snapshot) =>
//          snapshot.connectionState == ConnectionState.waiting && profileInfo.profileInfo == null?
//          Center(child: CircularProgressIndicator(),):
//          Column(
//            children: <Widget>[
//              Container(
//                height: 30.0,
//                color: Colors.grey[300],
//                child: Center(child: Text('Profile information')),
//              ),
//              ListTile(
//                leading: Icon(Icons.person),
//                title: profileInfo.profileInfo.name != null
//                    ? Text(profileInfo.profileInfo.name)
//                    : Text('not updated'),
//                onTap: () {},
//              ),
//              Divider(),
//              ListTile(
//                leading: Icon(Icons.phone),
//                title: profileInfo.profileInfo.mobileNumber != null
//                    ? Text(profileInfo.profileInfo.mobileNumber)
//                    : Text('not updated'),
//                onTap: () {},
//              ),
//              Divider(),
//              ListTile(
//                leading: Icon(Icons.email),
//                title: profileInfo.profileInfo.email != null
//                    ? Text(profileInfo.profileInfo.email)
//                    : Text('not updated'),
//                onTap: () {},
//              ),
//              Divider(),
//              ListTile(
//                leading: Icon(Icons.home),
//                title: profileInfo.profileInfo.address != null
//                    ? Text(profileInfo.profileInfo.address)
//                    : Text('not updated'),
//                onTap: () {},
//              ),
//              Divider(),
//              Container(
//                height: 40.0,
//                width: 150.0,
//                child: RaisedButton(
//                  shape: RoundedRectangleBorder(
//                      borderRadius: BorderRadius.circular(25.0),
//                      side: BorderSide(color: Colors.grey)),
//                  onPressed: () {
//                    Navigator.of(context).pushNamed(ProfileUpdateScreen.routeName);
////                  showDialog(
////                      context: context,
//////                      child: ProfileUpdateDialog(profileInfo.profileInfo));
////                      child: ProfileUpdateDialog()
////                  );
//                  },
//                  color: Theme.of(context).primaryColor,
//                  textColor: Colors.white,
//                  child: Text("Edit info".toUpperCase(),
//                      style: TextStyle(fontSize: 14)),
//                ),
//              ),
////            SizedBox(height: 10.0,),
////            Container(
////              height: 30.0,
////              color: Colors.grey[300],
////              child: Center(child:Text('password')),
////            ),
////            ListTile(
////              leading: Icon(Icons.vpn_key),
////              title: Text('*******'),
////              onTap: (){
////                Navigator.of(context).pushNamed(Profilepage.routeName);
////              },
////            ),
////            Divider(),
////            Container(
////              height: 40.0,
////              width: 150.0,
////              child: RaisedButton(
////                shape: RoundedRectangleBorder(
////                    borderRadius: BorderRadius.circular(25.0),
////                    side: BorderSide(color: Colors.grey)),
////                onPressed: () {},
////                color: Theme.of(context).primaryColor,
////                textColor: Colors.white,
////                child: Text("Change password".toUpperCase(),
////                    style: TextStyle(fontSize: 14)),
////              ),
////            ),
//            ],
//          ),
//        )
//
//    );
//  }
//}


















///------------with out future builder-----------------------
class ProfilePage extends StatefulWidget {
  static const routeName = '/profile';

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends BaseState<ProfilePage> {

  var _isInit = true;
  var _isLoading = false;
  @override
  void didChangeDependencies() {
    if(_isInit) {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });
      Provider.of<ShippingAddress>(context).fetchProfileInfo().then((_){
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }


  @override
  Widget build(BuildContext context) {
//    final profileInfo = Provider.of<ShippingAddress>(context,listen: false);
    return Scaffold(
        appBar: AppBar(
          title: Text('Profile page'),
        ),
        drawer: AppDrawer(),
        body: _isLoading ? Center(child: CircularProgressIndicator(),)
            :Consumer<ShippingAddress>(
          builder: (context, profileInfo, child) =>
              Column(
            children: <Widget>[
              Container(
                height: 30.0,
                color: Colors.grey[300],
                child: Center(child: Text('Profile information')),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: profileInfo.profileInfo.name != null
                    ? Text(profileInfo.profileInfo.name)
                    : Text('not updated'),
                onTap: () {},
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.phone),
                title: profileInfo.profileInfo.mobileNumber != null
                    ? Text(profileInfo.profileInfo.mobileNumber)
                    : Text('not updated'),
                onTap: () {},
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.email),
                title: profileInfo.profileInfo.email != null
                    ? Text(profileInfo.profileInfo.email)
                    : Text('not updated'),
                onTap: () {},
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.home),
                title: profileInfo.profileInfo.address != null
                    ? Text(profileInfo.profileInfo.address)
                    : Text('not updated'),
                onTap: () {},
              ),
              Divider(),
              Container(
                height: 40.0,
                width: 150.0,
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(color: Colors.grey)),
                  onPressed: () async{
//                    await Navigator.of(context).pushNamed(ProfileUpdateScreen.routeName);

                  await showDialog(
                      context: context,
                      child: ProfileUpdateDialog(profileInfo.profileInfo)
//                      child: ProfileUpdateDialog()
                  );

                  if (!mounted) return;
                    setState(() {
                      _isInit = true;
                    });
                  },
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  child: Text("Edit info".toUpperCase(),
                      style: TextStyle(fontSize: 14)),
                ),
              ),
//            SizedBox(height: 10.0,),
//            Container(
//              height: 30.0,
//              color: Colors.grey[300],
//              child: Center(child:Text('password')),
//            ),
//            ListTile(
//              leading: Icon(Icons.vpn_key),
//              title: Text('*******'),
//              onTap: (){
//                Navigator.of(context).pushNamed(Profilepage.routeName);
//              },
//            ),
//            Divider(),
//            Container(
//              height: 40.0,
//              width: 150.0,
//              child: RaisedButton(
//                shape: RoundedRectangleBorder(
//                    borderRadius: BorderRadius.circular(25.0),
//                    side: BorderSide(color: Colors.grey)),
//                onPressed: () {},
//                color: Theme.of(context).primaryColor,
//                textColor: Colors.white,
//                child: Text("Change password".toUpperCase(),
//                    style: TextStyle(fontSize: 14)),
//              ),
//            ),
            ],
          ),
        ));
  }
}










///----------------old---------------///

//
//class Profilepage extends StatefulWidget {
//  static const routeName = '/profile';
//
//  @override
//  _ProfilePageState createState() => _ProfilePageState();
//}
//
//class _ProfilePageState extends State<Profilepage> {
//  var _isLoading = false;
//
//  @override
//  void didChangeDependencies() {
//    Provider.of<ShippingAddress>(context).fetchProfileInfo();
////    if (!mounted) return;
////    setState(() {
////      _isLoading = true;
////    });
////    Provider.of<ShippingAddress>(context).fetchProfileInfo().then((_) {
////      if (!mounted) return;
////      setState(() {
////        _isLoading = false;
////      });
////    });
//    super.didChangeDependencies();
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    final profileInfo = Provider.of<ShippingAddress>(context);
//    return Scaffold(
//        appBar: AppBar(
//          title: Text('Profile page'),
//        ),
//        body: profileInfo.profileInfo == null ? Center(child: CircularProgressIndicator(),):Column(
//          children: <Widget>[
//            Container(
//              height: 30.0,
//              color: Colors.grey[300],
//              child: Center(child: Text('Profile information')),
//            ),
//            ListTile(
//              leading: Icon(Icons.person),
//              title: profileInfo.profileInfo.name != null
//                  ? Text(profileInfo.profileInfo.name)
//                  : Text('not updated'),
//              onTap: () {},
//            ),
//            Divider(),
//            ListTile(
//              leading: Icon(Icons.phone),
//              title: profileInfo.profileInfo.mobileNumber != null
//                  ? Text(profileInfo.profileInfo.mobileNumber)
//                  : Text('not updated'),
//              onTap: () {},
//            ),
//            Divider(),
//            ListTile(
//              leading: Icon(Icons.email),
//              title: profileInfo.profileInfo.email != null
//                  ? Text(profileInfo.profileInfo.email)
//                  : Text('not updated'),
//              onTap: () {},
//            ),
//            Divider(),
//            ListTile(
//              leading: Icon(Icons.home),
//              title: profileInfo.profileInfo.address != null
//                  ? Text(profileInfo.profileInfo.address)
//                  : Text('not updated'),
//              onTap: () {},
//            ),
//            Divider(),
//            Container(
//              height: 40.0,
//              width: 150.0,
//              child: RaisedButton(
//                shape: RoundedRectangleBorder(
//                    borderRadius: BorderRadius.circular(25.0),
//                    side: BorderSide(color: Colors.grey)),
//                onPressed: () {
//                  Navigator.of(context).pushNamed(ProfileUpdateScreen.routeName);
////                  showDialog(
////                      context: context,
//////                      child: ProfileUpdateDialog(profileInfo.profileInfo));
////                      child: ProfileUpdateDialog()
////                  );
//                },
//                color: Theme.of(context).primaryColor,
//                textColor: Colors.white,
//                child: Text("Edit info".toUpperCase(),
//                    style: TextStyle(fontSize: 14)),
//              ),
//            ),
////            SizedBox(height: 10.0,),
////            Container(
////              height: 30.0,
////              color: Colors.grey[300],
////              child: Center(child:Text('password')),
////            ),
////            ListTile(
////              leading: Icon(Icons.vpn_key),
////              title: Text('*******'),
////              onTap: (){
////                Navigator.of(context).pushNamed(Profilepage.routeName);
////              },
////            ),
////            Divider(),
////            Container(
////              height: 40.0,
////              width: 150.0,
////              child: RaisedButton(
////                shape: RoundedRectangleBorder(
////                    borderRadius: BorderRadius.circular(25.0),
////                    side: BorderSide(color: Colors.grey)),
////                onPressed: () {},
////                color: Theme.of(context).primaryColor,
////                textColor: Colors.white,
////                child: Text("Change password".toUpperCase(),
////                    style: TextStyle(fontSize: 14)),
////              ),
////            ),
//          ],
//        ));
//
////        FutureBuilder(
////            future: profileInfo.fetchProfileInfo(),
////            builder: (context, dataSnapshot) {
////              if (dataSnapshot.connectionState == ConnectionState.waiting) {
////                return Center(child: CircularProgressIndicator());
////              } else {
////                return Column(
////                  children: <Widget>[
////                    Container(
////                      height: 30.0,
////                      color: Colors.grey[300],
////                      child: Center(child: Text('Profile information')),
////                    ),
////                    ListTile(
////                      leading: Icon(Icons.person),
////                      title: profileInfo.profileInfo.name != null
////                          ? Text(profileInfo.profileInfo.name)
////                          : Text('not updated'),
////                      onTap: () {},
////                    ),
////                    Divider(),
////                    ListTile(
////                      leading: Icon(Icons.phone),
////                      title: profileInfo.profileInfo.mobileNumber != null
////                          ? Text(profileInfo.profileInfo.mobileNumber)
////                          : Text('not updated'),
////                      onTap: () {},
////                    ),
////                    Divider(),
////                    ListTile(
////                      leading: Icon(Icons.email),
////                      title: profileInfo.profileInfo.email != null
////                          ? Text(profileInfo.profileInfo.email)
////                          : Text('not updated'),
////                      onTap: () {},
////                    ),
////                    Divider(),
////                    ListTile(
////                      leading: Icon(Icons.home),
////                      title: profileInfo.profileInfo.address != null
////                          ? Text(profileInfo.profileInfo.address)
////                          : Text('not updated'),
////                      onTap: () {},
////                    ),
////                    Divider(),
////                    Container(
////                      height: 40.0,
////                      width: 150.0,
////                      child: RaisedButton(
////                        shape: RoundedRectangleBorder(
////                            borderRadius: BorderRadius.circular(25.0),
////                            side: BorderSide(color: Colors.grey)),
////                        onPressed: () {
////                          showDialog(
////                              context: context,
////                              child:
////                                  ProfileUpdateDialog(profileInfo.profileInfo));
////                        },
////                        color: Theme.of(context).primaryColor,
////                        textColor: Colors.white,
////                        child: Text("Edit info".toUpperCase(),
////                            style: TextStyle(fontSize: 14)),
////                      ),
////                    ),
//////            SizedBox(height: 10.0,),
//////            Container(
//////              height: 30.0,
//////              color: Colors.grey[300],
//////              child: Center(child:Text('password')),
//////            ),
//////            ListTile(
//////              leading: Icon(Icons.vpn_key),
//////              title: Text('*******'),
//////              onTap: (){
//////                Navigator.of(context).pushNamed(Profilepage.routeName);
//////              },
//////            ),
//////            Divider(),
//////            Container(
//////              height: 40.0,
//////              width: 150.0,
//////              child: RaisedButton(
//////                shape: RoundedRectangleBorder(
//////                    borderRadius: BorderRadius.circular(25.0),
//////                    side: BorderSide(color: Colors.grey)),
//////                onPressed: () {},
//////                color: Theme.of(context).primaryColor,
//////                textColor: Colors.white,
//////                child: Text("Change password".toUpperCase(),
//////                    style: TextStyle(fontSize: 14)),
//////              ),
//////            ),
////                  ],
////                );
////              }
////            }));
//  }
//}
