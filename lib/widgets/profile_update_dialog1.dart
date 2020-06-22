import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/orders.dart';
import 'package:shoptempdb/providers/shipping_address.dart';
import 'package:dio/dio.dart';
import 'package:shoptempdb/screens/products_overview_screen.dart';
import 'package:shoptempdb/models/http_exception.dart';

class ProfileUpdateDialog extends StatefulWidget {
  final ProfileItem info;

  ProfileUpdateDialog(this.info);

  @override
  _ProfileUpdateDialogDialogState createState() =>
      _ProfileUpdateDialogDialogState();
}

class _ProfileUpdateDialogDialogState extends State<ProfileUpdateDialog> {
  var _isInit = true;
  var _isLoading = false;
  String selectedArea;
  String selectedDistrict;
  String addressLine;
  String city;

  final _form = GlobalKey<FormState>();
  String mobileNo;
  String homeAddress;
  String name;
  String email;

  var _currentProfile = ProfileItem(
    id: '',
    name: '',
    gender: '',
    email: '',
    mobileNumber: '',
    address: '',
    city:'',
    areaId: '',
    contactPerson: '',
    contactPersonMobileNumber: '',
  );
  var _initValues = {
    'name': '',
    'gender': '',
    'email': '',
    'mobileNumber': '',
    'address': '',
    'city':'',
    'areaId': 0,
    'contactPerson': '',
    'contactPersonMobileNumber': '',
  };



  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    _currentProfile = Provider.of<ShippingAddress>(context, listen: false).getProfileInfo();
    Provider.of<ShippingAddress>(context,listen: false).fetchDistrictList();
    _initValues = {
      'name': _currentProfile.name,
      'gender': _currentProfile.gender,
      'email': _currentProfile.email,
      'mobileNumber': _currentProfile.mobileNumber,
      'address': _currentProfile.address,
      'city':_currentProfile.city,
      'areaId': _currentProfile.areaId,
      'contactPerson': _currentProfile.contactPerson,
      'contactPersonMobileNumber': _currentProfile.contactPersonMobileNumber,
    };
    setState(() {
      selectedDistrict = _initValues['city'];
    });
//    getAreaName(_currentProfile.areaId);
    super.didChangeDependencies();
  }

  Widget nameField() {
    return TextFormField(
      initialValue: _initValues['name'],
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value.isEmpty) {
          return 'please enter name';
        }
        return null;
      },
      onSaved: (value) {
        name = value;
      },
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.person,
          color: Theme.of(context).primaryColorDark,
        ),
        hintText: 'user name',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
  }

  Widget phoneField() {
    return TextFormField(
      initialValue: _initValues['mobileNumber'],
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value.isEmpty) {
          return 'please enter mobile number';
        }else if(value.length > 11 || value.length < 11){
          return 'please provide a valid mobile number';
        }
        return null;
      },
      onSaved: (value) {
        mobileNo = value;
      },
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.phone_android,
          color: Theme.of(context).primaryColorDark,
        ),
        hintText: 'mobile number',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
  }

  Widget emailField() {
    return TextFormField(
      initialValue: _initValues['email'],
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value.isEmpty) {
          return 'please enter email address';
        }
        return null;
      },
      onSaved: (value) {
        email = value;
      },
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.email,
          color: Theme.of(context).primaryColorDark,
        ),
        hintText: 'email address',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
  }

  Widget addressField() {
    return TextFormField(
      initialValue: _initValues['address'],
      keyboardType: TextInputType.multiline,
      maxLines: 2,
      validator: (value) {
        if (value.isEmpty) {
          return 'please enter your home address';
        }
        return null;
      },
      onSaved: (value){
        homeAddress = value;
      },
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.home,
          color: Theme.of(context).primaryColorDark,
        ),
        hintText: 'Home address',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
  }

  Future<void> _saveForm(var shippingAddress) async{


    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });


    if (shippingAddress.selectedArea != null &&
        shippingAddress.selectedDistrict != null) {
      setState(() {
        city = shippingAddress.selectedDistrict;
        addressLine = shippingAddress.selectedArea +
            ',' +
            shippingAddress.selectedDistrict +
            ',' +
            homeAddress;
      });
    } else {
      city = widget.info.city;
      addressLine = homeAddress;
    }

    try {
      Map<String,dynamic> response =await Provider.of<ShippingAddress>(context, listen: false).updateProfileInfo1(
        addressLine,
        mobileNo,
        name,
        email,
        city,
//        shippingAddress.selectedArea,
      );
      if(response != null){
        String msg ='';
        for(int i=0; i<response['data'].value.length; i++)
        {
          for(int j=0; j<response['data'][''].length; j++){
            msg += 'error definition goes here';
          }
          for(int j=0; j<response['data'][''].length; j++){
            msg += 'error definition goes here';
          }
        }
        _showErrorDialog(msg);
      }
    } catch (error) {
      const errorMessage = 'Some thing wrong, please try again later';
      _showErrorDialog(errorMessage);
    }
    shippingAddress.selectedDistrict = null;
    shippingAddress.selectedArea = null;

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final shippingAddress = Provider.of<ShippingAddress>(context);
    Map<String, dynamic> district = shippingAddress.allDistricts;
    Map<String, dynamic> areas = Map();
    return AlertDialog(
      title: Center(
        child: Text('Profile info'),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              nameField(),
              SizedBox(
                height: 15.0,
              ),
              phoneField(),
              SizedBox(
                height: 15.0,
              ),
              emailField(),
              SizedBox(
                height: 15.0,
              ),
              districtDropdown(shippingAddress, shippingAddress.allDistricts),
              SizedBox(
                height: 15.0,
              ),
              areaDropdown(shippingAddress, shippingAddress.allAreas),
              SizedBox(
                height: 15.0,
              ),
              addressField(),
              SizedBox(
                height: 25.0,
              ),
              Container(
                child: RaisedButton(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                      side: BorderSide(color: Colors.grey)),
                  onPressed: () async {
                    _saveForm(shippingAddress);
                  },
                  color: Theme.of(context).primaryColor,
                  textColor: Colors.white,
                  child: Text("Confirm".toUpperCase(),
                      style: TextStyle(fontSize: 14)),
                ),
              )
            ],
          ),
        )

      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        builder: (ctx) =>
            AlertDialog(
              title: Text('An Error Occurred!'),
              content: Text(message),
              actions: <Widget>[
                FlatButton(
                  child: Text('ok'),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                )
              ],
            ));
  }

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

  List<DropdownMenuItem> _areaMenuItems(Map<String, dynamic> items) {
    List<DropdownMenuItem> itemWidgets = List();
    items.forEach((key, value) {
      itemWidgets.add(DropdownMenuItem(
        value: value,
        child: Text(value),
      ));
    });
    return itemWidgets;
  }

  Widget districtDropdown(var shippingAddress,Map<String, dynamic> district){
    return Consumer<ShippingAddress>(
      builder: (
          final BuildContext context,
          final ShippingAddress address,
          final Widget child,
          ) {
        return Stack(
          children: <Widget>[
            Container(
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1.0, style: BorderStyle.solid),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                ),
                padding: EdgeInsets.only(left: 44.0, right: 10.0),
//              margin: EdgeInsets.only(left: 16.0, right: 16.0),
                child: DropdownButtonFormField(

                  isExpanded: true,
//                icon: Icon(Icons.location_city),
                  hint: Text('Select district'),
                  value: shippingAddress.selectedDistrict,
                  onSaved: (value){
                    shippingAddress.selectedDistrict = value;
                  },
                  validator: (value){
                    if (value == null) {
                      return 'please choose district';
                    }
                    return null;
                  },
                  onChanged: (newValue) {
                    shippingAddress.selectedDistrict = newValue;
                    shippingAddress.selectedArea = null;
                  },
                  items: _districtMenuItems(district),
                )),
            Container(
              padding: EdgeInsets.only(top: 24.0, left: 12.0),
              child: Icon(
                Icons.location_city,
                color: Theme.of(context).primaryColor,
//              size: 20.0,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget areaDropdown(var shippingAddress,Map<String, dynamic> areas){
    return Consumer<ShippingAddress>(
      builder: (
          final BuildContext context,
          final ShippingAddress address,
          final Widget child,
          ) {
        return Stack(
          children: <Widget>[
            Container(
                decoration: ShapeDecoration(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1.0, style: BorderStyle.solid),
                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  ),
                ),
                padding: EdgeInsets.only(left: 44.0, right: 10.0),
//              margin: EdgeInsets.only(left: 16.0, right: 16.0),
                child: DropdownButtonFormField(
                  isExpanded: true,
//                icon: Icon(Icons.local_gas_station),
                  hint: Text('Select area'),
                  value: shippingAddress.selectedArea,
                  onSaved: (value){
                    shippingAddress.selectedArea = value;

                  },
                  validator: (value){
                    if (value == null) {
                      return 'please choose area';
                    }
                    return null;
                  },
                  onChanged: (newValue) {
                    shippingAddress.selectedArea = newValue;
                  },
                  items: _areaMenuItems(areas),
                )),
            Container(
              margin: EdgeInsets.only(top: 24.0, left: 12.0),
              child: Icon(
                Icons.local_gas_station,
                color: Theme.of(context).primaryColor,
//              size: 20.0,
              ),
            ),
          ],
        );
      },
    );
  }
}

class DistrictDropDown extends StatelessWidget {
  String selectedDistrict;

//  DistrictDropDown(this.selectedDistrict);
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

    Map<String, dynamic> district = shippingAddress.allDistricts;
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
        value: value,
        child: Text(value),
      ));
    });
    return itemWidgets;
  }

  @override
  Widget build(final BuildContext context) {
    final shippingAddress = Provider.of<ShippingAddress>(context);
    Map<String, dynamic> district = shippingAddress.allAreas;
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