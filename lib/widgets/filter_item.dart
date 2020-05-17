


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/product.dart';
import 'package:shoptempdb/providers/products.dart';
import 'package:shoptempdb/widgets/product_item_grid_view.dart';
import 'package:shoptempdb/widgets/product_item_list_view.dart';

class DataSearch extends SearchDelegate<String> {

  final bool _showList;

  DataSearch(this._showList);
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = "";
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
        icon: AnimatedIcon(
            icon: AnimatedIcons.menu_arrow, progress: transitionAnimation),
        onPressed: () {
          close(context, null);
        });
  }

  @override
  Widget buildResults(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    List<Product> products = productsData.items.where((data) => data.title.toLowerCase().startsWith(query.toLowerCase())).toList();
    final cart = Provider.of<Cart>(context);

    return
      _showList
          ? ListView.builder(
          padding: const EdgeInsets.all(10.0),
          itemCount: products.length,
          itemBuilder: (context, i) =>
              ChangeNotifierProvider.value(
                value: products[i],
                child: ProductItemListView(),
              ))
          :
      GridView.builder(
          padding: const EdgeInsets.all(10.0),
          itemCount: products.length,
          gridDelegate:
          SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 3 / 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, i) =>
              ChangeNotifierProvider.value(
                value: products[i],
                child: ProductItemGridView(),
              ));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    List<Product> products = query.isEmpty
        ? []
        : productsData.items
        .where((data) =>
        data.title.toLowerCase().startsWith(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (context, i) => ListTile(
        onTap: (){
          showResults(context);
        },
        title: RichText(
          text: TextSpan(
              text: products[i].title.substring(0, query.length),
              style:
              TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: products[i].title.substring(query.length),
                  style: TextStyle(color: Colors.grey),
                )
              ]),
        ),
      ),
    );
//    List<Product> data = products.where((dt) => dt.title.toLowerCase().contains(value.toLowerCase())).toList();
  }
}