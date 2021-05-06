import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/base_state.dart';
import 'package:shoptempdb/providers/shipping_address.dart';
import 'package:shoptempdb/widgets/app_drawer.dart';
import 'package:shoptempdb/widgets/profile_update_dialog.dart';



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
    return Scaffold(
        appBar: AppBar(
          title: Text('Profile page'),
        ),
        drawer: AppDrawer(),
        body: _isLoading ? Center(child: CircularProgressIndicator(),)
            :Consumer<ShippingAddress>(
          builder: (context, profileInfo, child) =>
              SingleChildScrollView(child: Column(
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
                        await showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (context) => ProfileUpdateDialog(profileInfo.profileInfo)
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
                ],
              ),)
        ));
  }
}

