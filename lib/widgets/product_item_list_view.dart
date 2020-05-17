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
    final cart = Provider.of<Cart>(context, listen: false);
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
        child: cart.items.keys.contains(product.id) ? Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.add),
              onPressed: (){
                cart.addItem(product.id, product.title, product.price);
              },
            ),
             Text(cart.items[product.id].quantity.toString(),style: TextStyle(fontSize: 20.0),),
            IconButton(
              icon: Icon(Icons.remove),
              onPressed: (){
                cart.removeSingleItem(product.id);
              },
            ),
          ],
        ):IconButton(
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
//                onPressed: () {
//                  cart.removeSingleItem(product.id);
//                },
//              ),
//            ));
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
