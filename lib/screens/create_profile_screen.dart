import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/shipping_address.dart';
import 'package:shoptempdb/screens/delivery_address_screen.dart';
import 'package:shoptempdb/screens/products_overview_screen.dart';
import 'package:shoptempdb/utility/util.dart';

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
          .updateProfileInfo(addressLine, mobileNo, name, email, city, areaID,
      );
      if (response != null) {
        Navigator.of(context).pushReplacementNamed(DeliveryAddressScreen.routeName);
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
              ),

              SizedBox(height: 5.0,),


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
                        width: MediaQuery.of(context).size.width * 2/5,
                        child: InkWell(
                          child: Text('update profile latter',style: TextStyle(decoration: TextDecoration.underline),),
                          onTap: (){
                            Navigator.pushReplacementNamed(context, ProductsOverviewScreen.routeName);
                          },
                        ),
                      )
                    ],
                  )
              ),
            ],
          ),
        ),
      )),
    );
  }
}

