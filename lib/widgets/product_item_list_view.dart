import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/product.dart';
import 'package:shoptempdb/screens/product_detail_screen.dart';

class ProductItemListView extends StatefulWidget {

//  final int quantity;
//  ProductItemListView(this.quantity);

  @override
  _ProductItemListViewState createState() => _ProductItemListViewState();

}
class _ProductItemListViewState extends State<ProductItemListView>{


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
                  onPressed: (){
                    cart.addItem(product.id, product.title, product.price,product.isNonInventory,product.discount,product.discountId,product.discountType);
                    Scaffold.of(context).hideCurrentSnackBar();
                    if(cart.items.length> 0)
                      Scaffold.of(context).showSnackBar(SnackBar(
                        backgroundColor: cart.totalAmount > 500
                            ? Theme.of(context).primaryColor
                            : Colors.red[300],
                        content: cart.totalAmount > 500
                            ? Container(padding: EdgeInsets.only(top: 5.0,bottom: 5.0),
                            child:Text('Delievry charge free'))
                            : Row(
                          children: <Widget>[
                            Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                        right: BorderSide(
                                            color: Colors.white,
                                            width: 1.0))),
                                width: MediaQuery.of(context).size.width *
                                    1 /
                                    7,
                                child: Text('Delivery charge \n50 BDT')),
                            SizedBox(
                              width: 5.0,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width *
                                  4 /
                                  7,
                              child: Text(
                                  'Shop more for free delivery charge.'),
                            )
                          ],
                        ),
                        duration: Duration(seconds: 2),
                      )
                      );
                  },
                ),
                Text(cart.items.firstWhere((d) => d.productId == product.id).quantity.toString(),style: TextStyle(fontSize: 20.0),),
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: (){
                    cart.removeSingleItem(product.id, product.title, product.price,product.isNonInventory,product.discount,product.discountId,product.discountType);
                    Scaffold.of(context).hideCurrentSnackBar();
                    if(cart.items.length> 0)
                      Scaffold.of(context).showSnackBar(SnackBar(
                        backgroundColor: cart.totalAmount > 500
                            ? Theme.of(context).primaryColor
                            : Colors.red[300],
                        content: cart.totalAmount > 500
                            ? Container(padding: EdgeInsets.only(top: 5.0,bottom: 5.0),
                            child:Text('Delievry charge free'))
                            : Row(
                          children: <Widget>[
                            Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                        right: BorderSide(
                                            color: Colors.white,
                                            width: 1.0))),
                                width: MediaQuery.of(context).size.width *
                                    1 /
                                    7,
                                child: Text('Delivery charge \n50 BDT')),
                            SizedBox(
                              width: 5.0,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width *
                                  4 /
                                  7,
                              child: Text(
                                  'Shop more for free delivery charge.'),
                            )
                          ],
                        ),
                        duration: Duration(seconds: 2),
                      ));
                  },
                ),
              ],
            ):IconButton(
              color: Theme.of(context).accentColor,
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                cart.addItem(product.id, product.title, product.price,product.isNonInventory,product.discount,product.discountId,product.discountType);
                Scaffold.of(context).hideCurrentSnackBar();
                if(cart.items.length> 0)
                  Scaffold.of(context).showSnackBar(SnackBar(
                    backgroundColor: cart.totalAmount > 500
                        ? Theme.of(context).primaryColor
                        : Colors.red[300],
                    content: cart.totalAmount > 500
                        ? Container(padding: EdgeInsets.only(top: 5.0,bottom: 5.0),
                        child:Text('Delievry charge free'))
                        : Row(
                      children: <Widget>[
                        Container(
                            decoration: BoxDecoration(
                                border: Border(
                                    right: BorderSide(
                                        color: Colors.white,
                                        width: 1.0))),
                            width: MediaQuery.of(context).size.width *
                                1 /
                                7,
                            child: Text('Delivery charge \n50 BDT')),
                        SizedBox(
                          width: 5.0,
                        ),
                        Container(
                          width: MediaQuery.of(context).size.width *
                              4 /
                              7,
                          child: Text(
                              'Shop more for free delivery charge.'),
                        )
                      ],
                    ),
                    duration: Duration(seconds: 2),
                  ));
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
