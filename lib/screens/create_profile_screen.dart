import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/shipping_address.dart';
import 'package:shoptempdb/screens/delivery_address_screen.dart';
import 'package:shoptempdb/screens/profile_screen.dart';

class CreateProfileScreen extends StatefulWidget {
  static const routeName = '/update_profile';

  @override
  _CreateProfileScreenState createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  var _isLoading = false;
  final _form = GlobalKey<FormState>();
  String selectedDistrict;
  String selectedArea;
  String selectedAreaFromLocal;

  String mobileNo;
  // String homeAddress;
  String name;
  String email;
  String addressLine;
  String city;
  int areaID;



  @override
  void initState() {
    Provider.of<ShippingAddress>(context, listen: false).fetchDistrictList();

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  getAreaName(String areaId) async {
    final data = await Provider.of<ShippingAddress>(context, listen: false)
        .fetchAreaName(areaId.toString());
    setState(() {
      selectedAreaFromLocal = data;
    });
  }

  Future<void> _saveForm(var shippingAddress) async {
    final isValid = _form.currentState.validate();
    if (!isValid) {
      return;
    }
    _form.currentState.save();
    setState(() {
      _isLoading = true;
    });

    if (shippingAddress.selectedArea != null && shippingAddress.selectedDistrict != null) {
      setState(() {
        city = shippingAddress.selectedDistrict;
        areaID = int.parse(shippingAddress.selectedArea);
      });
    }

    try {
      Map<String, dynamic> response =
      await Provider.of<ShippingAddress>(context, listen: false)
          .updateProfileInfo1(addressLine, mobileNo, name, email, city, areaID,
      );
      if (response != null) {
        // Navigator.pushNamed(context, DeliveryAddressScreen.routeName);
        Navigator.of(context).pushReplacementNamed(DeliveryAddressScreen.routeName);
        // String msg = '';
        // for (int i = 0; i < response['data'].value.length; i++) {
        //   for (int j = 0; j < response['data'][''].length; j++) {
        //     msg += 'error definition goes here';
        //   }
        //   for (int j = 0; j < response['data'][''].length; j++) {
        //     msg += 'error definition goes here';
        //   }
        // }
        // _showErrorDialog(msg);
      }
    } catch (error) {
      const errorMessage = 'Some thing wrong, please try again later';
      _showErrorDialog(errorMessage);
    }
    shippingAddress.selectedDistrict = null;
    shippingAddress.selectedArea = null;

  }

  void _showErrorDialog(String message) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
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

  Widget nameField() {
    return Container(
        width: MediaQuery.of(context).size.width * 4/5,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.5/5,
              child: Text('Name'),
            ),
            Container(
                width: MediaQuery.of(context).size.width * 3/5,
                height: 40.0,
                child: TextFormField(
                  // initialValue: _initValues['name'],
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
                    hintText: 'user name',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2.0)),
                  ),
                )),
          ],
        ));
  }

  Widget phoneField(String ph) {
    return Container(
        width: MediaQuery.of(context).size.width * 4/5,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.5/5,
              child: Text('Phone'),
            ),
            Container(
                width: MediaQuery.of(context).size.width * 3/5,
                height: 40.0,
                child: TextFormField(
                  initialValue: ph,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'please enter mobile number';
                    } else if (value.length > 11 || value.length < 11) {
                      return 'please provide a valid mobile number';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    mobileNo = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'mobile number',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2.0)),
                  ),
                )),
          ],
        ));
  }

  Widget emailField() {
    return Container(
        width: MediaQuery.of(context).size.width * 4/5,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.5/5,
              child: Text('Email'),
            ),
            Container(
                width: MediaQuery.of(context).size.width * 3/5,
                height: 40.0,
                child: TextFormField(
                  // initialValue: _initValues['email'],
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
                    hintText: 'email address',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2.0)),
                  ),
                )),
          ],
        ));
  }

  Widget addressField() {
    return Container(
        width: MediaQuery.of(context).size.width * 4/5,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.7/5,
              child: Text('Address'),
            ),
            Container(
                width: MediaQuery.of(context).size.width * 3/5,
                height: 80.0,
                child: TextFormField(
                  // initialValue: _initValues['address'],
                  keyboardType: TextInputType.multiline,
                  maxLines: 2,
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'please enter your home address';
                    }
                    return null;
                  },
                  onSaved: (value) {
                    // homeAddress = value;
                    addressLine = value;
                  },
                  decoration: InputDecoration(
                    hintText: 'Home address',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(2.0)),
                  ),
                )),
          ],
        ));
  }

  Widget districtDropdown(var shippingAddress, Map<String, dynamic> district) {
    return Container(
        width: MediaQuery.of(context).size.width * 4/5,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.5/5,
              child: Text('City'),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 3/5,
              height: 80.0,
              child: Consumer<ShippingAddress>(
                builder: (
                  final BuildContext context,
                  final ShippingAddress address,
                  final Widget child,
                ) {
                  return DropdownButtonFormField(
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
//                enabledBorder: UnderlineInputBorder(
//                    borderSide: BorderSide(color: Colors.white))
                    ),
                    hint: Text('Select city'),
                    value: shippingAddress.selectedDistrict,
                    onSaved: (value) {
                      shippingAddress.selectedDistrict = value;
                      // if (shippingAddress.selectedDistrict == null) {
                      //   shippingAddress.selectedDistrict = _initValues['city'];
                      // } else {
                      //   shippingAddress.selectedDistrict = value;
                      // }
                    },
                    validator: (value) {
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
                  );
                },
              ),
            )
          ],
        ));
  }

  Widget areaDropdown(var shippingAddress, Map<String, dynamic> areas) {
    return Container(
      width: MediaQuery.of(context).size.width * 4/5,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width * 0.5/5,
            child: Text('Area'),
          ),
          Container(
              width: MediaQuery.of(context).size.width * 3/5,
              height: 80.0,
              child: Consumer<ShippingAddress>(
                builder: (
                  final BuildContext context,
                  final ShippingAddress address,
                  final Widget child,
                ) {
                  return DropdownButtonFormField(
                    isExpanded: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
//                enabledBorder: UnderlineInputBorder(
//                    borderSide: BorderSide(color: Colors.white))
                    ),
                    hint: Text('Select area'),
                    value: shippingAddress.selectedArea,
                    onSaved: (value) {
                      shippingAddress.selectedArea = value;
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'please choose area';
                      }
                      return null;
                    },
                    onChanged: (newValue) {
                      shippingAddress.selectedArea = newValue;
                    },
                    items: _areaMenuItems(areas),
                  );
                },
              ))
        ],
      ),
    );
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
        value: key,
        child: Text(value),
      ));
    });
    return itemWidgets;
  }

  @override
  Widget build(BuildContext context) {
    var ph = ModalRoute.of(context).settings.arguments as String;
    final shippingAddress = Provider.of<ShippingAddress>(context);
    Map<String, dynamic> district = shippingAddress.allAreas;
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Profile'),
      ),
      body:
          // _isLoading ? Center(child: CircularProgressIndicator(),) :
          SingleChildScrollView(
              child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.only(left: 20.0, right: 20.0),
        child: Form(
          key: _form,
          child:
              // selectedAreaFromLocal == null ? Center(child: CircularProgressIndicator(),) :
              Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 25.0,
              ),
              nameField(),
              SizedBox(height: 15.0,),
              phoneField(ph),
              SizedBox(height: 15.0,),
              emailField(),
              SizedBox(height: 15.0,),
              districtDropdown(shippingAddress, shippingAddress.allDistricts),
              // SizedBox(height: 15.0,),
              areaDropdown(shippingAddress, shippingAddress.allAreas),
              // SizedBox(height: 15.0,),
              addressField(),
              SizedBox(height: 25.0,),

              Container(
                  width: MediaQuery.of(context).size.width * 4/5,
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 1/5,
                      // child: Text(''),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width * 1.2/5,
                      // padding: EdgeInsets.only(left: MediaQuery.of(context).size.width * 1/5),
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(2.0),
                            side: BorderSide(color: Colors.grey)),
                        onPressed: () async {
                          _saveForm(shippingAddress);
                        },
                        color: Colors.red,
                        textColor: Colors.white,
                        child: Text('Submit', style: TextStyle(fontSize: 14)),
                      ),
                    )
                  ],

                )
              )
            ],
          ),
        ),
      )),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:shoptempdb/providers/shipping_address.dart';
