import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/products.dart';
import 'package:shoptempdb/utility/util.dart';



class ProductDetailScreen extends StatefulWidget {
  static const routeName = '/product-detail';

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}


class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product loadedProduct;
  bool _isInit = true;
  bool _isLoading = false;


  @override
  void didChangeDependencies() {
    final productId = ModalRoute.of(context).settings.arguments as String;
    if(_isInit){
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchSingleProduct(int.parse(productId)).then((data){
        if(data!= null){
          loadedProduct = data;
          setState(() {
            _isLoading = false;
            _isInit = false;
          });
        }
      });
    }

    super.didChangeDependencies();
  }

  getDeliveryCharge(Cart cart, double totalAmount) async {
    List deliveryChargeMatrix = [];
    await Provider.of<Products>(context, listen: false).fetchDeliveryCharMatrix().then((data) {
      deliveryChargeMatrix = data['range'];
      for (int i = 0; i < deliveryChargeMatrix.length; i++) {
        if (i == 0 && totalAmount <= deliveryChargeMatrix[i]['max']) {
          setState(() {
            cart.deliveryCharge = deliveryChargeMatrix[i]['charge'].toDouble();
          });
        } else if (i > 0 && totalAmount >= deliveryChargeMatrix[i]['min']) {
          setState(() {
            cart.deliveryCharge = deliveryChargeMatrix[i]['charge'].toDouble();
          });
        } else if (i > 0) {
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
    final cart = Provider.of<Cart>(context);
    Map<String, dynamic> newCartItem = Map.fromIterable(cart.items, key: (v) => v.productId, value: (v) => v.quantity);
    return Scaffold(
        backgroundColor: Theme.of(context).primaryColor,
        body:_isLoading? Center(child: CircularProgressIndicator(),):Container(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(
                    left: 24.0, right: 24.0, bottom: 24.0, top: 48.0),
                child: Row(
                  children: <Widget>[
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(true);
                      },
                      child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                              Radius.circular(15),
                            ),
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_left,
                            color: Colors.black,
                            size: 28,
                          )),
                    ),
                  ],
                ),
              ),
              Center(
                child: SizedBox(
                  height: 170,
                  child: Hero(
                    tag: loadedProduct.title,
                    child: Image.network(
                      loadedProduct.imageUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(50),
                    ),
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          loadedProduct.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        Text(
                          loadedProduct.price
                              .toString() +
                              '/' +
                              loadedProduct.unit,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),

                        SizedBox(
                          height: 24.0,
                        ),

                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Container(
                                child: newCartItem.keys.contains(
                                    loadedProduct.id)
                                    ? Row(
                                  children: <Widget>[
                                    Container(
                                        width: 48,
                                        height: 48,
                                        decoration:
                                        BoxDecoration(
                                          color:
                                          Colors.grey[200],
                                          borderRadius:
                                          BorderRadius.only(
                                            topLeft:
                                            Radius.circular(
                                                15),
                                            bottomLeft:
                                            Radius.circular(
                                                15),
                                          ),
                                        ),
                                        child: InkWell(
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.black,
                                          ),
                                          onTap: () async {
                                            cart.addItem(
                                              loadedProduct.id,
                                              loadedProduct.title,
                                              loadedProduct.imageUrl,
                                              loadedProduct.price,
                                              loadedProduct.vatRate,
                                              loadedProduct.isNonInventory,
                                              loadedProduct.discount,
                                              loadedProduct.discountId,
                                              loadedProduct.discountType,
                                            );
                                            Future.delayed(
                                                const Duration(
                                                    milliseconds:
                                                    500),
                                                    () async {
                                                  await Util.getDeliveryCharge(context,cart);
                                                });
                                          },
                                        )),
                                    Container(
                                      color: Colors.grey[200],
                                      width: 48,
                                      height: 48,
                                      child: Center(
                                        child: Text(cart.items.firstWhere((d) => d.productId == loadedProduct.id).quantity.toString(),
                                          style: TextStyle(
                                              fontSize: 25.0),
                                        ),
                                      ),
                                    ),
                                    Container(
                                        width: 48,
                                        height: 48,
                                        decoration:
                                        BoxDecoration(
                                          color:
                                          Colors.grey[200],
                                          borderRadius:
                                          BorderRadius.only(
                                            topRight:
                                            Radius.circular(
                                                15),
                                            bottomRight:
                                            Radius.circular(
                                                15),
                                          ),
                                        ),
                                        child: InkWell(
                                          child: Icon(
                                            Icons.remove,
                                            color: Colors.black,
                                          ),
                                          onTap: () async {
                                            cart.removeSingleItem(
                                                loadedProduct.id);
                                            Future.delayed(
                                                const Duration(
                                                    milliseconds:
                                                    500),
                                                    () async {
                                                      await Util.getDeliveryCharge(context,cart);
                                                });
                                          },
                                        )),
                                  ],
                                )
                                    : Row(
                                  children: <Widget>[
                                    Container(
                                        width: 70,
                                        height: 48,
                                        decoration:
                                        BoxDecoration(
                                          color:
                                          Colors.grey[200],
                                          borderRadius:
                                          BorderRadius.only(
                                            topLeft:
                                            Radius.circular(
                                                15),
                                            bottomLeft:
                                            Radius.circular(
                                                15),
                                            topRight:
                                            Radius.circular(
                                                15),
                                            bottomRight:
                                            Radius.circular(
                                                15),
                                          ),
                                        ),
                                        child: InkWell(
                                          child: Icon(
                                            Icons.shopping_cart,
                                            color: Theme.of(
                                                context)
                                                .accentColor,
                                          ),
                                          onTap: () {
                                            cart.addItem(
                                              loadedProduct.id,
                                              loadedProduct.title,
                                              loadedProduct.imageUrl,
                                              loadedProduct.price,
                                              loadedProduct.vatRate,
                                              loadedProduct.isNonInventory,
                                              loadedProduct.discount,
                                              loadedProduct.discountId,
                                              loadedProduct.discountType,
                                            );
                                            Future.delayed(
                                                const Duration(
                                                    milliseconds:
                                                    500),
                                                    () async {
                                                  // await getDeliveryCharge(cart, cart.totalAmount);
                                                      await Util.getDeliveryCharge(context,cart);
                                                });
                                          },
                                        )),
                                  ],
                                )),
                            Container(
                                child: Text(
                                  newCartItem.keys.contains(loadedProduct.id)
                                      ? 'BDT ' +
                                      (loadedProduct.price
                                          .toDouble() *
                                          (cart.items
                                              .firstWhere((d) =>
                                          d.productId ==
                                              loadedProduct
                                                  .id)
                                              .quantity
                                              .toDouble()))
                                          .toString()
                                      : 'BDT 0.00',
                                  style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                )),
                          ],
                        ),

                        SizedBox(
                          height: 24.0,
                        ),

                        Expanded(
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.stretch,
                              children: <Widget>[
                                Text(
                                  "Product description",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                loadedProduct.description != null
                                    ? Text(
                                  loadedProduct.description,
                                  textAlign: TextAlign.center,
                                  softWrap: true,
                                  style:
                                  TextStyle(fontSize: 15.0),
                                )
                                    : Text('No description found'),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(
                          height: 24.0,
                        ),

                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        )
    );
  }
}

