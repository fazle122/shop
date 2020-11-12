import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/base_state.dart';
import 'package:shoptempdb/providers/auth.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/orders.dart';
import 'package:shoptempdb/providers/products.dart';
import 'package:shoptempdb/screens/auth_screen.dart';
import 'package:shoptempdb/screens/delivery_address_screen.dart';
import 'package:shoptempdb/screens/login_screen.dart';
import 'package:shoptempdb/screens/create_profile_screen.dart';
import 'package:shoptempdb/widgets/app_drawer.dart';
import 'package:shoptempdb/widgets/cart_item.dart';
import 'package:shoptempdb/widgets/confirm_order_dialog.dart';
import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shoptempdb/screens/test.dart';
import 'package:provider/provider.dart';



class CartScreen extends StatefulWidget {
  static const routeName = '/cart';

  @override
  State<StatefulWidget> createState() {
    return _CartScreenState();
  }

}

class _CartScreenState extends BaseState<CartScreen>{

  var _isInit = true;
  var _isLoading = false;

//  @override
//  void didChangeDependencies(){
//    if(_isInit) {
//      if (!mounted) return;
//      setState(() {
//        _isLoading = true;
//      });
//      Provider.of<Cart>(context).fetchAndSetCartItems().then((_){
//        if (!mounted) return;
//        setState(() {
//          _isLoading = false;
//        });
//      });
//    }
//    _isInit = false;
//    super.didChangeDependencies();
//  }

