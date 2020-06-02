import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/product.dart';
import 'package:shoptempdb/providers/products.dart';


class ProductDetailScreen extends StatelessWidget{

  static const routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    final loadedProduct = Provider.of<Products>(context,listen:false).findById(productId);
    final cart = Provider.of<Cart>(context,);

    return Scaffold(
      appBar: AppBar(title: Text(loadedProduct.title),),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(height: 300,width:double.infinity,child: Hero(
              tag:loadedProduct.id,
              child: Image.network(loadedProduct.imageUrl,fit: BoxFit.cover,),
            ),),
            SizedBox(height: 10,),
//            Text('\$${loadedProduct.price}',style: TextStyle(color: Colors.grey,fontSize: 20),),
            Text('BDT ' + loadedProduct.price.toString() + '/' + loadedProduct.unit,style: TextStyle(color: Colors.grey,fontSize: 20),),
            cart.items.keys.contains(loadedProduct.id) ? Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.add),
                  onPressed: (){
                    cart.addItem(loadedProduct.id, loadedProduct.title, loadedProduct.price);
                  },
                ),
                Text(cart.items[loadedProduct.id].quantity.toString(),style: TextStyle(fontSize: 15.0),),
                IconButton(
                  icon: Icon(Icons.remove),
                  onPressed: (){
                    cart.removeSingleItem(loadedProduct.id);
                  },
                ),
              ],
            ):IconButton(
              color: Theme.of(context).accentColor,
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                cart.addItem(loadedProduct.id, loadedProduct.title, loadedProduct.price);
              },
            ),
            SizedBox(height: 10,),
            Container(
              padding: EdgeInsets.symmetric(horizontal:10),
              width: double.infinity,
              child:Column(
                children: <Widget>[
                  Text(
                    loadedProduct.title,
                    textAlign: TextAlign.start,
                    softWrap: true,
                    style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10.0,),
                  loadedProduct.description.isNotEmpty?Text(
                    loadedProduct.description,
                    textAlign: TextAlign.start,
                    softWrap: true,
                    style: TextStyle(fontSize: 15.0),
                  ):Text('No description found'),
                ],
              )
            )
//            Container(
//              padding: EdgeInsets.symmetric(horizontal:10),
//              width: double.infinity,
//              child: Text(
//                loadedProduct.description,
//                textAlign: TextAlign.center,
//                softWrap: true,
//              ),
//            )

          ],
        ),
      )
    );
  }


}