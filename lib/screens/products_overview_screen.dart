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
  var _isInit = true;
  var _isLoading = false;

  @override
  void didChangeDependencies(){
    if(_isInit) {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });
      Provider.of<Products>(context).fetchAndSetProducts().then((_){
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

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
              if (!mounted) return;
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
          ),
          cart.items.length > 0 ?
          Container(
              height: 50.0,
              color: Theme.of(context).primaryColor,
              child: Row(
                children: <Widget>[
                  Container(
                      width: MediaQuery.of(context).size.width * 5 / 7,
                      padding: EdgeInsets.only(left: 20.0,top: 5.0),
                      color: Theme.of(context).primaryColor,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Text('SubTotal: ' +
                              cart.totalAmount.toStringAsFixed(2)),
                          cart.totalAmount>500 ? Text('Delivery charge: 00.00 BDT'):Text('Delivery charge: 50.00 BDT'),
                          cart.totalAmount>500 ?
                          Text(
                            'Total amount : ' +
                                cart.totalAmount.toStringAsFixed(2),
                            style: TextStyle(color: Colors.white),
                          )
                              :Text(
                            'Total amount : ' +
                                (cart.totalAmount + 50.00).toStringAsFixed(2),
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      )),
                  Container(
                    height: MediaQuery.of(context).size.height,
                    width: MediaQuery.of(context).size.width * 2 / 7,
                    color: Theme.of(context).primaryColorDark,
                    child: InkWell(
                      child: Center(
                        child: Text(
                          'Check out',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(CartScreen.routeName);
                      },
                    ),
                  ),
                ],
              )) :SizedBox(width: 0.0,height: 0.0,)
        ],
      ),
    );
  }
}