  @override
  void didChangeDependencies(){
    if(_isInit) {
      Provider.of<Cart>(context).fetchAndSetCartItems();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  getDeliveryCharge(Cart cart,double totalAmount) async{
    List deliveryChargeMatrix = [];
    await Provider.of<Products>(context,listen: false).fetchDeliveryCharMatrix().then((data){
      deliveryChargeMatrix = data['range'];
      for(int i=0;i<deliveryChargeMatrix.length;i++){
        if(i == 0 && totalAmount<=deliveryChargeMatrix[i]['max']){
          setState(() {
            cart.deliveryCharge = deliveryChargeMatrix[i]['charge'].toDouble();
          });
        }else if( i>0 && totalAmount >= deliveryChargeMatrix[i]['min']){
          setState(() {
            cart.deliveryCharge = deliveryChargeMatrix[i]['charge'].toDouble();

          });
        }else if( i>0){
          setState(() {
            cart.maxDeliveryRange = deliveryChargeMatrix[i]['min'].toDouble();
            // cart.minDeliveryCharge = deliveryChargeMatrix[i]['charge'].toDouble();
          });
        }
        // if(i ==0 && totalAmount<=deliveryChargeMatrix[i]['max']){
        //   setState(() {
        //     cart.deliveryCharge = deliveryChargeMatrix[i]['charge'].toDouble();
        //   });
        // }else if( i>0 && totalAmount >= deliveryChargeMatrix[i]['min']){
        //   setState(() {
        //     cart.maxDeliveryRange = deliveryChargeMatrix[i]['min'].toDouble();
        //     cart.minDeliveryCharge = deliveryChargeMatrix[i]['charge'].toDouble();
        //     cart.deliveryCharge = deliveryChargeMatrix[i]['charge'].toDouble();
        //   });
        // }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<Cart>(context);
    final auth = Provider.of<Auth>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('My Basket'),
        ),
        drawer: AppDrawer(),
        body: Consumer<Cart>(builder: (context,cartData,child) =>
        cartData.items.length >0 ?
        Column(
            children: <Widget>[
//               Card(
//                 margin: EdgeInsets.all(15.0),
//                 child: Padding(
//                   padding: EdgeInsets.all(8),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: <Widget>[
//                       Text(
//                         'Sub Total',
//                         style: TextStyle(fontSize: 20),
//                       ),
//                       Spacer(),
//                       Chip(
//                         label: cart.totalAmount<500 && cart.items.length >0 ?
// //                    Text('\$${(cart.totalAmount + 50).toStringAsFixed(2)}',
//                         Text('\$${(cart.totalAmount).toStringAsFixed(2)}',
//                           style: TextStyle(
//                               color:
//                               Theme.of(context).primaryTextTheme.title.color),
//                         ) :
//                         Text('\$${cart.totalAmount.toStringAsFixed(2)}',
//                           style: TextStyle(
//                               color:
//                               Theme.of(context).primaryTextTheme.title.color),
//                         ),
//                         backgroundColor: Theme.of(context).primaryColor,
//                       ),
//                       FlatButton(
//                         textColor: Theme.of(context).primaryColor,
//                         child: Text('Order now'),
//                         onPressed: () {
//                           auth.isAuth?
//                           Navigator.of(context).pushNamed(DeliveryAddressScreen.routeName,arguments: cart)
//                               // :Navigator.of(context).pushNamed(AuthScreen.routeName);
//                               :Navigator.of(context).pushNamed(LoginScreen.routeName);
// //                      showDialog(
// //                          context: context,
// //                          child: _confirmOrderDialog(context, cart)
// ////                          child: ConfirmOrderDialog()
// //                      );
// //                      Provider.of<Orders>(context, listen: false).addOrder(
// //                          cart.items.values.toList(), cart.totalAmount);
// //                      cart.clear();
//                         },
//                       )
//                     ],
//                   ),
//                 ),
//               ),
              SizedBox(
                height: 10,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: cartData.items.length,
                  itemBuilder: (context,i){
                    return Dismissible(
                        key:UniqueKey(),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: Theme.of(context).errorColor,
                          child: Icon(Icons.delete,color: Colors.white,size: 40,),
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 4),
                        ),
                        confirmDismiss: (direction){
                          return   showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => AlertDialog(
                                title: Text('Are you sure?'),
                                content: Text('Do you want to cancel this order?'),
                                actions: <Widget>[
                                  FlatButton(child: Text('No'), onPressed: (){Navigator.of(context).pop(false);},),
                                  FlatButton(child: Text('Yes'), onPressed: (){Navigator.of(context).pop(true);},),
                                ],
                              )
                          );
                        },
                        onDismissed: (direction) async{
//                          setState(() {
//                            _isLoading = true;
//                          });
//                          await Provider.of<Orders>(context,listen: false).cancelOrder(cartData.items[i].id.toString(),'test');
                          cart.removeCartItemRow(cartData.items[i].productId);
                          if (!mounted) return;
                          setState(() {
                            _isInit = true;
                          });
                        },
                        child: Card(
                          margin: EdgeInsets.all(10),
                          child: Column(
                            children: <Widget>[
                              ListTile(
                                leading: CircleAvatar(
                                  child: Padding(
                                    padding: EdgeInsets.all(5),
                                    child: FittedBox(
                                      child: Text('\$$cartData.items[i].price'),
                                    ),
                                  ),
                                ),
                                title: Text(cartData.items[i].title),
                                subtitle: Text('Total : \$${(cart.items[i].price.toDouble() * cart.items[i].quantity)}'),
                                trailing: Container(
                                  width: 110.0,
                                  child: cartData.items[i].quantity != null ? Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      IconButton(
                                        icon: Icon(Icons.add),
                                        onPressed: (){
                                          cart.addItem(cartData.items[i].productId, cartData.items[i].title, cartData.items[i].price,cartData.items[i].isNonInventory,cartData.items[i].discount,cartData.items[i].discountId,cartData.items[i].discountType);
                                          Scaffold.of(context).hideCurrentSnackBar();
                                          Future.delayed(const Duration(milliseconds: 500), () async{
                                            await getDeliveryCharge(cart,cart.totalAmount);

                                            if(cart.items.length> 0)
                                              Scaffold.of(context).showSnackBar(SnackBar(
                                                backgroundColor: cart.totalAmount > cart.maxDeliveryRange ? Theme.of(context).primaryColor : Colors.red[300],
                                                content: cart.totalAmount > cart.maxDeliveryRange
                                                    ? Container(
                                                    padding: EdgeInsets.only(top: 5.0,bottom: 5.0),
                                                    child:Text('Delivery charge : ' + cart.deliveryCharge.toString() + ' BDT')
                                                )
                                                    : Row(
                                                  children: <Widget>[
                                                    // Container(
                                                    //     decoration: BoxDecoration(
                                                    //         border: Border(
                                                    //             right: BorderSide(
                                                    //                 color: Colors.white,
                                                    //                 width: 1.0))),
                                                    //     width: MediaQuery.of(context).size.width * 1 / 7,
                                                    //     child: Text(cart.deliveryCharge.toString())),
                                                    SizedBox(
                                                      width: 5.0,
                                                    ),
                                                    Container(
                                                      width: MediaQuery.of(context).size.width * 4 / 7,
                                                      child: Text('Shop more item of ' +  (cart.maxDeliveryRange-cart.totalAmount).toString() +  ' BDT to reduce delivery charge.'),
                                                    )
                                                  ],
                                                ),
                                                duration: Duration(seconds: 2),
                                              ));
                                          });


                                        },
                                      ),
                                      Text(cartData.items[i].quantity.toString(),style: TextStyle(fontSize: 20.0),),
                                      IconButton(
                                        icon: Icon(Icons.remove),
                                        onPressed: (){
                                          cart.removeSingleItem(cartData.items[i].productId);
                                          Scaffold.of(context).hideCurrentSnackBar();
                                          Future.delayed(const Duration(milliseconds: 500), () async{
                                            await getDeliveryCharge(cart,cart.totalAmount);

                                            if(cart.items.length> 0)
                                              Scaffold.of(context).showSnackBar(SnackBar(
                                                backgroundColor: cart.totalAmount > cart.maxDeliveryRange ? Theme.of(context).primaryColor : Colors.red[300],
                                                content: cart.totalAmount > cart.maxDeliveryRange
                                                    ? Container(padding: EdgeInsets.only(top: 5.0,bottom: 5.0),
                                                    child:Text('Delivery charge : ' + cart.deliveryCharge.toString() + ' BDT'))
                                                    : Row(
                                                  children: <Widget>[
                                                    // Container(
                                                    //     decoration: BoxDecoration(
                                                    //         border: Border(
                                                    //             right: BorderSide(
                                                    //                 color: Colors.white,
                                                    //                 width: 1.0))),
                                                    //     width: MediaQuery.of(context).size.width * 1 / 7,
                                                    //     child: Text(cart.minDeliveryCharge.toString())),
                                                    SizedBox(
                                                      width: 5.0,
                                                    ),
                                                    Container(
                                                      width: MediaQuery.of(context).size.width * 4 / 7,
                                                      child: Text('Shop more item of ' +  (cart.maxDeliveryRange-cart.totalAmount).toString() +  ' BDT to reduce delivery charge.'),
                                                    )
                                                  ],
                                                ),
                                                duration: Duration(seconds: 2),
                                              ));
                                          });


                                        },
                                      ),
                                    ],
                                  ):IconButton(
                                    color: Theme.of(context).accentColor,
                                    icon: Icon(Icons.shopping_cart),
                                    onPressed: () {
//                          cart.addItem(widget.id, widget.title, widget.price,widget.isNonInventory,widget.discount,widget.discountId,widget.discountType);
                                    },
                                  ),
                                ),
                                onTap: (){
//                        Navigator.of(context).pushNamed(OrderDetailScreen.routeName,
//                            arguments: orderData.orders[i].id);
                                },
                              ),
                            ],
                          ),
                        )
                    );
                  },
                ),
              ),
              cart.items.length > 0
                  ?Consumer<Cart>(
                builder: (context, cartData, child) =>
                    Container(
                      padding: EdgeInsets.only(left: 10.0,right: 10.0),
                        height: 30.0,
                        color: Color(0xffC6C6C6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('SubTotal'),
                            Text(cartData.totalAmount.toStringAsFixed(2)),

                          ],
                        )),
              ):SizedBox(width: 0.0,height: 0.0,),
              cart.items.length > 0
                  ?Consumer<Cart>(
                builder: (context, cartData, child) =>
                    Container(
                        padding: EdgeInsets.only(left: 10.0,right: 10.0),
                        height: 30.0,
                        color: Color(0xffDEDEDE),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text('Delivery fee'),
                            Text(cartData.deliveryCharge.toString()),
                          ],
                        )),
              ):SizedBox(width: 0.0,height: 0.0,),
              cart.items.length > 0
                  ?Consumer<Cart>(
                builder: (context, cartData, child) =>
                InkWell(
                  child:Container(
                    height: 50.0,
                    color: Theme.of(context).primaryColor,
                    child: Row(
                      children: <Widget>[
                        Container(
                            width: MediaQuery.of(context).size.width * 5 / 7,
                            padding: EdgeInsets.only(left: 20.0, top: 2.0),
                            color: Color(0xffFB0084),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text('Place order',style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: Colors.white),),

                              ],
                            )),
                        Container(
                          height: MediaQuery.of(context).size.height,
                          width:
                          MediaQuery.of(context).size.width * 2 / 7,
                          color: Color(0xffB40060),
                          child: Center(
                              child: Text((cartData.totalAmount + cartData.deliveryCharge).toStringAsFixed(2),style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color: Colors.white),),
                            ),
                        ),
                      ],
                    )),
                  onTap: () {
                    auth.isAuth?
                    Navigator.of(context).pushNamed(DeliveryAddressScreen.routeName)
                        :Navigator.of(context).pushNamed(LoginScreen.routeName);
                  },),
              ) : SizedBox(width: 0.0, height: 0.0,)
            ]
        )

            :Center(child: Text('no item added to cart yet!!!'),),
        )
    );
  }
}







