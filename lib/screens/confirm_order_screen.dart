import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/shipping_address.dart';
import 'package:shoptempdb/screens/delivery_address_screen.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:shoptempdb/screens/order_confirmation_screen.dart';


class ConfirmOrderScreen extends StatefulWidget{
  static const routeName = '/confirm_order';

  @override
  State<StatefulWidget> createState() {
    return _ConfirmOrderScreenState();
  }

}


class _ConfirmOrderScreenState extends State<ConfirmOrderScreen>{

  DateTime _deliveryDate;
  TimeOfDay currentTime = TimeOfDay.now();
  final format = DateFormat('yyyy-MM-dd');
  final timeFormat = DateFormat("HH:mm");

  int selectedRadioTile;

  @override
  void initState() {
    super.initState();
    selectedRadioTile = 3;
  }

  setSelectedRadioTile(int val) {
    setState(() {
      selectedRadioTile = val;
    });
  }

  Widget _paymentOptions(BuildContext context) {
    var innerBorder = Border.all(width: 2.0, color: Colors.black.withOpacity(0.3));
    var outerBorder = Border.all(width: 2.0, color: Colors.black.withOpacity(0.0));
    return ListView(
      shrinkWrap: true,
      children: ListTile.divideTiles(
        context: context,
        tiles: [
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Container(
                decoration: BoxDecoration(border: outerBorder, borderRadius: BorderRadius.circular(0.0)),
                child: Container(decoration: BoxDecoration(border: innerBorder, borderRadius: BorderRadius.circular(0.0)),
                  child: ListTile(
                    title: RadioListTile(
                      value: 1,
                      groupValue: selectedRadioTile,
                      title: Row(
                        children: <Widget>[
                          Image.asset('assets/Bkash-Logo.png'),
                          Text('bkash Checkout')
                        ],
                      ),
                      onChanged: (currentAddress) {
                        setSelectedRadioTile(currentAddress);
                      },
                      selected: selectedRadioTile == 1,
                      activeColor: Colors.red,
                    ),
                  ),
                )
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Container(decoration: BoxDecoration(
                border: outerBorder, borderRadius: BorderRadius.circular(0.0)),
                child: Container(
                  decoration: BoxDecoration(
                      border: innerBorder, borderRadius: BorderRadius.circular(0.0)),
                  child: ListTile(
                    title: RadioListTile(
                      value: 2,
                      groupValue: selectedRadioTile,
                      title: Row(
                        children: <Widget>[
                          Image.asset('assets/credit-card-Logo.png'),
                          Text('Credit or debit card')
                        ],
                      ),
                      onChanged: (currentAddress) {
                        setSelectedRadioTile(currentAddress);
                      },
                      selected: selectedRadioTile == 1,
                      activeColor: Colors.red,
                    ),
                  ),
                )
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(0.0),
            child: Container(
                decoration: BoxDecoration(
                    border: outerBorder, borderRadius: BorderRadius.circular(0.0)),
                child: Container(
                  decoration: BoxDecoration(
                      border: innerBorder, borderRadius: BorderRadius.circular(0.0)),
                  child: ListTile(
                    title: RadioListTile(
                      value: 3,
                      groupValue: selectedRadioTile,
                      title: Text('cash on delivery'),
                      onChanged: (currentAddress) {
                        setSelectedRadioTile(currentAddress);
                      },
                      selected: selectedRadioTile == 1,
                      activeColor: Colors.red,
                    ),
                  ),
                )
            ),
          ),
        ],
      ).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Confirm order'),),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            height: MediaQuery.of(context).size.height * 1/12,
            child: Padding(
              padding: EdgeInsets.only(top: 20.0,left: 20.0),
              child:Text('Select Payment Option',style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold,color: Colors.grey),),
            ),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 7.1/12,
            padding: EdgeInsets.only(left:10.0,right:10.0),
            child:_paymentOptions(context),
          ),
          Container(
            height: MediaQuery.of(context).size.height * 1/12,
            child: Padding(
              padding: EdgeInsets.only(left: 20.0),
              child:Text('By clicking the "Confirm order" button, you \n agree with our "Terms & Conditions".'),
            ),
          ),
          InkWell(
            child: Container(
                height: MediaQuery.of(context).size.height * 1/12,

                color: Theme.of(context).primaryColor,
                child: Row(
                  children: <Widget>[
                    Container(
                        width: MediaQuery.of(context).size.width * 5/7,
                        padding:
                        EdgeInsets.only(left: 20.0, top: 2.0),
                        color: Color(0xffFB0084),
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: <Widget>[
                            Text(' Confirm order',style: TextStyle(fontSize:18.0,fontWeight: FontWeight.bold,color: Colors.white),)
                          ],
                        )),
                    Container(
                      height: MediaQuery.of(context).size.height,
                      width:
                      MediaQuery.of(context).size.width * 2 / 7,
                      color: Color(0xffB40060),
                      child: InkWell(
                        child: Center(
                          // child: Text('Check out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
                          child: Text((cart.totalAmount + cart.deliveryCharge).toStringAsFixed(2) + ' BDT',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                        ),
                        onTap: () {

                        },
                      ),
                    ),
                  ],
                )),
            onTap: (){
              Navigator.pushNamed(context, OrderConfirmationScreen.routeName);
            },
          )

          // RadioListTile(
          //
          //   value: 1,
          //   groupValue: selectedRadioTile,
          //   title: Text("Radio 1"),
          //   subtitle: Text("Radio 1 Subtitle"),
          //   onChanged: (val) {
          //     print("Radio Tile pressed $val");
          //     setSelectedRadioTile(val);
          //   },
          //   activeColor: Colors.red,
          //   secondary: OutlineButton(
          //     child: Text("Say Hi"),
          //     onPressed: () {
          //       print("Say Hello");
          //     },
          //   ),
          //   selected: false,
          // ),
          // RadioListTile(
          //   value: 2,
          //   groupValue: selectedRadioTile,
          //   title: Text("Radio 2"),
          //   subtitle: Text("Radio 2 Subtitle"),
          //   onChanged: (val) {
          //     print("Radio Tile pressed $val");
          //     setSelectedRadioTile(val);
          //   },
          //   activeColor: Colors.red,
          //   secondary: OutlineButton(
          //     child: Text("Say Hi"),
          //     onPressed: () {
          //       print("Say Hello");
          //     },
          //   ),
          //   selected: false,
          // ),
          // RadioListTile(
          //   value: 3,
          //   groupValue: selectedRadioTile,
          //   title: Text("Radio 3"),
          //   subtitle: Text("Radio 1 Subtitle"),
          //   onChanged: (val) {
          //     print("Radio Tile pressed $val");
          //     setSelectedRadioTile(val);
          //   },
          //   activeColor: Colors.red,
          //   secondary: OutlineButton(
          //     child: Text("Say Hi"),
          //     onPressed: () {
          //       print("Say Hello");
          //     },
          //   ),
          //   selected: true,
          // ),

        ],
      ),
    );
  }

}