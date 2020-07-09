import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shoptempdb/providers/cart.dart';
import 'package:shoptempdb/providers/product.dart';
import 'package:shoptempdb/providers/products.dart';
import 'package:shoptempdb/screens/cart_screen.dart';
import 'package:shoptempdb/widgets/app_drawer.dart';
import 'package:shoptempdb/widgets/badge.dart';
import 'package:shoptempdb/widgets/filter_item.dart';
import 'package:shoptempdb/widgets/product_item_grid_view.dart';
import 'package:shoptempdb/widgets/product_item_list_view.dart';

import '../base_state.dart';

class ProductsOverviewScreen extends StatefulWidget {
  static const routeName = 'all-products';

  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends BaseState<ProductsOverviewScreen> {
  var _showList = false;
  var _isInit = true;
  var _isLoading = false;

  ScrollController _scrollController = new ScrollController();
  int pageCount = 1;
  int lastPage;
  String keyword= '';
  int oldPageCount;
  List<Product> finalProduct = [];


  @override
  void didChangeDependencies() {
    final products = Provider.of<Products>(context, listen: false);
    final cat = ModalRoute.of(context).settings.arguments as String;
    if (pageCount == 1) {
      if (_isInit) {
        setState(() {
          _isLoading = true;
        });
        if(cat != null){
          Provider.of<Products>(context, listen: false).fetchAndSetProducts(
              pageCount,int.parse(cat)).then((data) {
            setState(() {
              finalProduct = data;
              lastPage = products.lastPageNo;
              oldPageCount = 0;
              _isLoading = false;
            });
          });
        }else {
        Provider.of<Products>(context, listen: false).fetchAndSetProducts(
            pageCount,0).then((data) {
          setState(() {
            finalProduct = data;
            lastPage = products.lastPageNo;
            oldPageCount = 0;
            _isLoading = false;
          });
        });
      }
      }
      _isInit = false;
    }

      _scrollController.addListener(() {
        if (pageCount - oldPageCount == 1 || oldPageCount - pageCount == 1)
        {
        _isInit = true;
            if(pageCount < lastPage)
        if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent) {
          setState(() {
            pageCount += 1;
          });
          getData('increment');
        }
        if (pageCount > 0)
          if (_scrollController.position.pixels ==
              _scrollController.position.minScrollExtent) {
            setState(() {
              pageCount -= 1;
            });
            getData('decrement');
          }
        }

      });

    super.didChangeDependencies();
  }



  List<Product> getData(String type) {
    final cat = ModalRoute.of(context).settings.arguments as String;
    if(_isInit){
      setState(() {
        _isLoading = true;
      });
      if(cat != null) {
        Provider.of<Products>(context, listen: false).fetchAndSetProducts(
            pageCount, int.parse(cat))
            .then((data) {
          setState(() {
            finalProduct = data;
            _isLoading = false;
            type == 'increment' ? oldPageCount += 1 : oldPageCount -= 1;
          });
        });
      }else{
        Provider.of<Products>(context, listen: false).fetchAndSetProducts(
            pageCount, 0)
            .then((data) {
          setState(() {
            finalProduct = data;
            _isLoading = false;
            type == 'increment' ? oldPageCount += 1 : oldPageCount -= 1;
          });
        });
      }
    }
    _isInit = false;

//    final productsData = Provider.of<Products>(context, listen: false);
////    List<Product> products = productsData.items;
//
//    List<Product> tempProduct = [];
//    tempProduct = productsData.items;
//
//    if (tempProduct == null || tempProduct.isEmpty) {
//      if (productsData.items.isNotEmpty) {
//        animateScrollBump();
//      }
//    } else {
//      setState(() {
//        _isLoading = false;
//        productsData.items.addAll(tempProduct);
//        finalProduct = productsData.items;
//      });
//    }
//
  return finalProduct;
  }

  @override
  Widget build(BuildContext context) {
//    final productsData = Provider.of<Products>(context);
//    final cat = ModalRoute.of(context).settings.arguments as String;
//    final products = cat != null ? productsData.items.where((data) => data.category == cat).toList():finalProduct;
    final products = finalProduct;
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                Expanded(
                  child: _showList
                      ?  products != null && products.length > 0
                          ? ListView.builder(
                              padding: const EdgeInsets.all(10.0),
                              controller: _scrollController,
                              itemCount: products.length,
                              itemBuilder: (context, i) =>
                                  ChangeNotifierProvider.value(
                                    value: products[i],
                                    child: ProductItemListView(),
                                  ))
                          : Center(
                              child: Text('No item found'),
                            )
                      : products != null && products.length > 0
                          ? GridView.builder(
                              controller: _scrollController,
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
                                  ))
                          : Center(
                              child: Text('No item found'),
                            ),
                ),
                cart.items.length > 0
                    ? Container(
                        height: 50.0,
                        color: Theme.of(context).primaryColor,
                        child: Row(
                          children: <Widget>[
                            Container(
                                width:
                                    MediaQuery.of(context).size.width * 5 / 7,
                                padding: EdgeInsets.only(left: 20.0, top: 2.0),
                                color: Theme.of(context).primaryColor,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: <Widget>[
                                    Text('SubTotal: ' +
                                        cart.totalAmount.toStringAsFixed(2)),
                                    cart.totalAmount > 500
                                        ? Text('Delivery charge: 00.00 BDT')
                                        : Text('Delivery charge: 50.00 BDT'),
                                    cart.totalAmount > 500
                                        ? Text(
                                            'Total amount : ' +
                                                cart.totalAmount
                                                    .toStringAsFixed(2),
                                            style:
                                                TextStyle(color: Colors.white),
                                          )
                                        : Text(
                                            'Total amount : ' +
                                                (cart.totalAmount + 50.00)
                                                    .toStringAsFixed(2),
                                            style:
                                                TextStyle(color: Colors.white),
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
                        ))
                    : SizedBox(
                        width: 0.0,
                        height: 0.0,
                      )
              ],
            ),
    );
  }
  void animateScrollBump() {
    double edge = 50.0;
    double offsetFromBottom = _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;
    if (offsetFromBottom < edge) {
      _scrollController.animateTo(
          _scrollController.offset - (edge - offsetFromBottom),
          duration: new Duration(milliseconds: 500),
          curve: Curves.easeOut);
    }
  }
}