// import 'package:shoptempdb/screens/profile_screen.dart';
//
// class ProfileUpdateScreen extends StatefulWidget {
//   static const routeName = '/update_profile';
//
//   @override
//   _ProfileUpdateScreenState createState() => _ProfileUpdateScreenState();
// }
//
// class _ProfileUpdateScreenState extends State<ProfileUpdateScreen> {
//   var _isLoading = false;
//   final _form = GlobalKey<FormState>();
//   String selectedDistrict;
//   String selectedArea;
//   String selectedAreaFromLocal;
//
//   var _currentProfile = ProfileItem(
//     id: '',
//     name: '',
//     gender: '',
//     email: '',
//     mobileNumber: '',
//     address: '',
//     city:'',
//     areaId: '',
//     contactPerson: '',
//     contactPersonMobileNumber: '',
//   );
//   var _initValues = {
//     'name': '',
//     'gender': '',
//     'email': '',
//     'mobileNumber': '',
//     'address': '',
//     'city':'',
//     'areaId': 0,
//     'contactPerson': '',
//     'contactPersonMobileNumber': '',
//   };
//
//   @override
//   void didChangeDependencies() {
//     _currentProfile = Provider.of<ShippingAddress>(context, listen: false).getProfileInfo();
//     Provider.of<ShippingAddress>(context,listen: false).fetchDistrictList();
//     _initValues = {
//       'name': _currentProfile.name,
//       'gender': _currentProfile.gender,
//       'email': _currentProfile.email,
//       'mobileNumber': _currentProfile.mobileNumber,
//       'address': _currentProfile.address,
//       'city':_currentProfile.city,
//       'areaId': _currentProfile.areaId,
//       'contactPerson': _currentProfile.contactPerson,
//       'contactPersonMobileNumber': _currentProfile.contactPersonMobileNumber,
//     };
//     setState(() {
//       selectedDistrict = _initValues['city'];
//     });
//     getAreaName(_currentProfile.areaId);
//     super.didChangeDependencies();
//   }
//
//   getAreaName(String areaId) async{
//     final data = await Provider.of<ShippingAddress>(context, listen: false).fetchAreaName(areaId.toString());
//     setState(() {
//       selectedAreaFromLocal = data;
//     });
//   }
//
//   Future<void> _saveForm() async {
//     final isValid = _form.currentState.validate();
//     if (!isValid) {
//       return;
//     }
//     _form.currentState.save();
//     setState(() {
//       _isLoading = true;
//     });
//     try {
//       await Provider.of<ShippingAddress>(context, listen: false).updateProfileInfo(_currentProfile);
//     } catch (error) {
//       await showDialog(
//         context: context,
//         barrierDismissible: false,
//         builder: (ctx) => AlertDialog(
//           title: Text('An error occurred!'),
//           content: Text(error.toString()),
//           actions: <Widget>[
//             FlatButton(
//               child: Text('Okay'),
//               onPressed: () {
//                 Navigator.of(ctx).pop();
//               },
//             )
//           ],
//         ),
//       );
//     }
//     setState(() {
//       _isLoading = false;
//     });
// //    Navigator.pop(context, true);
//     Navigator.of(context).pushReplacementNamed(ProfilePage.routeName);
//   }
//
//   List<DropdownMenuItem> _areaMenuItems(Map<String, dynamic> items) {
//     List<DropdownMenuItem> itemWidgets = List();
//     items.forEach((key, value) {
//       itemWidgets.add(DropdownMenuItem(
//         value: value,
//         child: Text(value),
//       ));
//     });
//     return itemWidgets;
//   }
//
//   Widget districtDropdown(ProfileItem item,shippingAddress,district) {
// //    final shippingAddress = Provider.of<ShippingAddress>(context);
// //    Map<String,dynamic> district = shippingAddress.allAreas;
//     return Consumer<ShippingAddress>(
//       builder: (
//           final BuildContext context,
//           final ShippingAddress address,
//           final Widget child,
//           ) {
//         return DropdownButtonFormField(
//
//           isExpanded: true,
//           icon: Icon(Icons.local_gas_station),
//           hint: Text('Select area'),
//           value: shippingAddress.selectedArea,
//           onChanged: (newValue) {
//             shippingAddress.selectedArea = newValue;
//           },
//           onSaved: (value){
//             item = ProfileItem(
//               name: item.name,
//               gender: item.gender,
//               email: item.email,
//               mobileNumber: item.mobileNumber,
//               address: item.address,
//               city: item.city,
//               areaId: shippingAddress.selectedArea,
//               contactPerson: item.contactPerson,
//               contactPersonMobileNumber:
//               item.contactPersonMobileNumber,
//             );
//           },
//           items: _areaMenuItems(district),
//         );
//       },
//     );
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     final shippingAddress = Provider.of<ShippingAddress>(context);
//     Map<String,dynamic> district = shippingAddress.allAreas;
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Update profile information'),
//         actions: <Widget>[
//           IconButton(
//             icon: Icon(Icons.save),
//             onPressed: _saveForm,
//           )
//         ],
//       ),
//       body: _isLoading
//           ? Center(
//               child: CircularProgressIndicator(),
//             )
//           : Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Form(
//                 key: _form,
//                 child: ListView(
//                   children: <Widget>[
//                     TextFormField(
//                       initialValue: _initValues['name'],
//                       decoration: InputDecoration(labelText: 'User name'),
// //                textInputAction: TextInputAction.next,
// //              onFieldSubmitted: (_){},
//                       validator: (value) {
//                         if (value.isEmpty) {
//                           return 'please enter a name';
//                         }
//                         return null;
//                       },
//                       onSaved: (value) {
//                         _currentProfile = ProfileItem(
//                           name: value,
//                           gender: _currentProfile.gender,
//                           email: _currentProfile.email,
//                           mobileNumber: _currentProfile.mobileNumber,
//                           address: _currentProfile.address,
//                           city: _currentProfile.city,
//                           areaId: _currentProfile.areaId,
//                           contactPerson: _currentProfile.contactPerson,
//                           contactPersonMobileNumber:
//                               _currentProfile.contactPersonMobileNumber,
//                         );
//                       },
//                     ),
//                     TextFormField(
//                       initialValue: _initValues['email'],
//                       decoration: InputDecoration(labelText: 'Email address'),
// //                textInputAction: TextInputAction.next,
// //                onFieldSubmitted: (_){},
//                       validator: (value) {
//                         if (value.isEmpty) {
//                           return 'please enter your email address';
//                         }
//                         return null;
//                       },
//                       onSaved: (value) {
//                         _currentProfile = ProfileItem(
//                           name: _currentProfile.name,
//                           gender: _currentProfile.gender,
//                           email: value,
//                           mobileNumber: _currentProfile.mobileNumber,
//                           address: _currentProfile.address,
//                           city: _currentProfile.city,
//                           areaId: _currentProfile.areaId,
//                           contactPerson: _currentProfile.contactPerson,
//                           contactPersonMobileNumber:
//                               _currentProfile.contactPersonMobileNumber,
//                         );
//                       },
//                     ),
//                     TextFormField(
//                       initialValue: _initValues['mobileNumber'],
//                       decoration: InputDecoration(labelText: 'Mobile number'),
// //                textInputAction: TextInputAction.next,
//                       onFieldSubmitted: (_) {},
//                       validator: (value) {
//                         if (value.isEmpty) {
//                           return 'please enter mobile number';
//                         }
//                         return null;
//                       },
//                       onSaved: (value) {
//                         _currentProfile = ProfileItem(
//                           name: _currentProfile.name,
//                           gender: _currentProfile.gender,
//                           email: _currentProfile.email,
//                           mobileNumber: value,
//                           address: _currentProfile.address,
//                           city: _currentProfile.city,
//                           areaId: _currentProfile.areaId,
//                           contactPerson: _currentProfile.contactPerson,
//                           contactPersonMobileNumber:
//                               _currentProfile.contactPersonMobileNumber,
//                         );
//                       },
//                     ),
//                     districtDropdown(_currentProfile,shippingAddress,district),
//                     AreaDropDown(_currentProfile),
//                   ],
//                 ),
//               ),
//             ),
//     );
//   }
// }
//
//
// class DistrictDropDown extends StatelessWidget {
//
//   ProfileItem item;
//   DistrictDropDown(this.item);
//
//   String selectedDistrict;
//   List<DropdownMenuItem> _districtMenuItems(Map<String, dynamic> items) {
//     List<DropdownMenuItem> itemWidgets = List();
//     items.forEach((key, value) {
//       itemWidgets.add(DropdownMenuItem(
//         value: value,
//         child: Text(value),
//       ));
//     });
//     return itemWidgets;
//   }
//
//   @override
//   Widget build(final BuildContext context) {
//     final shippingAddress = Provider.of<ShippingAddress>(context);
//
//     Map<String,dynamic> district = shippingAddress.allDistricts;
//     return Consumer<ShippingAddress>(
//       builder: (
//           final BuildContext context,
//           final ShippingAddress address,
//           final Widget child,
//           ) {
//         return DropdownButtonFormField(
//           isExpanded: true,
//           icon: Icon(Icons.location_city),
//           hint: Text('Select district'),
//           value: shippingAddress.selectedDistrict,
//           onChanged: (newValue) {
//             shippingAddress.selectedDistrict = newValue;
//             shippingAddress.selectedArea = null;
//           },
//           onSaved: (value){
//             item = ProfileItem(
//               name: item.name,
//               gender: item.gender,
//               email: item.email,
//               mobileNumber: item.mobileNumber,
//               address: item.address,
//               city: shippingAddress.selectedDistrict,
//               areaId: item.areaId,
//               contactPerson: item.contactPerson,
//               contactPersonMobileNumber:
//               item.contactPersonMobileNumber,
//             );
//           },
//
//           items: _districtMenuItems(district),
//         );
//       },
//     );
//   }
// }
//
// class AreaDropDown extends StatelessWidget {
//   ProfileItem item;
//   AreaDropDown(this.item);
//   String selectedArea;
//   List<DropdownMenuItem> _areaMenuItems(Map<String, dynamic> items) {
//     List<DropdownMenuItem> itemWidgets = List();
//     items.forEach((key, value) {
//       itemWidgets.add(DropdownMenuItem(
//         value: value,
//         child: Text(value),
//       ));
//     });
//     return itemWidgets;
//   }
//
//   @override
//   Widget build(final BuildContext context) {
//     final shippingAddress = Provider.of<ShippingAddress>(context);
//     Map<String,dynamic> district = shippingAddress.allAreas;
//     return Consumer<ShippingAddress>(
//       builder: (
//           final BuildContext context,
//           final ShippingAddress address,
//           final Widget child,
//           ) {
//         return DropdownButtonFormField(
//
//           isExpanded: true,
//           icon: Icon(Icons.local_gas_station),
//           hint: Text('Select area'),
//           value: shippingAddress.selectedArea,
//           onChanged: (newValue) {
//             shippingAddress.selectedArea = newValue;
//           },
//           onSaved: (value){
//             item = ProfileItem(
//               name: item.name,
//               gender: item.gender,
//               email: item.email,
//               mobileNumber: item.mobileNumber,
//               address: item.address,
//               city: item.city,
//               areaId: shippingAddress.selectedArea,
//               contactPerson: item.contactPerson,
//               contactPersonMobileNumber:
//               item.contactPersonMobileNumber,
//             );
//           },
//           items: _areaMenuItems(district),
//         );
//       },
//     );
//   }
// }