//class CartScreen extends StatelessWidget {
//  static const routeName = '/cart';
//
//  @override
//  Widget build(BuildContext context) {
//    final cart = Provider.of<Cart>(context);
//    final auth = Provider.of<Auth>(context);
//    return Scaffold(
//      appBar: AppBar(
//        title: Text('Your cart'),
//      ),
//      body: Column(
//        children: <Widget>[
//          Card(
//            margin: EdgeInsets.all(15.0),
//            child: Padding(
//              padding: EdgeInsets.all(8),
//              child: Row(
//                mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                children: <Widget>[
//                  Text(
//                    'Total',
//                    style: TextStyle(fontSize: 20),
//                  ),
//                  Spacer(),
//                  Chip(
//                    label: cart.totalAmount<500 && cart.items.length >0 ?
////                    Text('\$${(cart.totalAmount + 50).toStringAsFixed(2)}',
//                        Text('\$${(cart.totalAmount).toStringAsFixed(2)}',
//                      style: TextStyle(
//                          color:
//                          Theme.of(context).primaryTextTheme.title.color),
//                    ) :
//                    Text('\$${cart.totalAmount.toStringAsFixed(2)}',
//                      style: TextStyle(
//                          color:
//                              Theme.of(context).primaryTextTheme.title.color),
//                    ),
//                    backgroundColor: Theme.of(context).primaryColor,
//                  ),
//                  FlatButton(
//                    textColor: Theme.of(context).primaryColor,
//                    child: Text('Order now'),
//                    onPressed: () {
//                      auth.isAuth?
//                      Navigator.of(context).pushNamed(ShippingAddressScreen.routeName,arguments: cart)
//                      :Navigator.of(context).pushNamed(AuthScreen.routeName);
////                      showDialog(
////                          context: context,
////                          child: _confirmOrderDialog(context, cart)
//////                          child: ConfirmOrderDialog()
////                      );
////                      Provider.of<Orders>(context, listen: false).addOrder(
////                          cart.items.values.toList(), cart.totalAmount);
////                      cart.clear();
//                    },
//                  )
//                ],
//              ),
//            ),
//          ),
//          SizedBox(
//            height: 10,
//          ),
//          Expanded(
//              child: ListView.builder(
//            itemCount: cart.itemCount,
//            itemBuilder: (context, i) => CartItemWidget(
//              cart.items.values.toList()[i].id,
//              cart.items.keys.toList()[i],
//              cart.items.values.toList()[i].price,
//              cart.items.values.toList()[i].quantity,
//              cart.items.values.toList()[i].title,
//              cart.items.values.toList()[i].isNonInventory,
//              cart.items.values.toList()[i].discount,
//              cart.items.values.toList()[i].discountId,
//              cart.items.values.toList()[i].discountType,
//            ),
//          )),
//          cart.items.length > 0
//              ? Container(
//                  height: 50.0,
//                  color: Theme.of(context).primaryColor,
//                  child: Row(
//                    children: <Widget>[
//                      Container(
//                          width: MediaQuery.of(context).size.width * 5 / 7,
//                          padding: EdgeInsets.only(left: 20.0,top: 5.0),
//                          color: Theme.of(context).primaryColor,
//                          child: Column(
//                            crossAxisAlignment: CrossAxisAlignment.start,
//                            mainAxisAlignment: MainAxisAlignment.start,
//                            children: <Widget>[
//                              Text('SubTotal: ' +
//                                  cart.totalAmount.toStringAsFixed(2)),
//                              cart.totalAmount>500 ? Text('Delivery charge: 00.00 BDT'):Text('Delivery charge: 50.00 BDT'),
//                              cart.totalAmount>500 ?
//                              Text(
//                                'Total amount : ' +
//                                    cart.totalAmount.toStringAsFixed(2),
//                                style: TextStyle(color: Colors.white),
//                              )
//                              :Text(
//                                'Total amount : ' +
//                                    (cart.totalAmount + 50.00).toStringAsFixed(2),
//                                style: TextStyle(color: Colors.white),
//                              ),
//                            ],
//                          )),
//                      Container(
//                        height: MediaQuery.of(context).size.height,
//                        width: MediaQuery.of(context).size.width * 2 / 7,
//                        color: Theme.of(context).primaryColorDark,
//                        child: InkWell(
//                          child: Center(
//                            child: Text(
//                              'Check out',
//                              style: TextStyle(
//                                  color: Colors.white,
//                                  fontWeight: FontWeight.bold),
//                            ),
//                          ),
//                          onTap: () {
//                            auth.isAuth?
//                            Navigator.of(context).pushNamed(ShippingAddressScreen.routeName,arguments: cart)
//                                :Navigator.of(context).pushNamed(AuthScreen.routeName);
////                            showDialog(
////                                context: context,
////                                child: _confirmOrderDialog(context, cart)
//////                                child: ConfirmOrderDialog()
////                            );
//                          },
//                        ),
//                      ),
//                    ],
//                  ))
//              : SizedBox(
//                  width: 0.0,
//                  height: 0.0,
//                )
//        ],
//      ),
//    );
//  }
//}
