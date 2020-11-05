import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/products.dart';
import 'package:shoptempdb/screens/product_detail_screen.dart';


class ProductItemListView extends StatefulWidget {


  @override
  _ProductItemListViewState createState() => _ProductItemListViewState();

}
class _ProductItemListViewState extends State<ProductItemListView>{


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
        // shape: BeveledRectangleBorder(
        //   borderRadius:
        //   BorderRadius.all(Radius.circular(8.0)),
        // ),
        child:ListTile(
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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                product.title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.0),
              ),
            ],
          ),
          subtitle: Text('BDT ' + product.price.toString(),style: TextStyle(fontSize: 10.0,color: Colors.red,fontWeight: FontWeight.bold),),

          trailing: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(product.unit,style: TextStyle(fontSize: 12.0,color: Colors.grey,)),
                  newCartItem.keys.contains(product.id) ?
                  Expanded(
                      child:Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                            icon: Icon(Icons.add_circle_outline),
                            color:Colors.red,
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
                          Text(cart.items.firstWhere((d) => d.productId == product.id).quantity.toString(),style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold,color:Colors.red),),
                          IconButton(
                            icon: Icon(Icons.remove_circle_outline,),
                            color: Colors.red,
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
                      )):
                      Container(
                        margin: EdgeInsets.only(top:5.0),
                        padding: EdgeInsets.all(2.0),
                        width: 70.0,
                        height: 20.0,
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor
                        ),
                        child: InkWell(
                          child: Center(child:Text('Add to cart',style: TextStyle(fontSize: 12.0,color: Colors.white,fontWeight: FontWeight.bold),),),
                          onTap: () async{
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
                      )
                      )


                      // IconButton(
                      //   color: Theme.of(context).accentColor,
                      //   icon: Icon(Icons.shopping_cart),
                      //   onPressed: () async{
                      //     await cart.addItem(
                      //         product.id,
                      //         product.title,
                      //         product.price,
                      //         product.isNonInventory,
                      //         product.discount,
                      //         product.discountId,
                      //         product.discountType);
                      //     Future.delayed(const Duration(milliseconds: 500), () async{
                      //       await getDeliveryCharge(cart,cart.totalAmount);
                      //
                      //       Scaffold.of(context).showSnackBar(SnackBar(
                      //         backgroundColor: cart.totalAmount > cart.maxDeliveryRange ? Theme.of(context).primaryColor : Colors.red[300],
                      //         content: cart.totalAmount > cart.maxDeliveryRange
                      //             ? Container(
                      //             padding: EdgeInsets.only(top: 5.0,bottom: 5.0),
                      //             child:Text('Delivery charge : ' + cart.deliveryCharge.toString() + ' BDT')
                      //         )
                      //             : Row(
                      //           children: <Widget>[
                      //             SizedBox(
                      //               width: 5.0,
                      //             ),
                      //             Container(
                      //               width: MediaQuery.of(context).size.width * 4 / 7,
                      //               child: Text('Shop more item of ' +  (cart.maxDeliveryRange-cart.totalAmount).toString() +  ' BDT to reduce delivery charge.'),
                      //             )
                      //           ],
                      //         ),
                      //         duration: Duration(seconds: 2),
                      //       ));
                      //     });
                      //   },
                      // ),



                    // ),


                ],

              ),

          onTap: () {
            Navigator.of(context)
                .pushNamed(ProductDetailScreen.routeName, arguments: product.id);
          },
        ));
  }
}
