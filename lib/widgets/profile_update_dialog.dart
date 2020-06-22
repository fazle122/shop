//import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
//import 'package:shoptempdb/providers/cart.dart';
//import 'package:shoptempdb/providers/orders.dart';
//import 'package:shoptempdb/providers/shipping_address.dart';
//import 'package:dio/dio.dart';
//import 'package:shoptempdb/screens/products_overview_screen.dart';
//import 'package:shoptempdb/models/http_exception.dart';
//
//class ProfileUpdateDialog extends StatefulWidget {
//  final ProfileItem info;
//
//  ProfileUpdateDialog(this.info);
//
//  @override
//  _ProfileUpdateDialogDialogState createState() =>
//      _ProfileUpdateDialogDialogState();
//}
//
//class _ProfileUpdateDialogDialogState extends State<ProfileUpdateDialog> {
//  TextEditingController _nameEditController;
//  TextEditingController _phoneEditController;
//  TextEditingController _emailEditController;
//  TextEditingController _addressEditController;
//  String selectedArea;
//  String selectedDistrict;
//  String addressLine;
//  String mobileNo;
//  String city;
//
//  var _isInit = true;
//  var _isLoading = false;
//
//  @override
//  void initState() {
//    _nameEditController = TextEditingController();
//    _nameEditController.text = widget.info.name;
//    _phoneEditController = TextEditingController();
//    _phoneEditController.text = widget.info.mobileNumber;
//    _emailEditController = TextEditingController();
//    _emailEditController.text = widget.info.email;
//    _addressEditController = TextEditingController();
//    _addressEditController.text = widget.info.address;
//
//    super.initState();
//  }
//
//  @override
//  void didChangeDependencies() {
//    if (_isInit) {
//      if (!mounted) return;
//      setState(() {
//        _isLoading = true;
//      });
//      Provider.of<ShippingAddress>(context).fetchDistrictList().then((_) {
//        if (!mounted) return;
//        setState(() {
//          _isLoading = false;
//        });
//      });
////      Provider.of<ShippingAddress>(context).fetchAreaList().then((_){
////        if (!mounted) return;
////        setState(() {
////          _isLoading = false;
////        });
////      });
//    }
//    _isInit = false;
//    super.didChangeDependencies();
//  }
//
//  Widget nameField() {
//    return TextField(
//      controller: _nameEditController,
//      keyboardType: TextInputType.text,
//      decoration: InputDecoration(
//        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
//        suffixIcon: Icon(Icons.person),
//        hintText: 'user name',
////          border:
////          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
//      ),
//    );
//  }
//
//  Widget phoneField() {
//    return TextField(
//      controller: _phoneEditController,
//      keyboardType: TextInputType.number,
//      decoration: InputDecoration(
//        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
//        suffixIcon: Icon(Icons.phone),
//        hintText: 'Phone number',
////          border:
////          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
//      ),
//    );
//  }
//
//  Widget emailField() {
//    return TextField(
//      controller: _emailEditController,
//      keyboardType: TextInputType.emailAddress,
//      decoration: InputDecoration(
//        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
//        suffixIcon: Icon(Icons.email),
//        hintText: 'email address',
////          border:
////          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
//      ),
//    );
//  }
//
//  Widget addressField() {
//    return TextField(
//      controller: _addressEditController,
//      keyboardType: TextInputType.multiline,
//      minLines: 2,
//      maxLines: 3,
//      decoration: InputDecoration(
//        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
//        suffixIcon: Icon(Icons.home),
//        hintText: 'Home address',
////          border:
////          OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
//      ),
//    );
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    final shippingAddress = Provider.of<ShippingAddress>(context);
//    Map<String, dynamic> district = shippingAddress.allDistricts;
//    Map<String, dynamic> areas = Map();
//    return AlertDialog(
//      title: Center(
//        child: Text('Profile info'),
//      ),
//      content: SingleChildScrollView(
//        child: Column(
//          mainAxisSize: MainAxisSize.min,
//          children: <Widget>[
//            nameField(),
//            SizedBox(
//              height: 15.0,
//            ),
//            phoneField(),
//            SizedBox(
//              height: 15.0,
//            ),
//            emailField(),
//            SizedBox(
//              height: 15.0,
//            ),
//            DistrictDropDown(),
//            SizedBox(
//              height: 15.0,
//            ),
//            AreaDropDown(),
//            SizedBox(
//              height: 15.0,
//            ),
//            addressField(),
//            SizedBox(
//              height: 25.0,
//            ),
//            Container(
//              child: RaisedButton(
//                shape: RoundedRectangleBorder(
//                    borderRadius: BorderRadius.circular(25.0),
//                    side: BorderSide(color: Colors.grey)),
//                onPressed: () async {
//                  if (shippingAddress.selectedArea != null &&
//                      shippingAddress.selectedDistrict != null) {
//                    setState(() {
//                      city = shippingAddress.selectedDistrict;
//                      addressLine = shippingAddress.selectedArea +
//                          ',' +
//                          shippingAddress.selectedDistrict +
//                          ',' +
//                          _addressEditController.text;
//                    });
//                  } else {
//                    city = widget.info.city;
//                    addressLine = _addressEditController.text;
//                  }
//
//                  print(shippingAddress.selectedDistrict);
//                  print(shippingAddress.selectedArea);
//                  print(_nameEditController.text);
//                  print(_phoneEditController.text);
//                  print(_emailEditController.text);
//                  print(_addressEditController.text);
//                  print(city);
////                  try {
////                    await Provider.of<ShippingAddress>(context, listen: false).updateProfileInfo1(
////                      addressLine,
////                      '0' + _phoneEditController.text,
////                      _nameEditController.text,
////                      _emailEditController.text,
////                      city,
//////                      shippingAddress.selectedArea,
////                    );
////                  }
////                  catch (error) {
////                    const errorMessage = 'Could not authenticate you, please try again later';
////                    _showErrorDialog(errorMessage);
////                  }
//                  try {
//                    Map<String,dynamic> response =await Provider.of<ShippingAddress>(context, listen: false).updateProfileInfo1(
//                      addressLine,
//                      '0' + _phoneEditController.text,
//                      _nameEditController.text,
//                      _emailEditController.text,
//                      city,
////                      shippingAddress.selectedArea,
//                    );
//                    if(response != null){
//                      String msg ='';
//                      for(int i=0; i<response['data'].value.length; i++)
//                        {
//                          for(int j=0; j<response['data'][''].length; j++){
//                            msg += 'error definition goes here';
//                          }
//                          for(int j=0; j<response['data'][''].length; j++){
//                            msg += 'error definition goes here';
//                          }
//                        }
//                      _showErrorDialog(msg);
//                    }
//                  } catch (error) {
//                    const errorMessage = 'Some thing wrong, please try again later';
//                    _showErrorDialog(errorMessage);
//                  }
//                  shippingAddress.selectedDistrict = null;
//                  shippingAddress.selectedArea = null;
//                  print('test');
//                  Navigator.of(context).pop();
//                },
//                color: Theme.of(context).primaryColor,
//                textColor: Colors.white,
//                child: Text("Confirm".toUpperCase(),
//                    style: TextStyle(fontSize: 14)),
//              ),
//            )
//          ],
//        ),
//      ),
//    );
//  }
//
//  void _showErrorDialog(String message) {
//    showDialog(
//        context: context,
//        builder: (ctx) =>
//            AlertDialog(
//              title: Text('An Error Occurred!'),
//              content: Text(message),
//              actions: <Widget>[
//                FlatButton(
//                  child: Text('ok'),
//                  onPressed: () {
//                    Navigator.of(ctx).pop();
//                  },
//                )
//              ],
//            ));
//  }
//}
//
//class DistrictDropDown extends StatelessWidget {
//  String selectedDistrict;
//
////  DistrictDropDown(this.selectedDistrict);
//  List<DropdownMenuItem> _districtMenuItems(Map<String, dynamic> items) {
//    List<DropdownMenuItem> itemWidgets = List();
//    items.forEach((key, value) {
//      itemWidgets.add(DropdownMenuItem(
//        value: value,
//        child: Text(value),
//      ));
//    });
//    return itemWidgets;
//  }
//
//  @override
//  Widget build(final BuildContext context) {
//    final shippingAddress = Provider.of<ShippingAddress>(context);
//
//    Map<String, dynamic> district = shippingAddress.allDistricts;
//    return Consumer<ShippingAddress>(
//      builder: (
//        final BuildContext context,
//        final ShippingAddress address,
//        final Widget child,
//      ) {
//        return DropdownButton(
//          isExpanded: true,
//          icon: Icon(Icons.location_city),
//          hint: Text('Select district'),
//          value: shippingAddress.selectedDistrict,
//          onChanged: (newValue) {
//            shippingAddress.selectedDistrict = newValue;
//            shippingAddress.selectedArea = null;
//          },
//          items: _districtMenuItems(district),
//        );
//      },
//    );
//  }
//}
//
//class AreaDropDown extends StatelessWidget {
//  String selectedArea;
//
//  List<DropdownMenuItem> _districtMenuItems(Map<String, dynamic> items) {
//    List<DropdownMenuItem> itemWidgets = List();
//    items.forEach((key, value) {
//      itemWidgets.add(DropdownMenuItem(
//        value: value,
//        child: Text(value),
//      ));
//    });
//    return itemWidgets;
//  }
//
//  @override
//  Widget build(final BuildContext context) {
//    final shippingAddress = Provider.of<ShippingAddress>(context);
//    Map<String, dynamic> district = shippingAddress.allAreas;
//    return Consumer<ShippingAddress>(
//      builder: (
//        final BuildContext context,
//        final ShippingAddress address,
//        final Widget child,
//      ) {
//        return DropdownButton(
//          isExpanded: true,
//          icon: Icon(Icons.local_gas_station),
//          hint: Text('Select area'),
//          value: shippingAddress.selectedArea,
//          onChanged: (newValue) {
//            shippingAddress.selectedArea = newValue;
//          },
//          items: _districtMenuItems(district),
//        );
//      },
//    );
//  }
//}
