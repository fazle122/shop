import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/orders.dart';
import 'package:shoptempdb/providers/product.dart';
import 'package:shoptempdb/providers/products.dart';
import 'package:shoptempdb/screens/product_detail_screen.dart';
import 'package:flushbar/flushbar.dart';

class ProductItemGridView extends StatefulWidget {


  @override
  _ProductItemGridView createState() => _ProductItemGridView();
}

class _ProductItemGridView extends State<ProductItemGridView> {


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
    var cart = Provider.of<Cart>(context);
    Map<String, dynamic> newCartItem = Map.fromIterable(cart.items,
        key: (v) => v.productId, value: (v) => v.quantity);
    return GestureDetector(
      onTap: () {
        Navigator.of(context)
            .pushNamed(ProductDetailScreen.routeName, arguments: product.id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white54,
          borderRadius: BorderRadius.all(
            Radius.circular(25),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Text(
                product.title,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  Text(
                    r"$ " + product.price.toString(),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: 8.0,
                  ),
                  Text(
                    '/' + product.unit,
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 8.0,
              ),
              Expanded(
                  child: Hero(
                tag: product.id,
                child: FadeInImage(
                  image: NetworkImage(product.imageUrl),
                  fit: BoxFit.cover,
                  placeholder: AssetImage('assets/products.png'),
                ),
              )),
              SizedBox(
                height: 8.0,
              ),
              Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.1),
                    borderRadius: BorderRadius.all(
                      Radius.circular(25),
                    ),
                  ),
                  child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: newCartItem.keys.contains(product.id)
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                InkWell(
                                  child: Icon(
                                    Icons.add,
                                    size: 22,
                                  ),
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

                                    });
                                  },
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                Container(
                                  child: Text(
                                      cart.items
                                          .firstWhere(
                                              (d) => d.productId == product.id)
                                          .quantity
                                          .toString(),
                                      style: TextStyle(fontSize: 20.0)),
                                ),
                                SizedBox(
                                  width: 15,
                                ),
                                InkWell(
                                  child: Icon(
                                    Icons.remove,
                                    size: 22,
                                  ),
                                  onTap: () async{
                                    await cart.removeSingleItem(product.id);
                                    Future.delayed(const Duration(milliseconds: 500), () async{
                                    await getDeliveryCharge(cart,cart.totalAmount);
                                    });
                                  },
                                )
                              ],
                            )
                          : InkWell(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Text(
                                    "Add to cart",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 5.0,
                                  ),
                                  Icon(
                                    Icons.add_shopping_cart,
                                    color: Theme.of(context).accentColor,
                                    size: 22,
                                  )
                                ],
                              ),
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
                                });

                              },
                            )))
            ],
          ),
        ),
      ),
    );
  }
}
