import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/product.dart';
import 'package:shoptempdb/screens/product_detail_screen.dart';

class ProductItemGridView extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final product = Provider.of<Product>(context,listen: false);
    final cart = Provider.of<Cart>(context,listen: false);
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
        child:GridTile(
      child: GestureDetector(
        onTap: (){
          Navigator.of(context).pushNamed(ProductDetailScreen.routeName,arguments: product.id);
        },
        child: Hero(
          tag:product.id,
          child: FadeInImage(
            image: NetworkImage(product.imageUrl),
            fit: BoxFit.cover,
            placeholder: AssetImage('assets/products.png'),
          ),
        )
      ),
      footer: GridTileBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            !cart.items.keys.contains(product.id) ?Text(
              product.title,
              textAlign: TextAlign.start,
            ):SizedBox(width: 0.0,height: 0.0,),

            !cart.items.keys.contains(product.id) ?
            Text('BDT ' + product.price.toString() + '/' + product.unit,style: TextStyle(fontSize: 12.0,color: Colors.grey),):SizedBox(width: 0.0,height: 0.0,),

            cart.items.keys.contains(product.id) ?
            Text(cart.items[product.id].quantity.toString(),style: TextStyle(fontSize: 15.0,))
                :SizedBox(width: 0.0,height: 0.0,),
          ],
        ),
        backgroundColor: Colors.black54,
        leading: cart.items.keys.contains(product.id) ? Consumer<Product>(
          builder: (context,product,child) => IconButton(
            icon: Icon(Icons.add),
            onPressed: (){
              cart.addItem(product.id, product.title, product.price);
            },
          ),
        ):SizedBox(width: 0.0,height: 0.0,),
        trailing: cart.items.keys.contains(product.id) ?
        IconButton(
          icon: Icon(Icons.remove),
          onPressed: (){
            cart.removeSingleItem(product.id);
          },
        )
        : IconButton(
          color: Theme.of(context).accentColor,
          icon: Icon(Icons.shopping_cart),
          onPressed: () {
            cart.addItem(product.id, product.title, product.price);
//            Scaffold.of(context).hideCurrentSnackBar();
//            Scaffold.of(context).showSnackBar(SnackBar(
//              content: Text('Item added to cart.'),
//              duration: Duration(seconds: 2),
//              action: SnackBarAction(
//                label: 'undo',
//                onPressed: (){
//                  cart.removeSingleItem(product.id);
//                },
//              ),
//            ));
          },
        ),
      ),
    ));
  }
}
