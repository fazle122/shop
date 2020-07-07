import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/product.dart';
import 'package:shoptempdb/providers/shipping_address.dart';
import 'package:shoptempdb/screens/products_overview_screen.dart';
import 'package:dio/dio.dart';


class TestWidget extends StatefulWidget {
  final AddressItem addressItem;

  TestWidget({this.addressItem});
  _TestWidgetState createState() => _TestWidgetState();
}

class _TestWidgetState
    extends State<TestWidget> {
  final _form = GlobalKey<FormState>();

  TextEditingController _phoneEditController;
  TextEditingController _addressEditController;
  String selectedArea;
  String selectedDistrict;

  var _isInit = true;
  var _isLoading = false;

  String mobileNumber;
  String homeAddress;

  @override
  void initState(){
    _phoneEditController = TextEditingController();
    _phoneEditController.text = widget.addressItem.phoneNumber;
    _addressEditController = TextEditingController();
    _addressEditController.text = widget.addressItem.shippingAddress;
    setState(() {
      selectedDistrict = widget.addressItem.city;
//      selectedArea = widget.addressItem.areaId;

    });
    print(selectedArea);
    super.initState();
  }


  @override
  void didChangeDependencies(){
    if(_isInit) {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });
      Provider.of<ShippingAddress>(context).fetchDistrictList().then((_){
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }


  Widget phoneField() {
    return TextField(
      controller: _phoneEditController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        prefixIcon: Icon(
          Icons.phone_android,
          color: Theme.of(context).primaryColorDark,
        ),
        hintText: 'Mobile number',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
      ),
    );
  }


  Widget addressField() {
    return TextField(
      controller: _addressEditController,
      keyboardType: TextInputType.multiline,
      minLines: 2,
      maxLines: 3,
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


  Widget districtDropdown(var shippingAddress,Map<String, dynamic> district){
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
            child:DropdownButtonHideUnderline(
              child: DropdownButton(
                isExpanded: true,
                hint: Text(selectedDistrict),
//                value: selectedDistrict,
                onChanged: (newValue) {
                  setState(() {
                    selectedDistrict = newValue;
                  });
//                  selectedArea = null;
                  Provider.of<ShippingAddress>(context,listen: false).fetchAreaList(selectedDistrict);
                },
                items: _districtMenuItems(district),
              ),
            )
        ),
        Container(
          padding: EdgeInsets.only(top: 12.0, left: 12.0),
          child: Icon(
            Icons.location_city,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }


  Widget areaDropdown(var shippingAddress,Map<String, dynamic> areas) {
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
            child: DropdownButtonHideUnderline(
              child: DropdownButton(
                isExpanded: true,
                hint: selectedArea != null ?Text(selectedArea):Text('select area'),
                value: selectedArea,
                onChanged: (newValue) {
                  setState(() {
                    selectedArea = newValue;
                  });
                },
                items: _areaMenuItems(areas),
              ),
            )
        ),
        Container(
          margin: EdgeInsets.only(top: 12.0, left: 12.0),
          child: Icon(
            Icons.local_gas_station,
            color: Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final shippingAddress = Provider.of<ShippingAddress>(context);

    Map<String, dynamic> district = shippingAddress.allDistricts;
    Map<String, dynamic> areas = Map();
    return AlertDialog(
      title: Center(
        child: Text('Update address'),
      ),
      content: selectedDistrict == null? Center(child: CircularProgressIndicator(),):SingleChildScrollView(
          child: _isLoading
              ? Center(
            child: CircularProgressIndicator(),
          )
              :
          Form(key:_form,
            child:Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                phoneField(),
                SizedBox(
                  height: 15.0,
                ),
                districtDropdown(shippingAddress,shippingAddress.allDistricts),
                SizedBox(
                  height: 15.0,
                ),
                areaDropdown(shippingAddress,shippingAddress.allAreas),
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
                    color: Theme.of(context).primaryColor,
                    textColor: Colors.white,
                    child: Text("Confirm".toUpperCase(),
                        style: TextStyle(fontSize: 14)),
                    onPressed: () async{
                      FormData data = new FormData();
                      data.add('city',selectedDistrict);
                      data.add('area_id', selectedArea.toString());
                      data.add('shipping_address_line', _addressEditController.text);
                      data.add('mobile_no', _phoneEditController.text);

                      setState(() {
                        _isLoading = true;
                      });
                      final response = await Provider.of<ShippingAddress>(context, listen: false).createShippingAddress1(widget.addressItem.id.toString(),data);
                      if (response != null) {
                        setState(() {
                          _isLoading = false;
                        });
                        selectedDistrict = null;
                        selectedArea = null;
                        Navigator.of(context).pop();
                      } else {
                        showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text('Order confirmation'),
                              content: Text(
                                  'something went wrong!!! Please try again'),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('ok'),
                                  onPressed: () {
                                    Navigator.of(context).pushNamed(
                                        ProductsOverviewScreen
                                            .routeName);
                                  },
                                ),
                              ],
                            ));
                      }
                    },
                  ),
                )
              ],
            ),)

      ),
    );
  }

}

