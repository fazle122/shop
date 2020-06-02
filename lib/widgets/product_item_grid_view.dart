import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/product.dart';
import 'package:shoptempdb/screens/product_detail_screen.dart';

class ProductItemGridView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context, listen: false);
    final cart = Provider.of<Cart>(context, listen: false);
    return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: GridTile(
          child: GestureDetector(
              onTap: () {
                Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                    arguments: product.id);
              },
              child: Hero(
                tag: product.id,
                child: FadeInImage(
                  image: NetworkImage(product.imageUrl),
                  fit: BoxFit.cover,
                  placeholder: AssetImage('assets/products.png'),
                ),
              )),
          footer: GridTileBar(
            title: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                !cart.items.keys.contains(product.id)
                    ? Text(
                        product.title,
                        textAlign: TextAlign.start,
                      )
                    : SizedBox(
                        width: 0.0,
                        height: 0.0,
                      ),
                !cart.items.keys.contains(product.id)
                    ? Text(
                        'BDT ' + product.price.toString() + '/' + product.unit,
                        style: TextStyle(fontSize: 12.0, color: Colors.grey),
                      )
                    : SizedBox(
                        width: 0.0,
                        height: 0.0,
                      ),
                cart.items.keys.contains(product.id)
                    ? Text(cart.items[product.id].quantity.toString(),
                        style: TextStyle(
                          fontSize: 15.0,
                        ))
                    : SizedBox(
                        width: 0.0,
                        height: 0.0,
                      ),
              ],
            ),
            backgroundColor: Colors.black54,
            leading: cart.items.keys.contains(product.id)
                ?
//                Consumer<Product>(
//                    builder: (context, product, child) => IconButton(
//                      icon: Icon(Icons.add),
//                      onPressed: (){
//                        cart.addItem(product.id, product.title, product.price);
//                        Scaffold.of(context).hideCurrentSnackBar();
//                        if(cart.items.length> 0)
//                          Scaffold.of(context).showSnackBar(SnackBar(
//                            backgroundColor: cart.totalAmount > 500
//                                ? Theme.of(context).primaryColor
//                                : Colors.red[300],
//                            content: cart.totalAmount > 500
//                                ? Container(padding: EdgeInsets.only(top: 5.0,bottom: 5.0),
//                    child:Text('Delievry charge free'))
//                                : Row(
//                              children: <Widget>[
//                                Container(
//                                    decoration: BoxDecoration(
//                                        border: Border(
//                                            right: BorderSide(
//                                                color: Colors.white,
//                                                width: 1.0))),
//                                    width: MediaQuery.of(context).size.width *
//                                        1 /
//                                        7,
//                                    child: Text('Delivery charge \n50 BDT')),
//                                SizedBox(
//                                  width: 5.0,
//                                ),
//                                Container(
//                                  width: MediaQuery.of(context).size.width *
//                                      4 /
//                                      7,
//                                  child: Text(
//                                      'Shop more for free delivery charge.'),
//                                )
//                              ],
//                            ),
//                            duration: Duration(seconds: 2),
//                          ));
//                      },
//                    ),
//                  )
            IconButton(
              icon: Icon(Icons.add),
              onPressed: (){
                cart.addItem(product.id, product.title, product.price);
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
            )
                : SizedBox(
                    width: 0.0,
                    height: 0.0,
                  ),
            trailing: cart.items.keys.contains(product.id)
                ? IconButton(
                    icon: Icon(Icons.remove),
                    onPressed: () {
                      cart.removeSingleItem(product.id);
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
                  )
                : IconButton(
                    color: Theme.of(context).accentColor,
                    icon: Icon(Icons.shopping_cart),
                    onPressed: () {
                      cart.addItem(product.id, product.title, product.price);
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
//              action: SnackBarAction(
//                label: 'undo',
//                onPressed: (){
//                  cart.removeSingleItem(product.id);
//                },
//              ),
                      ));
                    },
                  ),
          ),
        ));
  }
}
