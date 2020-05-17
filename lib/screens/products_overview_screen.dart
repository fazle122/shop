import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/products.dart';
import 'package:shoptempdb/screens/cart_screen.dart';
import 'package:shoptempdb/widgets/app_drawer.dart';
import 'package:shoptempdb/widgets/badge.dart';
import 'package:shoptempdb/widgets/filter_item.dart';
import 'package:shoptempdb/widgets/product_item_grid_view.dart';
import 'package:shoptempdb/widgets/product_item_list_view.dart';

class ProductsOverviewScreen extends StatefulWidget {
  static const routeName = 'all-products';

  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  var _showList = false;

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<Products>(context);
    final cat = ModalRoute.of(context).settings.arguments as String;
    final products = cat != null ? productsData.items.where((data) => data.category == cat).toList():productsData.items;
    final cart = Provider.of<Cart>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Bepari'),
        actions: <Widget>[
          IconButton(
            icon: !_showList
                ? Icon(
                    Icons.list,
                    size: 25.0,
                  )
                : Icon(
                    Icons.grid_on,
                    size: 20.0,
                  ),
            onPressed: () {
              setState(() {
                _showList = !_showList;
              });
            },
          ),
          Consumer<Cart>(
            builder: (context, cart, ch) => Badge(
              child: ch,
              value: cart.itemCount.toString(),
            ),
            child: IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: DataSearch(_showList));
            },
          ),
        ],
      ),
      drawer: AppDrawer(),
//      body: ProductsView(_showOnlyFavorites, _showList),
      body: Column(
        children: <Widget>[
          Expanded(
            child: _showList
                ? ListView.builder(
                    padding: const EdgeInsets.all(10.0),
                    itemCount: products.length,
                    itemBuilder: (context, i) => ChangeNotifierProvider.value(
                          value: products[i],
                          child: ProductItemListView(),
                        ))
                : GridView.builder(
                    padding: const EdgeInsets.all(10.0),
                    itemCount: products.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, i) => ChangeNotifierProvider.value(
                          value: products[i],
                          child: ProductItemGridView(),
                        )),
          )
        ],
      ),
    );
  }


//  Widget _searchBar(BuildContext context) {
//    final productsData = Provider.of<Products>(context);
//    final products = productsData.items;
//    return Container(
//      margin: EdgeInsets.all(5.0),
//      decoration: BoxDecoration(
//          borderRadius: BorderRadius.circular(4.0),
//          border: Border.all(width: 1, color: Colors.grey)),
//      child: Row(
//        children: <Widget>[
//          Expanded(
//              flex: 1,
//              child: Container(
//                color: Colors.grey[350],
//                child: IconButton(
//                  icon: Icon(
//                    Icons.cancel,
//                    color: Theme.of(context).primaryColor,
//                  ),
//                  onPressed: () {
//                    setState(() {
//                      _showSearchBar = false;
//                    });
//                  },
//                ),
//              )),
//          Expanded(
//              flex: 7,
//              child: TextField(
//                autofocus: true,
//                textInputAction: TextInputAction.search,
//                onChanged: (val) {
//                  initiateSearch(val, products);
//                },
//                decoration: InputDecoration(
//                    contentPadding: EdgeInsets.only(left: 10.0),
//                    hintText: 'Search by product name',
//                    border: InputBorder.none),
//              ))
//        ],
//      ),
//    );
//  }
}
