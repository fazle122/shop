import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/base_state.dart';
import 'package:shoptempdb/providers/auth.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/products.dart';
import 'package:shoptempdb/screens/delivery_address_screen.dart';
import 'package:shoptempdb/screens/login_screen.dart';
import 'package:shoptempdb/utility/util.dart';
import 'package:shoptempdb/widgets/app_drawer.dart';



class CartScreen extends StatefulWidget {
  static const routeName = '/cart';

  @override
  State<StatefulWidget> createState() {
    return _CartScreenState();
  }

}

class _CartScreenState extends BaseState<CartScreen>{

  var _isInit = true;

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
          });
        }
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
                                leading: Container(
                                  color:Colors.white,
                                  child: CircleAvatar(
                                    child: Padding(
                                      padding: EdgeInsets.all(5),
                                      child: FittedBox(
                                          child: FadeInImage(
                                            image: NetworkImage(cart.items[i].imgUrl),
                                            height: 30.0,
                                            width: 25.0,
                                            fit: BoxFit.contain,
                                            placeholder: AssetImage('assets/products.png'),
                                          )
                                        // Text('{cart.items[i].price.toString()}'),
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(cartData.items[i].title),
                                subtitle: Text('Total : ' + (cart.items[i].price.toDouble() * cart.items[i].quantity).toString() + ' BDT'),
                                trailing: Container(
                                  width: MediaQuery.of(context).size.width * 1.4/5,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: <Widget>[
                                      IconButton(
                                        icon: Icon(Icons.add_circle_outline,size: 25.0,),
                                        color:Colors.red,
                                        onPressed: (){
                                          cart.addItem(cartData.items[i].productId, cartData.items[i].title, cartData.items[i].imgUrl,cartData.items[i].price,cartData.items[i].vatRate,cartData.items[i].isNonInventory,cartData.items[i].discount,cartData.items[i].discountId,cartData.items[i].discountType);
                                          Scaffold.of(context).hideCurrentSnackBar();
                                          Future.delayed(const Duration(milliseconds: 500), () async{
                                            // await getDeliveryCharge(cart,cart.totalAmount);
                                            await Util.getDeliveryCharge(context,cart);
                                          });


                                        },
                                      ),
                                      Text(cartData.items[i].quantity.toString(),style: TextStyle(fontSize: 20.0),),
                                      IconButton(
                                        icon: Icon(Icons.remove_circle_outline,size: 25.0,),
                                        color: Colors.red,
                                        onPressed: (){
                                          cart.removeSingleItem(cartData.items[i].productId);
                                          Scaffold.of(context).hideCurrentSnackBar();
                                          Future.delayed(const Duration(milliseconds: 500), () async{
                                            // await getDeliveryCharge(cart,cart.totalAmount);
                                            await Util.getDeliveryCharge(context,cart);
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
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
                        height: MediaQuery.of(context).size.height * 1 / 25,
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
                        height: MediaQuery.of(context).size.height * 1 / 25,
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
                      height: MediaQuery.of(context).size.height * 1 / 15,
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
        ) :Center(child: Text('no item added to cart yet.',style: TextStyle(fontSize: 22.0),),),
        )
    );
  }
}

