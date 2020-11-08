import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/shipping_address.dart';
import 'package:shoptempdb/screens/confirm_order_screen.dart';
import 'package:shoptempdb/screens/delivery_address_screen.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';


class OrderConfirmationScreen extends StatefulWidget{
  static const routeName = '/order_confirmation';

  @override
  State<StatefulWidget> createState() {
    return _OrderConfirmationScreenState();
  }

}


class _OrderConfirmationScreenState extends State<OrderConfirmationScreen>{

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


  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    var outerBorder = Border.all(width: 2.0, color: Colors.black.withOpacity(0.2));
    var buttonBorder = Border.all(width: 2.0, color: Colors.red.withOpacity(1));
    return Scaffold(
      appBar: AppBar(title: Text('Order Confirmed'),),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
                height: MediaQuery.of(context).size.height * 2/12,
                padding: EdgeInsets.all(2.0),
                margin: EdgeInsets.only(top:10.0),
                child: Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Image.asset('assets/Bkash-Logo.png'),
                      Column(children: <Widget>[
                        Text('CONGRATULATIONS!',style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold,color: Colors.grey),),
                        Text('Order placed.',style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold,color: Colors.grey),),
                        Text('Your order number is',style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold,color: Colors.grey),),
                        Text('#5678',style: TextStyle(fontSize: 25.0,fontWeight: FontWeight.bold,color: Theme.of(context).primaryColor),)

                      ],)
                    ],
                  ),
                )

            ),
            SizedBox(height: 10.0,),
                Container(
                  height: MediaQuery.of(context).size.height * 1.2/12,
                  padding: EdgeInsets.only(left:10.0,right:10.0),
                  child:Column(children: <Widget>[
                    Text('payment Option',style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: Colors.grey),),
                    SizedBox(height: 10.0,),
                    Container(
                      width: MediaQuery.of(context).size.width * 1/2,
                      height: 30.0,
                      decoration: BoxDecoration(border: outerBorder, borderRadius: BorderRadius.circular(0.0)),
                      child: Center(child:Text('Cash on delivery')),
                    ),
                  ],),
                ),
                SizedBox(height: 10.0,),
            Container(
              height: MediaQuery.of(context).size.height * 1.2/12,
              padding: EdgeInsets.only(left:10.0,right:10.0),
              child:Column(children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 1.2/2,
                  height: 30.0,
                  decoration: BoxDecoration(border: outerBorder, borderRadius: BorderRadius.circular(0.0)),
                  child: Center(child:Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Image.asset('assets/Bkash-Logo.png'),
                      Text('bkash Checkout'),
                      Container(
                        width: MediaQuery.of(context).size.width * 1/6,
                        height: 18.0,
                        decoration: BoxDecoration(border: buttonBorder,),
                        child: MaterialButton(
                          color: Color(0xffFB0084),
                          child: Text('Pay now',style: TextStyle(color: Colors.white,fontSize: 7.0),),
                          onPressed: (){

                          },
                        ),
                      ),
                    ],
                  )),
                ),
                SizedBox(height: 5.0,),
                Container(
                  width: MediaQuery.of(context).size.width * 1.2/2,
                  height: 30.0,
                  decoration: BoxDecoration(border: outerBorder, borderRadius: BorderRadius.circular(0.0)),
                  child: Center(child:Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Image.asset('assets/credit-card-Logo.png'),
                      Text('Credit or debit card'),
                      Container(
                        width: MediaQuery.of(context).size.width * 1/6,
                        height: 18.0,
                        decoration: BoxDecoration(border: buttonBorder,),
                        child: MaterialButton(
                          color: Color(0xffFB0084),
                          child: Text('Pay now',style: TextStyle(color: Colors.white,fontSize: 7.0),),
                          onPressed: (){

                          },
                        ),
                      ),
                    ],
                  )),
                ),
              ],),
            ),
            SizedBox(height: 10.0,),
            Container(
              height: MediaQuery.of(context).size.height * 1/12,
              padding: EdgeInsets.only(left:10.0,right:10.0),
              child:Column(children: <Widget>[
                Text('Order Note',style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: Colors.grey),),
                SizedBox(height: 10.0,),
                Container(
                  width: MediaQuery.of(context).size.width * 1/2,
                  height: 30.0,
                  decoration: BoxDecoration(border: outerBorder, borderRadius: BorderRadius.circular(0.0)),
                  child: Center(child:Text('Call me before delivery')),
                ),
              ],),
            ),
            SizedBox(height: 10.0,),
            Container(
              height: MediaQuery.of(context).size.height * 1/12,
              padding: EdgeInsets.only(left:10.0,right:10.0),
              child:Column(children: <Widget>[
                Text('Cancel Order',style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: Colors.grey),),
                SizedBox(height: 10.0,),
                Container(
                  width: MediaQuery.of(context).size.width * 1/5,
                  height: 30.0,
                  decoration: BoxDecoration(border: buttonBorder, borderRadius: BorderRadius.circular(0.0)),
                  child: MaterialButton(
                    child: Text('Cancel',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red,fontSize: 12.0),),
                    onPressed: (){

                    },
                  ),
                ),
              ],),
            ),
                SizedBox(height: 10.0,),
                Container(
                  height: MediaQuery.of(context).size.height * 2/12,
                  padding: EdgeInsets.only(left:10.0,right:10.0),
                  child:Column(children: <Widget>[
                    Text('Order Summary',style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: Colors.grey),),
                    SizedBox(height: 10.0,),
                    Card(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Image.asset('assets/Bkash-Logo.png'),
                          Column(children: <Widget>[
                            Text('CONGRATULATIONS!',style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold,color: Colors.grey),),
                            Text('Order placed.',style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold,color: Colors.grey),),
                            Text('Your order number is',style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold,color: Colors.grey),),
                            Text('#5678',style: TextStyle(fontSize: 25.0,fontWeight: FontWeight.bold,color: Theme.of(context).primaryColor),)

                          ],)
                        ],
                      ),
                    )
                  ],),
                ),
            SizedBox(height: 10.0,),
            Container(
              height: MediaQuery.of(context).size.height * 2/12,
              padding: EdgeInsets.only(left:10.0,right:10.0),
              child:Column(children: <Widget>[
                Text('Delivery Address',style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: Colors.grey),),
                SizedBox(height: 10.0,),
                Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Column(children: <Widget>[
                        Text('Address',style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold,color: Colors.grey),),
                        Text('Order placed.',style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold,color: Colors.grey),),
                        Text('Your order number is',style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold,color: Colors.grey),),
                        Text('#5678',style: TextStyle(fontSize: 25.0,fontWeight: FontWeight.bold,color: Theme.of(context).primaryColor),)

                      ],)
                    ],
                  ),
                )
              ],),
            ),
            SizedBox(height: 10.0,),
            Container(
              height: MediaQuery.of(context).size.height * 1.2/12,
              padding: EdgeInsets.only(left:10.0,right:10.0),
              child:Column(children: <Widget>[
                Text('Delivery Date & time',style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: Colors.grey),),
                SizedBox(height: 10.0,),
                Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Column(children: <Widget>[
                        Text('Date n time',style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold,color: Colors.grey),),


                      ],)
                    ],
                  ),
                )
              ],),
            ),
            Container(
              height: 250,
              color: Colors.red[500],
              child: const Center(child: Text('Entry B')),
            ),
            Container(
              height: 250,
              color: Colors.yellow[100],
              child: const Center(child: Text('Entry C')),
            ),
          ],
        ),
      )

    );
  }

}