import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/orders.dart';
import 'package:shoptempdb/providers/product.dart';
import 'package:shoptempdb/providers/products.dart';
import 'package:shoptempdb/screens/product_detail_screen.dart';
import 'package:flushbar/flushbar.dart';


class ProductItemListView extends StatefulWidget {

//  final int quantity;
//  ProductItemListView(this.quantity);

  @override
  _ProductItemListViewState createState() => _ProductItemListViewState();

}
class _ProductItemListViewState extends State<ProductItemListView>{

  Widget _showFlushbar(BuildContext context,Cart cart) {
    Flushbar(
      duration: Duration(seconds: 3),
      margin: EdgeInsets.only(bottom: 50),
      padding: EdgeInsets.all(10),
      borderRadius: 8,
      backgroundColor: cart.totalAmount > 500 ? Colors.green.shade400:Colors.red.shade300,
//              backgroundGradient: LinearGradient(
//              colors: [Colors.green.shade400, Colors.greenAccent.shade700],
//              stops: [0.6, 1],
//              ),
      boxShadows: [
        BoxShadow(
          color: Colors.black45,
          offset: Offset(3, 3),
          blurRadius: 3,
        ),
      ],
      dismissDirection: FlushbarDismissDirection.HORIZONTAL,
      forwardAnimationCurve: Curves.fastLinearToSlowEaseIn,
      title: cart.totalAmount > 500 ? 'Delivery charge free' : 'Delivery charge \n50 BDT',
      message: cart.totalAmount > 500 ? ' ' : 'Shop more for free delivery charge.',
    )..show(context);
  }

  // getDeliveryCharge(Cart cart,double totalAmount) async{
  //   List deliveryChargeMatrix = [];
  //   await Provider.of<Orders>(context,listen: false).fetchDeliveryCharMatrix().then((data){
  //     deliveryChargeMatrix = data['range'];
  //     for(int i=0;i<deliveryChargeMatrix.length;i++){
  //       if(i ==0 && totalAmount<=deliveryChargeMatrix[i]['max']){
  //         setState(() {
  //           cart.deliveryCharge = deliveryChargeMatrix[i]['charge'].toDouble();
  //         });
  //       }else if( i>0 && totalAmount >= deliveryChargeMatrix[i]['min']){
  //         setState(() {
  //           cart.deliveryCharge = deliveryChargeMatrix[i]['charge'].toDouble();
  //         });
  //       }
  //     }
  //   });
  // }

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
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context);
    Map<String,dynamic> newCartItem = Map.fromIterable(cart.items, key: (v) => v.productId, value: (v) => v.quantity);

    return Card(
        shape: BeveledRectangleBorder(
          borderRadius:
          BorderRadius.all(Radius.circular(8.0)),
        ),
        child:ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                product.title,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 05.0,),
            ],
          ),
          subtitle: Text('BDT ' + product.price.toString() + '/' + product.unit,style: TextStyle(fontSize: 15.0,color: Colors.grey),),
          leading: Hero(
            tag: product.id,
            child: FadeInImage(
              image: NetworkImage(product.imageUrl),
              height: 70.0,
              width: 50.0,
              fit: BoxFit.contain,
              placeholder: AssetImage('assets/products.png'),
            ),
          ),
          trailing:
          Container(
            width: 110.0,
            child: newCartItem.keys.contains(product.id) ? Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.add),
                    onPressed: () async{
                      await cart.addItem(
                          product.id,
                          product.title,
                          product.price,
                          product.isNonInventory,
                          product.discount,
                          product.discountId,
                          product.discountType);
                      Future.delayed(const Duration(milliseconds: 500), () async{
                        await getDeliveryCharge(cart,cart.totalAmount);

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


                      // Future.delayed(Duration(milliseconds: 200)).then((_) {
                      // if(cart.items.length>0)
                      //   _showFlushbar(context,cart);
                      // });

                    },
                ),
                Text(cart.items.firstWhere((d) => d.productId == product.id).quantity.toString(),style: TextStyle(fontSize: 20.0),),
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: () async{
                    await cart.removeSingleItem(product.id);
                    Future.delayed(const Duration(milliseconds: 500), () async{
                      await getDeliveryCharge(cart,cart.totalAmount);

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


                    // Future.delayed(Duration(milliseconds: 200)).then((_) {
                    // if(cart.items.length>0)
                    //   _showFlushbar(context,cart);
                    // });
                  },
                ),
              ],
            ):IconButton(
              color: Theme.of(context).accentColor,
              icon: Icon(Icons.shopping_cart),
              onPressed: () async{
                await cart.addItem(
                    product.id,
                    product.title,
                    product.price,
                    product.isNonInventory,
                    product.discount,
                    product.discountId,
                    product.discountType);
                Future.delayed(const Duration(milliseconds: 500), () async{
                  await getDeliveryCharge(cart,cart.totalAmount);

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
          ),
          onTap: () {
            Navigator.of(context)
                .pushNamed(ProductDetailScreen.routeName, arguments: product.id);
          },
        ));
  }
}
