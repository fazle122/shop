import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert' show json;
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:shoptempdb/base_state.dart';
import 'package:intl/intl.dart';



class OrderFilterDialog extends StatefulWidget {

  @override
  State<StatefulWidget> createState() {
    return _OrderFilterDialogState();
  }
}

class _OrderFilterDialogState extends BaseState<OrderFilterDialog> {

  DateTime _from;
  DateTime _to;
  final format = DateFormat('yyyy-MM-dd');

  static const orderStatus = <String>[
    'Approved',
    'Declined',
    'Pending',
    'Requested for Cancellation',
    'Cancelled'
  ];

  Map<String,dynamic> _defaultFilters = Map();


  List _mySelectedStatus;
  List<Map> dataSource = [

    {
      "display": "Approved",
      "value": "Approved",
    },
    {
      "display": "Declined",
      "value": "Declined",
    },
    {
      "display": "Pending",
      "value": "Pending",
    },
    {
      "display": "Requested for Cancellation",
      "value": "Requested for Cancellation",
    },
    {
      "display": "Cancelled",
      "value": "Cancelled",
    },
  ];

  @override
  void initState() {
    _mySelectedStatus = [];
    _defaultFilters['status'] = ['Pending','Requested for Cancellation'];
    _getStatusList();
    super.initState();
  }

  _getStatusList()async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    var list = pref.getString('statusList');
    if(list != null){
      setState(() {
        _mySelectedStatus = json.decode(list);
      });
    }
  }



  List<DropdownMenuItem> _menuItems(Map<dynamic, dynamic> items) {
    List<DropdownMenuItem> itemWidgets = List();
    items.forEach((key, value) {
      itemWidgets.add(DropdownMenuItem(
//        key: key,
        value: key,
        child: Text(value),
      ));
    });
    return itemWidgets;
  }

  List<DropdownMenuItem<String>> _statusMenuItems(Map<dynamic, dynamic> items) {
    List<DropdownMenuItem> itemWidgets = List();
    items.forEach((key, value) {
      itemWidgets.add(DropdownMenuItem(
//        key: key,
        value: key,
        child: Text(value),
      ));
    });
    return itemWidgets;
  }

  Widget _alertDialog(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(5.0))),
//      contentPadding: EdgeInsets.all(15.0),

//      titlePadding: EdgeInsets.only(left:20.0,right: 20.0),
      title: Container(
        margin: EdgeInsets.only(left: 40.0, right: 40.0),
        padding: EdgeInsets.all(0.0),
        child: Center(
          child: Text('Filter options'),
        ),
      ),
      content: SingleChildScrollView(
        padding: EdgeInsets.all(0.0),
        child: Column(
//          mainAxisAlignment: MainAxisAlignment.start,
//          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    margin: EdgeInsets.all(3.0),
                    child: Text(
                      'From date',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13.0),
                    )),
                Container(
                  child: DateTimeField(
                    textAlign: TextAlign.start,
                    format: format,
                    onChanged: (dt) {
                      setState(() {
                        _from = dt;
                        print(_from.toString());
                      });
                    },
                    decoration: InputDecoration(
                        labelText: 'From date',
                        prefixIcon: Icon(
                          Icons.date_range,
                          color: Theme.of(context).primaryColorDark,
                        ),
                        contentPadding:
                        EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                    onShowPicker: (context, currentValue) {
                      return showDatePicker(
                          context: context,
                          firstDate: DateTime(1900),
                          initialDate: currentValue ?? DateTime.now(),
                          lastDate: DateTime(2100));
                    },
                  ),
                ),
              ],
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                    margin: EdgeInsets.all(3.0),
                    child: Text(
                      'To date',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13.0),
                    )),
                Container(
                    child: DateTimeField(
                      enabled: _from == null ? false : true,
                      textAlign: TextAlign.start,
                      format: format,
                      onChanged: (dt) {
                        setState(() {
                          _to = dt;
                          print(_to.toString());
                        });
                      },
                      decoration: InputDecoration(
                          labelText: 'To date',
                          prefixIcon: Icon(
                            Icons.date_range,
                            color: Theme.of(context).primaryColorDark,
                          ),
                          contentPadding: EdgeInsets.fromLTRB(
                              20.0, 15.0, 20.0, 15.0),
                          border: OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(5.0))),
                      onShowPicker: (context, currentValue) {
                        return showDatePicker(
                            context: context,
                            firstDate: _from,
//                          initialDate: currentValue ?? DateTime.now(),
                            initialDate:
                            _from.compareTo(DateTime.now()) < 1
                                ? DateTime.now()
                                : _from,
                            lastDate: DateTime(2100));
                      },
                    ),
                  )
              ],
            ),
            SizedBox(
              height: 20.0,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        width: 100.0,
                        height: 35.0,
                        decoration: ShapeDecoration(
                          color: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: 1.0, style: BorderStyle.solid,color: Colors.grey.shade500),
                            borderRadius: BorderRadius.all(Radius.circular(3.0)),
                          ),
                        ),
                        child: Center(
                            child: Text(
                              'Cancel',
                              style:
                              TextStyle(color: Theme.of(context).primaryColorDark),
                            )),
                      ),
                      onTap: () {
                        Navigator.of(context).pop(_defaultFilters);
                      },
                    ),
                    InkWell(
                      child: Container(
                        width: 100.0,
                        height: 35.0,
                        decoration: ShapeDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: 1.0, style: BorderStyle.solid,color: Colors.grey.shade500),
                            borderRadius: BorderRadius.all(Radius.circular(5.0)),
                          ),
                        ),
                        child: Center(
                            child: Text(
                              'Apply',
                              style: TextStyle(color: Colors.white),
                            )),
                      ),
                      onTap: () async{
                        Map<String, dynamic> filters = Map();
                        filters['invoice_from_date'] = _from;
                        filters['invoice_to_date'] = _to;
                        Navigator.of(context).pop(filters);
                      },
                    ),
                    SizedBox(height: 20.0)
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _alertDialog(context);
  }

}