//class _TestWidgetState extends State<TestWidget>{
//
//  TextEditingController _phoneEditController;
//  TextEditingController _addressEditController;
//  String selectedArea;
//  String selectedDistrict;
//
//  var _isInit = true;
//  var _isLoading = false;
//
//  String mobileNumber;
//  String homeAddress;
//
//  @override
//  void initState(){
//    _phoneEditController = TextEditingController();
//    _phoneEditController.text = widget.addressItem.phoneNumber;
//    _addressEditController = TextEditingController();
//    _addressEditController.text = widget.addressItem.shippingAddress;
//    selectedArea = widget.addressItem.areaId;
//    print(selectedArea);
//    super.initState();
//  }
//
//
//  @override
//  void didChangeDependencies(){
//    if(_isInit) {
//      if (!mounted) return;
//      setState(() {
//        _isLoading = true;
//      });
//      Provider.of<ShippingAddress>(context).fetchDistrictList().then((_){
//        if (!mounted) return;
//        setState(() {
//          _isLoading = false;
//        });
//      });
//    }
//    _isInit = false;
//    super.didChangeDependencies();
//  }
//
//
//  Widget phoneField() {
//    return TextField(
//      controller: _phoneEditController,
//      keyboardType: TextInputType.number,
//      decoration: InputDecoration(
//        prefixIcon: Icon(
//          Icons.phone_android,
//          color: Theme.of(context).primaryColorDark,
//        ),
//        hintText: 'Mobile number',
//        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
//      ),
//    );
//  }
//
//
//  Widget addressField() {
//    return TextField(
//      controller: _addressEditController,
//      keyboardType: TextInputType.multiline,
//      minLines: 2,
//      maxLines: 3,
//      decoration: InputDecoration(
//        prefixIcon: Icon(
//          Icons.home,
//          color: Theme.of(context).primaryColorDark,
//        ),
//        hintText: 'Home address',
//        border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
//      ),
//    );
//  }
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
//  List<DropdownMenuItem> _areaMenuItems(Map<String, dynamic> items) {
//    List<DropdownMenuItem> itemWidgets = List();
//    items.forEach((key, value) {
//      itemWidgets.add(DropdownMenuItem(
//        value: key,
//        child: Text(value),
//      ));
//    });
//    return itemWidgets;
//  }
//
//
//  Widget districtDropdown(var shippingAddress,Map<String, dynamic> district){
////    return Consumer<ShippingAddress>(
////      builder: (
////          final BuildContext context,
////          final ShippingAddress address,
////          final Widget child,
////          ) {
//    return Stack(
//      children: <Widget>[
//        Container(
//            decoration: ShapeDecoration(
//              shape: RoundedRectangleBorder(
//                side: BorderSide(width: 1.0, style: BorderStyle.solid),
//                borderRadius: BorderRadius.all(Radius.circular(5.0)),
//              ),
//            ),
//            padding: EdgeInsets.only(left: 44.0, right: 10.0),
////              margin: EdgeInsets.only(left: 16.0, right: 16.0),
//            child:DropdownButtonHideUnderline(
//              child: DropdownButton(
//
//                isExpanded: true,
////                icon: Icon(Icons.location_city),
//                hint: Text('Select district'),
//                value: selectedDistrict,
//                onChanged: (newValue) {
//                  setState(() {
//                    selectedDistrict = newValue;
//
//                  });
//                  selectedArea = null;
//                  Provider.of<ShippingAddress>(context,listen: false).fetchAreaList(selectedDistrict);
//                },
//                items: _districtMenuItems(district),
//              ),
//            )
//        ),
//        Container(
//          padding: EdgeInsets.only(top: 12.0, left: 12.0),
//          child: Icon(
//            Icons.location_city,
//            color: Theme.of(context).primaryColor,
////              size: 20.0,
//          ),
//        ),
//      ],
//    );
////      },
////    );
//  }
//
//
//  Widget areaDropdown(var shippingAddress,Map<String, dynamic> areas) {
////    return Consumer<ShippingAddress>(
////      builder: (
////          final BuildContext context,
////          final ShippingAddress address,
////          final Widget child,
////          ) {
//    return Stack(
//      children: <Widget>[
//        Container(
//            decoration: ShapeDecoration(
//              shape: RoundedRectangleBorder(
//                side: BorderSide(width: 1.0, style: BorderStyle.solid),
//                borderRadius: BorderRadius.all(Radius.circular(5.0)),
//              ),
//            ),
//            padding: EdgeInsets.only(left: 44.0, right: 10.0),
//            child: DropdownButtonHideUnderline(
//              child: DropdownButton(
//                isExpanded: true,
//                hint: Text('Select area'),
//                value: selectedArea,
//                onChanged: (newValue) {
//                  setState(() {
//                    selectedArea = newValue;
//                  });
//                },
//                items: _areaMenuItems(areas),
//              ),
//            )
//        ),
//        Container(
//          margin: EdgeInsets.only(top: 12.0, left: 12.0),
//          child: Icon(
//            Icons.local_gas_station,
//            color: Theme.of(context).primaryColor,
////              size: 20.0,
//          ),
//        ),
//      ],
//    );
////      },
////    );
//  }
//
//  @override
//  Widget build(BuildContext context) {
//    final shippingAddress = Provider.of<ShippingAddress>(context);
//
//    return Scaffold(
//      appBar: AppBar(title: Text('Test window'),),
//      body: SingleChildScrollView(
//        child: _isLoading?Center(child: CircularProgressIndicator(),):Column(
//          mainAxisSize: MainAxisSize.min,
//          children: <Widget>[
//            phoneField(),
//            SizedBox(height: 15.0,),
//            districtDropdown(shippingAddress, shippingAddress.allDistricts),
//            SizedBox(height: 15.0,),
//            areaDropdown(shippingAddress, shippingAddress.allAreas),
//            SizedBox(height: 15.0,),
//            addressField(),
//            SizedBox(height: 25.0,),
//            Center(child: Text('** all fields are mandatory',style: TextStyle(color: Colors.red,fontSize: 12.0),),),
//            SizedBox(height: 10.0,),
//            Container(
//              child: RaisedButton(
//                shape: RoundedRectangleBorder(
//                    borderRadius: BorderRadius.circular(25.0),
//                    side: BorderSide(color: Colors.grey)),
//                onPressed: () async{
//
//                  FormData data = new FormData();
//                  data.add('area_id', selectedArea.toString());
//                  data.add('shipping_address_line', homeAddress);
//                  data.add('mobile_no', mobileNumber);
//
//                  setState(() {
//                    _isLoading = true;
//                  });
//                  final response = await Provider.of<ShippingAddress>(context, listen: false).createShippingAddress1(widget.addressItem.id.toString(),data);
//                  if (response != null) {
//                    setState(() {
//                      _isLoading = false;
//                    });
//                    selectedDistrict = null;
//                    selectedArea = null;
//                    Navigator.of(context).pop();
//                  } else {
//                    showDialog(
//                        context: context,
//                        builder: (ctx) => AlertDialog(
//                          title: Text('Order confirmation'),
//                          content: Text(
//                              'something went wrong!!! Please try again'),
//                          actions: <Widget>[
//                            FlatButton(
//                              child: Text('ok'),
//                              onPressed: () {
//                                Navigator.of(context).pushNamed(
//                                    ProductsOverviewScreen
//                                        .routeName);
//                              },
//                            ),
//                          ],
//                        ));
//                  }
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
//}
