import 'package:dio/dio.dart';
import 'package:flushbar/flushbar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/orders.dart';
import 'package:shoptempdb/providers/products.dart';
import 'package:shoptempdb/providers/shipping_address.dart';
import 'package:shoptempdb/screens/delivery_address_screen.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:shoptempdb/screens/order_confirmation_screen.dart';
import 'package:shoptempdb/screens/orders_screen.dart';


class ConfirmOrderScreen extends StatefulWidget{
  static const routeName = '/confirm_order';

  @override
  State<StatefulWidget> createState() {
    return _ConfirmOrderScreenState();
  }

}


class _ConfirmOrderScreenState extends State<ConfirmOrderScreen>{
  var _isLoading = false;
  DateTime _deliveryDate;
  TimeOfDay currentTime = TimeOfDay.now();
  final format = DateFormat('yyyy-MM-dd');
  final timeFormat = DateFormat("HH:mm");
  Map<String, dynamic> product;
  String paymentOptionName;
  int selectedRadioTile;

  var totalAmount;
  var delCharge;

  @override
  void initState() {
    super.initState();
    selectedRadioTile = 3;
    paymentOptionName = 'cash on delivery';
    getDeliveryCharge();

  }

  setSelectedRadioTile(int val) {
    setState(() {
      selectedRadioTile = val;
    });
  }

  // @override
  // void didChangeDependencies() {
  //   // getDeliveryCharge();
  //   super.didChangeDependencies();
  // }

  getDeliveryCharge() async {
    final cart = await Provider.of<Cart>(context, listen: false);
    Map<String, dynamic> data = Map();
    data.putIfAbsent('amount', () => cart.totalAmount.toDouble());
    FormData formData = FormData.fromMap(data);
    var response = await Provider.of<Products>(context, listen: false).fetchDeliveryCharge(formData);
    if (response != null) {
      setState(() {
        product = response['data']['product'];
      });
    }
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
                          Image.asset('assets/bkash-icon.png',scale: 7.0,),
                          SizedBox(width: 5.0,),
                          Text('bkash Checkout')
                        ],
                      ),
                      onChanged: (currentAddress) {
                        setSelectedRadioTile(currentAddress);
                        setState(() {
                          paymentOptionName = 'bkash Checkout';
                        });
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
                          Image.asset('assets/card-logo.png',scale: 2,),
                          SizedBox(width: 5.0,),
                          Text('credit or debit card')
                        ],
                      ),
                      onChanged: (currentAddress) {
                        setSelectedRadioTile(currentAddress);
                        setState(() {
                          paymentOptionName = 'credit or debit card';
                        });
                      },
                      selected: selectedRadioTile == 2,
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
                        setState(() {
                          paymentOptionName = 'cash on delivery';
                        });
                      },
                      selected: selectedRadioTile == 3,
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
    final shippingAddress = Provider.of<ShippingAddress>(context,listen: false);
    Map<String,dynamic> dt = ModalRoute.of(context).settings.arguments as Map;

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
            height: MediaQuery.of(context).size.height * 7.18/12,
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
                          child: Text((cart.totalAmount + cart.deliveryCharge).toStringAsFixed(2) + ' BDT',style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),),
                        ),
                        onTap: () async{
                        },
                      ),
                    ),
                  ],
                )),
            onTap: () async{
              setState(() {
                totalAmount = cart.totalAmount;
                delCharge = cart.deliveryCharge;
              });
              if (product != null) {
                await cart.addItem(
                    product['id'].toString(),
                    product['name'],
                    product['unit_price'].toDouble(),
                    product['is_non_inventory'],
                    product['discount'] != null ? product['discount'] : 0.0,
                    product['discount_id'],
                    product['discount_type']);
              }
              Future.delayed(Duration(milliseconds: 500), () async{
                List<Cart> ct = [];
                ct = cart.items.map((e) => Cart(id: e.id, cartItem: e)).toList();
                // Map<String,dynamic> dt = Map();
                for (int i = 0; i < ct.length; i++) {
                  dt.putIfAbsent('product_id[$i]', ()=>ct[i].cartItem.productId);
                  dt.putIfAbsent('quantity[$i]', ()=>ct[i].cartItem.quantity);
                  dt.putIfAbsent('unit_price[$i]', ()=>ct[i].cartItem.price);
                  dt.putIfAbsent('is_non_inventory[$i]', ()=>ct[i].cartItem.isNonInventory);
                  dt.putIfAbsent('discount[$i]', ()=>ct[i].cartItem.discount);
                }
                dt.putIfAbsent('payment_method', () => 0);

                FormData formData= FormData.fromMap(dt);

                // final response = await Provider.of<Orders>(context, listen: false).addOrder(formData);
                // if (response != null) {
                // var orderId = response['data']['customer_invoice']['invoice']['id'];
                var orderId = '12345';
                  if(dt.containsKey('customer_shipping_address_id') && dt['customer_shipping_address_id'] != null){
                    Navigator.pushReplacement(context, MaterialPageRoute(
                      builder: (context) => OrderConfirmationScreen(
                        dt['customer_shipping_address_id'],
                        null,null,null,null,
                        dt['comment'],
                        paymentOptionName,
                        dt['delivery_date'],
                        dt['delivery_slot_start'],
                        dt['delivery_slot_end'],
                        totalAmount,
                        delCharge,
                        orderId,
                      ),
                    ));
                //   }
                //   else{
                //     Navigator.pushReplacement(context, MaterialPageRoute(
                //       builder: (context) => OrderConfirmationScreen(
                //         null,
                //         dt['city'],
                //         dt['area_id'],
                //         dt['shipping_address_line'],
                //         dt['mobile_no'],
                //         dt['comment'],
                //         paymentOptionName,
                //         dt['delivery_date'],
                //           dt['delivery_slot_start'],
                //           dt['delivery_slot_end'],
                //         totalAmount,
                //         delCharge,
                //           orderId
                //       ),
                //     ));
                //   }
                //   cart.clearCartTable();
                //   shippingAddress.selectedDate = null;
                //   shippingAddress.selectedTime = null;
                // }
                // else {
                //   await cart.removeCartItemRow('1');
                //   setState(() {
                //     _isLoading = false;
                //   });
                //   Flushbar(
                //     duration: Duration(seconds: 5),
                //     margin: EdgeInsets.only(bottom: 2),
                //     padding: EdgeInsets.all(10),
                //     borderRadius: 8,
                //     backgroundColor: Colors.red.shade400,
                //     boxShadows: [
                //       BoxShadow(
                //         color: Colors.black45,
                //         offset: Offset(3, 3),
                //         blurRadius: 3,
                //       ),
                //     ],
                //     dismissDirection: FlushbarDismissDirection.HORIZONTAL,
                //     forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
                //     title: 'Order confirmation',
                //     message: 'Something wrong. Please try again',
                //   )..show(context);
                }
              });
            },
          )
        ],
      ),
    );
  }

}