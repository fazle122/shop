//import 'package:flutter/material.dart';
//import 'package:provider/provider.dart';
//import 'package:shoptempdb/providers/cart.dart';
//import 'package:shoptempdb/providers/products.dart';
//import 'package:shoptempdb/widgets/product_item_grid_view.dart';
//import 'package:shoptempdb/widgets/product_item_list_view.dart';
//
//class ProductsView extends StatelessWidget {
//
//  final bool showFavorite;
//  final bool showList;
//
//  ProductsView(this.showFavorite,this.showList);
//
//  @override
//  Widget build(BuildContext context) {
//    final productsData = Provider.of<Products>(context);
//    final products = showFavorite ? productsData.favoriteItems :productsData.items;
//    final cart = Provider.of<Cart>(context);
//    return showList ?
//    ListView.builder(
//        padding: const EdgeInsets.all(10.0),
//        itemCount: products.length,
//        itemBuilder: (context, i) => ChangeNotifierProvider.value(
//          value: products[i],
//          child: ProductItemListView(),
//        )
//    )
//        :GridView.builder(
//      padding: const EdgeInsets.all(10.0),
//      itemCount: products.length,
//      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//        crossAxisCount: 2,
//        childAspectRatio: 3 / 2,
//        crossAxisSpacing: 10,
//        mainAxisSpacing: 10,
//      ),
//      itemBuilder: (context, i) => ChangeNotifierProvider.value(
//        value: products[i],
//        child: ProductItemGridView(),
//      )
//    );
//  }
//}
