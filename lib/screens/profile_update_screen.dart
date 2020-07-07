import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/shipping_address.dart';
import 'package:shoptempdb/screens/profile_screen.dart';

class ProfileUpdateScreen extends StatefulWidget {
  static const routeName = '/update_profile';

  @override
  _ProfileUpdateScreenState createState() => _ProfileUpdateScreenState();
}

class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
  var _isLoading = false;
  final _form = GlobalKey<FormState>();
  String selectedDistrict;
  String selectedArea;
  String selectedAreaFromLocal;

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
    getAreaName(_currentProfile.areaId);
    super.didChangeDependencies();
  }

  getAreaName(String areaId) async{
    final data = await Provider.of<ShippingAddress>(context, listen: false).fetchAreaName(areaId.toString());
    setState(() {
      selectedAreaFromLocal = data;
    });
  }

  Future<void> _saveForm() async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });
    try {
      await Provider.of<ShippingAddress>(context, listen: false).updateProfileInfo(_currentProfile);
    } catch (error) {
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('An error occurred!'),
          content: Text(error.toString()),
          actions: <Widget>[
            FlatButton(
              child: Text('Okay'),
              onPressed: () {
                Navigator.of(ctx).pop();
              },
            )
          ],
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
//    Navigator.pop(context, true);
    Navigator.of(context).pushReplacementNamed(ProfilePage.routeName);
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

  Widget districtDropdown(ProfileItem item,shippingAddress,district) {
//    final shippingAddress = Provider.of<ShippingAddress>(context);
//    Map<String,dynamic> district = shippingAddress.allAreas;
    return Consumer<ShippingAddress>(
      builder: (
          final BuildContext context,
          final ShippingAddress address,
          final Widget child,
          ) {
        return DropdownButtonFormField(

          isExpanded: true,
          icon: Icon(Icons.local_gas_station),
          hint: Text('Select area'),
          value: shippingAddress.selectedArea,
          onChanged: (newValue) {
            shippingAddress.selectedArea = newValue;
          },
          onSaved: (value){
            item = ProfileItem(
              name: item.name,
              gender: item.gender,
              email: item.email,
              mobileNumber: item.mobileNumber,
              address: item.address,
              city: item.city,
              areaId: shippingAddress.selectedArea,
              contactPerson: item.contactPerson,
              contactPersonMobileNumber:
              item.contactPersonMobileNumber,
            );
          },
          items: _areaMenuItems(district),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final shippingAddress = Provider.of<ShippingAddress>(context);
    Map<String,dynamic> district = shippingAddress.allAreas;
    return Scaffold(
      appBar: AppBar(
        title: Text('Update profile information'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveForm,
          )
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _form,
                child: ListView(
                  children: <Widget>[
                    TextFormField(
                      initialValue: _initValues['name'],
                      decoration: InputDecoration(labelText: 'User name'),
//                textInputAction: TextInputAction.next,
//              onFieldSubmitted: (_){},
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'please enter a name';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _currentProfile = ProfileItem(
                          name: value,
                          gender: _currentProfile.gender,
                          email: _currentProfile.email,
                          mobileNumber: _currentProfile.mobileNumber,
                          address: _currentProfile.address,
                          city: _currentProfile.city,
                          areaId: _currentProfile.areaId,
                          contactPerson: _currentProfile.contactPerson,
                          contactPersonMobileNumber:
                              _currentProfile.contactPersonMobileNumber,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['email'],
                      decoration: InputDecoration(labelText: 'Email address'),
//                textInputAction: TextInputAction.next,
//                onFieldSubmitted: (_){},
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'please enter your email address';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _currentProfile = ProfileItem(
                          name: _currentProfile.name,
                          gender: _currentProfile.gender,
                          email: value,
                          mobileNumber: _currentProfile.mobileNumber,
                          address: _currentProfile.address,
                          city: _currentProfile.city,
                          areaId: _currentProfile.areaId,
                          contactPerson: _currentProfile.contactPerson,
                          contactPersonMobileNumber:
                              _currentProfile.contactPersonMobileNumber,
                        );
                      },
                    ),
                    TextFormField(
                      initialValue: _initValues['mobileNumber'],
                      decoration: InputDecoration(labelText: 'Mobile number'),
//                textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {},
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'please enter mobile number';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _currentProfile = ProfileItem(
                          name: _currentProfile.name,
                          gender: _currentProfile.gender,
                          email: _currentProfile.email,
                          mobileNumber: value,
                          address: _currentProfile.address,
                          city: _currentProfile.city,
                          areaId: _currentProfile.areaId,
                          contactPerson: _currentProfile.contactPerson,
                          contactPersonMobileNumber:
                              _currentProfile.contactPersonMobileNumber,
                        );
                      },
                    ),
                    districtDropdown(_currentProfile,shippingAddress,district),
                    AreaDropDown(_currentProfile),
                  ],
                ),
              ),
            ),
    );
  }
}


class DistrictDropDown extends StatelessWidget {

  ProfileItem item;
  DistrictDropDown(this.item);

  String selectedDistrict;
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

    Map<String,dynamic> district = shippingAddress.allDistricts;
    return Consumer<ShippingAddress>(
      builder: (
          final BuildContext context,
          final ShippingAddress address,
          final Widget child,
          ) {
        return DropdownButtonFormField(
          isExpanded: true,
          icon: Icon(Icons.location_city),
          hint: Text('Select district'),
          value: shippingAddress.selectedDistrict,
          onChanged: (newValue) {
            shippingAddress.selectedDistrict = newValue;
            shippingAddress.selectedArea = null;
          },
          onSaved: (value){
            item = ProfileItem(
              name: item.name,
              gender: item.gender,
              email: item.email,
              mobileNumber: item.mobileNumber,
              address: item.address,
              city: shippingAddress.selectedDistrict,
              areaId: item.areaId,
              contactPerson: item.contactPerson,
              contactPersonMobileNumber:
              item.contactPersonMobileNumber,
            );
          },

          items: _districtMenuItems(district),
        );
      },
    );
  }
}

class AreaDropDown extends StatelessWidget {
  ProfileItem item;
  AreaDropDown(this.item);
  String selectedArea;
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

  @override
  Widget build(final BuildContext context) {
    final shippingAddress = Provider.of<ShippingAddress>(context);
    Map<String,dynamic> district = shippingAddress.allAreas;
    return Consumer<ShippingAddress>(
      builder: (
          final BuildContext context,
          final ShippingAddress address,
          final Widget child,
          ) {
        return DropdownButtonFormField(

          isExpanded: true,
          icon: Icon(Icons.local_gas_station),
          hint: Text('Select area'),
          value: shippingAddress.selectedArea,
          onChanged: (newValue) {
            shippingAddress.selectedArea = newValue;
          },
          onSaved: (value){
            item = ProfileItem(
              name: item.name,
              gender: item.gender,
              email: item.email,
              mobileNumber: item.mobileNumber,
              address: item.address,
              city: item.city,
              areaId: shippingAddress.selectedArea,
              contactPerson: item.contactPerson,
              contactPersonMobileNumber:
              item.contactPersonMobileNumber,
            );
          },
          items: _areaMenuItems(district),
        );
      },
    );
  }
}
