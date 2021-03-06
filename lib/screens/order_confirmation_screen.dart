import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/orders.dart';
import 'package:shoptempdb/providers/shipping_address.dart';
import 'package:shoptempdb/screens/products_overview_screen.dart';
import 'package:shoptempdb/widgets/app_drawer.dart';
import 'package:toast/toast.dart';


class OrderConfirmationScreen extends StatefulWidget{
  static const routeName = '/order_confirmation';
  final deliveryAddressId;
  final city;
  final areaId;
  final addressLine;
  final mobileNo;
  final orderNote;
  final paymentOption;
  final deliveryDate;
  final deliveryTimeStart;
  final deliveryTimeEnd;
  final totalAmount;
  final deliveryCharge;
  final orderId;

  OrderConfirmationScreen(this.deliveryAddressId,this.city,this.areaId,this.addressLine,this.mobileNo,this.orderNote,this.paymentOption,this.deliveryDate,this.deliveryTimeStart,this.deliveryTimeEnd,this.totalAmount,this.deliveryCharge,this.orderId);

  @override
  State<StatefulWidget> createState() {
    return _OrderConfirmationScreenState();
  }

}


class _OrderConfirmationScreenState extends State<OrderConfirmationScreen>{
  TimeOfDay currentTime = TimeOfDay.now();
  final format = DateFormat('yyyy-MM-dd');
  final timeFormat = DateFormat("HH:mm");
  TextEditingController _cancelCommentController = TextEditingController();
  int selectedRadioTile;

  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    super.initState();
    selectedRadioTile = 3;
  }

  @override
  void didChangeDependencies(){
    if(_isInit) {
      if(widget.deliveryAddressId != null) {
        setState(() {
          _isLoading = true;
        });
        Provider.of<ShippingAddress>(context).fetchShippingAddress(
            widget.deliveryAddressId).then((data) {
          setState(() {
            _isLoading = false;
          });
        });
      }
    }
    _isInit = false;
    super.didChangeDependencies();
  }


  setSelectedRadioTile(int val) {
    setState(() {
      selectedRadioTile = val;
    });
  }

  Future<bool> _onBackPressed() {
    Navigator.pushReplacementNamed(context, ProductsOverviewScreen.routeName);

  }

  @override
  Widget build(BuildContext context) {
    final shippingAddress = Provider.of<ShippingAddress>(context);
    var outerBorder = Border.all(width: 2.0, color: Colors.black.withOpacity(0.2));
    var buttonBorder = Border.all(width: 2.0, color: Colors.red.withOpacity(1));
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
          appBar: AppBar(title: Text('Order Confirmed'),), drawer: AppDrawer(),
          body: _isLoading? Center(child: CircularProgressIndicator(),):SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Container(
                    height: MediaQuery.of(context).size.height * 2.2/12,
                    padding: EdgeInsets.all(10.0),
                    child: Card(
                        child: Container(
                          padding: EdgeInsets.only(top:10.0,bottom:10.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Image.asset('assets/package.png'),
                              SizedBox(width: 20.0,),
                              Column(children: <Widget>[
                                Text('CONGRATULATIONS!',style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold,color: Colors.grey),),
                                Text('Order placed.',style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold,color: Colors.grey),),
                                Text('Your order number is',style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold,color: Colors.grey),),
                                Text(widget.orderId.toString(),style: TextStyle(fontSize: 25.0,fontWeight: FontWeight.bold,color: Theme.of(context).primaryColor),)

                              ],)
                            ],
                          ),
                        )
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
                      child: Center(child:Text(widget.paymentOption)),
                    ),
                  ],),
                ),
                SizedBox(height: 10.0,),
                Container(
                  height: MediaQuery.of(context).size.height * 1.8/12,
                  padding: EdgeInsets.only(left:10.0,right:10.0),
                  child:Column(children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width * 1.5/2,
                      height: 50.0,
                      decoration: BoxDecoration(border: outerBorder, borderRadius: BorderRadius.circular(0.0)),
                      child: Center(child:Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Image.asset('assets/bkash-icon.png',scale: 8.0,),
                          Text('bkash Checkout'),
                          Container(
                            width: MediaQuery.of(context).size.width * 1.5/6,
                            height: 25.0,
                            decoration: BoxDecoration(border: buttonBorder,),
                            child: MaterialButton(
                              color: Color(0xffFB0084),
                              child: Text('Pay now',style: TextStyle(color: Colors.white,fontSize: 12.0),),
                              onPressed: (){

                              },
                            ),
                          ),
                        ],
                      )),
                    ),
                    SizedBox(height: 5.0,),
                    Container(
                      width: MediaQuery.of(context).size.width * 1.5/2,
                      height: 50.0,
                      decoration: BoxDecoration(border: outerBorder, borderRadius: BorderRadius.circular(0.0)),
                      child: Center(child:Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Image.asset('assets/card-logo.png',scale: 2.0,),
                          Text('credit or debit cart'),
                          Container(
                            width: MediaQuery.of(context).size.width * 1.5/6,
                            height: 25.0,
                            decoration: BoxDecoration(border: buttonBorder,),
                            child: MaterialButton(
                              color: Color(0xffFB0084),
                              child: Text('Pay now',style: TextStyle(color: Colors.white,fontSize: 12.0),),
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
                  height: MediaQuery.of(context).size.height * 1.5/12,
                  padding: EdgeInsets.only(left:10.0,right:10.0),
                  child:Column(children: <Widget>[
                    Text('Order Note',style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: Colors.grey),),
                    SizedBox(height: 10.0,),
                    Container(
                        width: MediaQuery.of(context).size.width * 1.5/2,
                        padding: EdgeInsets.all(5.0),
                        height: 50.0,
                        decoration: BoxDecoration(border: outerBorder, borderRadius: BorderRadius.circular(0.0)),
                        child: Scrollbar(
                          child: ListView(
                            shrinkWrap: true,
                            physics: AlwaysScrollableScrollPhysics(),
                            children: <Widget>[
                              Center(child:widget.orderNote !=null ?Text(widget.orderNote):Text('no order note')),
                            ],
                          ),
                        )
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
                      width: MediaQuery.of(context).size.width * 1.2/5,
                      height: 30.0,
                      decoration: BoxDecoration(border: buttonBorder, borderRadius: BorderRadius.circular(0.0)),
                      child: MaterialButton(
                        child: Center(child:Text('Cancel',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.red,fontSize: 12.0),)),
                        onPressed: () async{
                          showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) =>
                                  AlertDialog(
                                    title: Center(child: Text('Cancel order')),
                                    content: Container(
                                      height: 70,
                                      child: Column(
                                        children: <Widget>[
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              Text('Comment'),
                                              SizedBox(width: 10,),
                                              Container(
                                                width: 150,
                                                child: TextFormField(
                                                  keyboardType: TextInputType.multiline,
                                                  maxLines: 2,
                                                  controller: _cancelCommentController,
                                                  decoration: InputDecoration(hintText: 'write a comment'),
                                                ),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    actions: <Widget>[

                                      FlatButton(
                                        child: Text('Confirm'),
                                        onPressed: () async{
                                          var response;
                                          if(_cancelCommentController.text.isEmpty || _cancelCommentController.text == null || _cancelCommentController.text == ""){
                                            Toast.show('Write down some comment', context,duration: Toast.LENGTH_LONG,gravity: Toast.BOTTOM);
                                          }else{
                                            response = await Provider.of<Orders>(context, listen: false).cancelOrder(widget.orderId.toString(), _cancelCommentController.text);
                                            if(response != null){
                                              Toast.show(response['msg'], context,duration: Toast.LENGTH_LONG,gravity: Toast.BOTTOM);
                                              Navigator.pushNamed(context, ProductsOverviewScreen.routeName);
                                            }else{
                                              Toast.show('Something went wrong, please try again.', context,duration: Toast.LENGTH_LONG,gravity: Toast.BOTTOM);
                                              Navigator.of(context).pop(false);

                                            }
                                            if (!mounted) return;
                                            setState(() {
                                              _cancelCommentController.text = '';
                                            });
                                          }

                                        },
                                      ),
                                      FlatButton(
                                        child: Text('Cancel'),
                                        onPressed: () {
                                          setState(() {
                                            _cancelCommentController.text = '';
                                          });
                                          Navigator.of(context).pop(false);
                                        },
                                      ),
                                    ],
                                  ));
                        },
                      ),
                    ),
                  ],),
                ),
                SizedBox(height: 10.0,),
                Container(
                  height: MediaQuery.of(context).size.height * 2.5/12,
                  child:Column(children: <Widget>[
                    Text('Order Summary',style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: Colors.grey),),
                    SizedBox(height: 10.0,),
                    Card(
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('SubTotal',style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold)),
                                Text(widget.totalAmount.toStringAsFixed(2),style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(height: 5.0,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Delivery charge',style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold)),
                                Text(widget.deliveryCharge.toString(),style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(height: 5.0,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Order Total',style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold)),
                                Text((widget.totalAmount + widget.deliveryCharge).toStringAsFixed(2),style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold)),
                              ],
                            ),
                            SizedBox(height: 5.0,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Amount Paid',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
                                Text('0.00',style: TextStyle(color: Colors.red,fontWeight: FontWeight.bold),),
                              ],
                            ),
                            SizedBox(height: 5.0,),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text('Due',style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold)),
                                Text((widget.totalAmount + widget.deliveryCharge).toStringAsFixed(2),style: TextStyle(color: Colors.grey,fontWeight: FontWeight.bold)),
                              ],
                            ),

                          ],
                        ),
                      ),
                    )
                  ],),
                ),
                SizedBox(height: 10.0,),
                Container(
                  height: MediaQuery.of(context).size.height * 2/12,
                  child:Column(children: <Widget>[
                    Text('Delivery Address',style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: Colors.grey),),
                    SizedBox(height: 10.0,),
                    Card(
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Column(children: <Widget>[
                              Text(
                                widget.deliveryAddressId != null? shippingAddress.getDeliveryAddress.shippingAddress : widget.addressLine,style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold,color: Colors.grey),),
                              SizedBox(height: 5.0,),
                              Text(
                                widget.deliveryAddressId != null? shippingAddress.getDeliveryAddress.city : widget.city,style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold,color: Colors.grey),),
                              SizedBox(height: 5.0,),
                              Text(
                                // 'Cell: ' +
                                widget.deliveryAddressId != null? shippingAddress.getDeliveryAddress.phoneNumber : widget.mobileNo,style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold,color: Colors.grey),),

                            ],)
                          ],
                        ),
                      ),
                    ),
                  ],),
                ),
                SizedBox(height: 10.0,),
                Container(
                  height: MediaQuery.of(context).size.height * 1.5/12,
                  // padding: EdgeInsets.all(10.0),
                  child:Column(children: <Widget>[
                    Text('Delivery Date & time',style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: Colors.grey),),
                    SizedBox(height: 10.0,),
                    Card(
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: <Widget>[
                            Text('Date: '+ DateFormat('yyyy-MM-dd').format(DateTime.parse(widget.deliveryDate)),style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold,color: Colors.grey),),
                            SizedBox(width: 10.0,),
                            // Text('Time: ' + widget.deliveryTime.format(context).toString(),style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold,color: Colors.grey),),
                            Text('Time: ' + widget.deliveryTimeStart+ '-' + widget.deliveryTimeEnd,style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold,color: Colors.grey),),
                          ],
                        ),
                      ),
                    )
                  ],),
                ),
              ],
            ),
          )

      )
    );
  }

}